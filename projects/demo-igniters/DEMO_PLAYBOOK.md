# Sales Demo Playbook – Lead & Opportunity Realism

This playbook captures repeatable steps to prep an org for demos: identify stale opportunities, generate realistic activities, normalize lead data, and rebalance lead ownership.

Prereqs
- Salesforce CLI installed and authenticated
- Org alias: `agentforce-for-sales-demo-org` (or set `SF_TARGET_ORG`)
- From repo root: `/Users/sargo/Documents/demo-igniters/demo-igniters`

Quick Reference
- Set default alias for commands:
  ```bash
  export SF_TARGET_ORG=agentforce-for-sales-demo-org
  ```

1) Find opportunities lacking activity
- Open, no activity ever:
  ```bash
  sf data query --query "SELECT Id, Name, StageName, Amount, CloseDate, Owner.Name, LastActivityDate FROM Opportunity WHERE IsClosed = false AND LastActivityDate = NULL ORDER BY CloseDate ASC" --target-org ${SF_TARGET_ORG}
  ```
- Open, last activity >30 days:
  ```bash
  sf data query --query "SELECT Id, Name, StageName, Amount, CloseDate, Owner.Name, LastActivityDate FROM Opportunity WHERE IsClosed = false AND LastActivityDate < LAST_N_DAYS:30 ORDER BY LastActivityDate ASC, CloseDate ASC" --target-org ${SF_TARGET_ORG}
  ```

2) Generate realistic opportunity activities (Tasks + Events)
- Create CSVs tied to Opportunities missing/stale activity:
  ```bash
  node scripts/generate-opportunity-activities.js
  ```
- Import into the org:
  ```bash
  sf data import bulk --file data/opportunity-tasks.csv --sobject Task  --wait 10 --line-ending LF --target-org ${SF_TARGET_ORG}
  sf data import bulk --file data/opportunity-events.csv --sobject Event --wait 10 --line-ending LF --target-org ${SF_TARGET_ORG}
  ```
- Verify inserts today:
  ```bash
  sf data query --query "SELECT COUNT() FROM Task  WHERE CreatedDate = TODAY AND WhatId IN (SELECT Id FROM Opportunity WHERE IsClosed = false)" --target-org ${SF_TARGET_ORG}
  sf data query --query "SELECT COUNT() FROM Event WHERE CreatedDate = TODAY AND WhatId IN (SELECT Id FROM Opportunity WHERE IsClosed = false)" --target-org ${SF_TARGET_ORG}
  ```

3) Normalize leads for demo realism
- Run normalization (Apex execute anonymous):
  ```bash
  sf apex run --file scripts/normalize-leads.apex --target-org ${SF_TARGET_ORG}
  ```
- What it does:
  - Standardizes phone format to `(###) ###-####`
  - Lowercases/infers emails where missing
  - Title-cases `Title` and `City`
  - Maps noisy `Industry` / `LeadSource` values to canonical sets
  - Simplifies statuses into `New`, `Working`, `Qualified`, etc.
- Quick QA:
  ```bash
  sf data query --query "SELECT Status, COUNT(Id) FROM Lead GROUP BY Status ORDER BY COUNT(Id) DESC" --target-org ${SF_TARGET_ORG} --result-format csv
  sf data query --query "SELECT LeadSource, COUNT(Id) FROM Lead GROUP BY LeadSource ORDER BY COUNT(Id) DESC" --target-org ${SF_TARGET_ORG} --result-format csv
  sf data query --query "SELECT COUNT() FROM Lead WHERE Phone LIKE '%) %-%'" --target-org ${SF_TARGET_ORG}
  ```

4) Evenly rebalance lead ownership
- Generate CSV and bulk update:
  ```bash
  node scripts/rebalance-leads.js
  ```
- Verify new distribution:
  ```bash
  sf data query --query "SELECT Owner.Name, OwnerId, COUNT(Id) FROM Lead WHERE IsConverted = false GROUP BY Owner.Name, OwnerId ORDER BY COUNT(Id) DESC" --target-org ${SF_TARGET_ORG} --result-format csv
  ```

Notes & Adjustments
- To target a curated seller list only, update `scripts/rebalance-leads.js` user filter or hardcode allowed OwnerIds.
- To exclude helper/bot users from rebalancing, add name/profile filters in `rebalance-leads.js`.
- If your org alias differs, set `export SF_TARGET_ORG=your-alias` before running steps.

Troubleshooting
- CLI warns “update available”: optional; functionality is unaffected.
- If anonymous Apex fails to compile due to custom fields, the normalization script already guards optional fields; ensure you use the latest committed version.
- Bulk jobs timing out: re-run with `--wait 15` or use `--async` + `sf data update resume`.

Screenshots & Walkthrough
- Paste a Loom (or equivalent) link demonstrating the full flow:
  - Loom: <ADD_RECORDING_LINK_HERE>
- Suggested screenshots to drop into `docs/` and reference here:
  - Opportunity list view showing “No Activity Ever” filter
  - Tasks/Events import job complete (Bulk API 2.0 status page)
  - Lead Status distribution (after normalization) – CSV output snippet
  - LeadSource distribution (after normalization) – CSV output snippet
  - Lead ownership distribution (after rebalance) – CSV output snippet
  - Lead record detail showing normalized phone/email/title
  
Example (replace with your image paths):
![No Activity Opportunities](docs/no-activity-opps.png)
![Bulk Import Complete](docs/bulk-import-complete.png)
![Lead Status Distribution](docs/lead-status-distribution.png)
![Lead Source Distribution](docs/lead-source-distribution.png)
![Lead Ownership Even](docs/lead-ownership-even.png)
![Lead Detail Normalized](docs/lead-detail-normalized.png)


