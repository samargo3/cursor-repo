#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const TARGET_ORG = process.env.SF_TARGET_ORG || 'agentforce-for-sales-demo-org';
const OUTPUT_DIR = path.join(__dirname, '..', 'data');
const TASKS_CSV = path.join(OUTPUT_DIR, 'opportunity-tasks.csv');
const EVENTS_CSV = path.join(OUTPUT_DIR, 'opportunity-events.csv');

// Utility: random helpers
function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomChoice(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function daysAgoDate(days) {
  const d = new Date();
  d.setDate(d.getDate() - days);
  return d;
}

function daysFromNowDate(days) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d;
}

function formatDateOnly(date) {
  // yyyy-mm-dd for Task.ActivityDate
  const yyyy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

function formatDateTime(date) {
  // ISO-like without timezone for Event Start/End (CLI accepts ISO)
  return date.toISOString();
}

// Content libraries
const taskSubjects = [
  'Call: qualification discussion',
  'Call: budget and timeline',
  'Email: send product deck',
  'Email: proposal follow-up',
  'Note: discovery insights',
  'Log: stakeholder mapping',
  'Call: technical deep-dive',
  'Email: pricing/discounts thread',
  'Task: confirm decision process',
  'Task: confirm legal/security review'
];

const taskTypes = [
  'Call',
  'Email',
  'Call',
  'Email',
  'Other'
];

const taskDescriptions = [
  'Discussed pain points and success criteria.',
  'Aligned on evaluation timeline and key milestones.',
  'Shared deck and case studies relevant to their industry.',
  'Reviewed proposal details and procurement steps.',
  'Captured notes from discovery call with project team.',
  'Identified champions and potential blockers.',
  'Deep dive into technical requirements and integrations.',
  'Negotiated pricing bands and discount approvals.',
  'Validated decision makers and approval chain.',
  'Coordinated security, legal, and compliance review.'
];

const eventSubjects = [
  'Discovery call',
  'Demo with stakeholders',
  'Technical workshop',
  'Proposal review',
  'Negotiation meeting',
  'Executive alignment call'
];

const eventDescriptions = [
  'Live session to confirm requirements and scope.',
  'Walkthrough of product capabilities with the buying team.',
  'Hands-on workshop to validate integration approach.',
  'Review final proposal and address open questions.',
  'Discuss terms, pricing, and close plan.',
  'Align executives on business case and rollout.'
];

function runQuery(soql) {
  const cmd = `sf data query --query "${soql}" --target-org ${TARGET_ORG} --result-format json`;
  const out = execSync(cmd, { stdio: 'pipe', encoding: 'utf8', cwd: path.join(__dirname, '..') });
  return JSON.parse(out);
}

function ensureOutputDir() {
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }
}

function csvEscape(value) {
  if (value === null || value === undefined) return '';
  const str = String(value);
  if (str.includes(',') || str.includes('"') || str.includes('\n')) {
    return '"' + str.replace(/"/g, '""') + '"';
  }
  return str;
}

function buildTaskRows(opportunities) {
  // Header fields for Task insert
  const rows = [
    [
      'Subject',
      'Status',
      'Priority',
      'ActivityDate',
      'Description',
      'OwnerId',
      'WhatId',
      'Type'
    ].join(',')
  ];

  for (const opp of opportunities) {
    const whatId = opp.Id;
    const ownerId = opp.OwnerId;

    // Generate 1-3 historical completed tasks within last 45 days
    const numCompleted = randomInt(1, 3);
    for (let i = 0; i < numCompleted; i++) {
      const subject = randomChoice(taskSubjects);
      const type = randomChoice(taskTypes);
      const description = randomChoice(taskDescriptions);
      const daysAgo = randomInt(5, 45);
      const when = formatDateOnly(daysAgoDate(daysAgo));
      const line = [
        csvEscape(subject),
        'Completed',
        'Normal',
        when,
        csvEscape(description),
        csvEscape(ownerId),
        csvEscape(whatId),
        csvEscape(type)
      ].join(',');
      rows.push(line);
    }

    // Optionally add 0-1 open next-step task due in the next 14 days
    if (Math.random() < 0.7) {
      const subject = 'Next step: ' + randomChoice(eventSubjects);
      const description = 'Planned follow-up aligned to stage progression.';
      const dueIn = randomInt(3, 14);
      const when = formatDateOnly(daysFromNowDate(dueIn));
      const line = [
        csvEscape(subject),
        'Not Started',
        'Normal',
        when,
        csvEscape(description),
        csvEscape(ownerId),
        csvEscape(whatId),
        csvEscape('Task')
      ].join(',');
      rows.push(line);
    }
  }

  return rows;
}

function buildEventRows(opportunities) {
  // Header fields for Event insert
  const rows = [
    [
      'Subject',
      'StartDateTime',
      'EndDateTime',
      'Description',
      'OwnerId',
      'WhatId',
      'IsAllDayEvent',
      'ShowAs'
    ].join(',')
  ];

  for (const opp of opportunities) {
    const whatId = opp.Id;
    const ownerId = opp.OwnerId;

    // 0-1 upcoming meeting in the next 7-21 days
    if (Math.random() < 0.6) {
      const subject = randomChoice(eventSubjects);
      const description = randomChoice(eventDescriptions);
      const startInDays = randomInt(7, 21);
      const start = daysFromNowDate(startInDays);
      const end = new Date(start.getTime() + 60 * 60 * 1000); // +1 hour
      const line = [
        csvEscape(subject),
        csvEscape(formatDateTime(start)),
        csvEscape(formatDateTime(end)),
        csvEscape(description),
        csvEscape(ownerId),
        csvEscape(whatId),
        'false',
        'Busy'
      ].join(',');
      rows.push(line);
    }
  }

  return rows;
}

(async () => {
  console.log('🔎 Fetching target Opportunities (no or stale activity)...');
  const soql = `SELECT Id, Name, StageName, CloseDate, OwnerId, LastActivityDate FROM Opportunity WHERE IsClosed = false AND (LastActivityDate = NULL OR LastActivityDate < LAST_N_DAYS:30)`;
  const result = runQuery(soql);
  const records = result && result.result && result.result.records ? result.result.records : [];
  console.log(`📈 Found ${records.length} target opportunities`);

  if (!records.length) {
    console.log('✅ No opportunities require activity generation.');
    process.exit(0);
  }

  ensureOutputDir();

  console.log('🧮 Generating Tasks and Events...');
  const taskRows = buildTaskRows(records);
  const eventRows = buildEventRows(records);

  fs.writeFileSync(TASKS_CSV, taskRows.join('\n'));
  fs.writeFileSync(EVENTS_CSV, eventRows.join('\n'));

  const numTasks = taskRows.length - 1;
  const numEvents = eventRows.length - 1;
  console.log(`✅ Wrote ${numTasks} Tasks to data/${path.basename(TASKS_CSV)}`);
  console.log(`✅ Wrote ${numEvents} Events to data/${path.basename(EVENTS_CSV)}`);

  console.log('\n📋 Import instructions:');
  console.log(`sfdx force:data:bulk:insert --sobjecttype Task --csvfile ${TASKS_CSV} --target-org ${TARGET_ORG}`);
  console.log(`sfdx force:data:bulk:insert --sobjecttype Event --csvfile ${EVENTS_CSV} --target-org ${TARGET_ORG}`);
})();


