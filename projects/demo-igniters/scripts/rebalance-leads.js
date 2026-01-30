#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const TARGET_ORG = process.env.SF_TARGET_ORG || 'agentforce-for-sales-demo-org';
const OUTPUT_DIR = path.join(__dirname, '..', 'data');
const CSV_PATH = path.join(OUTPUT_DIR, 'lead-owner-rebalance.csv');

function run(cmd) {
  return execSync(cmd, { stdio: 'pipe', encoding: 'utf8', cwd: path.join(__dirname, '..') });
}

function queryJson(soql) {
  const out = run(`sf data query --query "${soql}" --target-org ${TARGET_ORG} --result-format json`);
  const data = JSON.parse(out);
  return (data && data.result && data.result.records) || [];
}

function ensureDir(p) {
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

// 1) Fetch candidate human users
const users = queryJson(
  "SELECT Id, Name, Profile.Name, UserType, IsActive FROM User WHERE IsActive = true AND Profile.Name IN ('System Administrator','Sales User','Standard User') AND (UserType = 'Standard' OR UserType = 'CSPLitePortal') ORDER BY Name"
).filter(u => {
  const name = (u.Name || '').toLowerCase();
  return !name.includes('integration') && !name.includes('bot') && !name.includes('api');
});

if (!users.length) {
  console.error('No candidate users found.');
  process.exit(1);
}

const userIds = users.map(u => u.Id);

// 2) Fetch all non-converted leads
const leads = queryJson("SELECT Id, OwnerId FROM Lead WHERE IsConverted = false ORDER BY CreatedDate DESC");
if (!leads.length) {
  console.log('No leads to rebalance.');
  process.exit(0);
}

// 3) Seed order by current load (least first)
const ownerCounts = new Map();
for (const u of users) ownerCounts.set(u.Id, 0);
for (const l of leads) {
  if (ownerCounts.has(l.OwnerId)) ownerCounts.set(l.OwnerId, ownerCounts.get(l.OwnerId) + 1);
}
const sortedUsers = [...users].sort((a, b) => (ownerCounts.get(a.Id) || 0) - (ownerCounts.get(b.Id) || 0));
const assignmentOrder = sortedUsers.map(u => u.Id);

// 4) Round-robin assign
let idx = 0;
const rows = [['Id', 'OwnerId']];
for (const l of leads) {
  const ownerId = assignmentOrder[idx % assignmentOrder.length];
  idx++;
  rows.push([l.Id, ownerId]);
}

// 5) Write CSV
ensureDir(OUTPUT_DIR);
const csv = rows.map(r => r.join(',')).join('\n');
fs.writeFileSync(CSV_PATH, csv);
console.log(`✅ Wrote mapping CSV: ${CSV_PATH} with ${rows.length - 1} rows`);

// 6) Bulk update
console.log('🚀 Updating Lead owners via Bulk API 2.0...');
const res = run(`sf data update bulk --file ${CSV_PATH} --sobject Lead --wait 10 --line-ending LF --target-org ${TARGET_ORG}`);
console.log(res);

// 7) Verify distribution
const verify = run(`sf data query --query "SELECT Owner.Name, OwnerId, COUNT(Id) FROM Lead WHERE IsConverted = false GROUP BY Owner.Name, OwnerId ORDER BY COUNT(Id) DESC" --target-org ${TARGET_ORG} --result-format csv`);
console.log(verify);



