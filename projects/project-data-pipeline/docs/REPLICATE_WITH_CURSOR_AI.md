# Replicating This Pipeline with a Cursor AI Agent

Use these copy-paste prompt templates to have a Cursor AI agent recreate and maintain this Salesforce → Tableau pipeline.

## 1) Project setup
- Create a Python project to automate Salesforce report exports, transform data via YAML, resolve Salesforce IDs to names, and produce a Tableau-ready master CSV. Include a Makefile, `requirements.txt`, and a clear `README.md`.

## 2) Auth via Salesforce CLI
- Set up Salesforce auth using Salesforce CLI (no username/password stored). Use env vars `SF_ACCESS_TOKEN` and `SF_INSTANCE_URL` from `sf org display --json`.

## 3) Implement Salesforce export
- Add `src/pipeline/salesforce_export.py` that calls the Analytics Reports API `analytics/reports/{report_id}?includeDetails=true` to export rows to CSV. Support token-based auth. Log report name and row count.

## 4) YAML-driven transformer
- Add `src/pipeline/transformer.py` that loads CSV and applies transforms from YAML:
  - `rename_columns`
  - `extract_currency` (regex parse OrderedDict amount)
  - `extract_currency_code`
  - `resolve_ids_to_names` (batch SOQL for Opportunity, Account, User)
  - `derive_column`
  - `cast_dtypes`
  - `select_columns` (enforce order)
  - `data_quality_check` (row_count, null_check, value_check, range_check)
  - `coalesce_columns` (e.g., backfill “Amount (converted)” from “Amount”)
  Save output CSV.

## 5) CLI orchestrator
- Create `src/pipeline/cli.py` to:
  - load YAML config
  - export to `data/output/history/opportunities_{date}.csv`
  - apply transforms and overwrite the snapshot
  - postprocess: append to `data/output/opportunities_weekly_master.csv` with dedupe on “Opportunity ID”
  - date templating in paths
  - optional: publish to Tableau

## 6) Weekly config
- Create `configs/weekly_opportunities.yaml`:
  - `reports`: set `report_id` and `output`
  - `steps` (in order): add_constant_column → extract_currency → extract_currency_code → resolve_ids_to_names → rename_columns → derive_column → cast_dtypes → coalesce_columns → select_columns → data_quality_check
  - `postprocess.append` with dedupe on “Opportunity ID”

## 7) Validation utility
- Add `src/pipeline/validate.py` to compare a produced CSV with a manual Salesforce export by schema and values, joining on “Opportunity ID”. Add `--strict` to fail on mismatches.

## 8) Documentation
- Generate docs in `docs/`:
  - `SALESFORCE_TO_TABLEAU_PIPELINE.md` (overview/use-case)
  - `QUICK_START_GUIDE.md` (30-min setup)
  - `TECHNICAL_IMPLEMENTATION.md` (deep dive)
  - `EXECUTIVE_SUMMARY.md` (stakeholder summary)
  - Link them in `README.md` with badges and a “Why this project” section.

## 9) Makefile
- Add targets: `install`, `run`, `dry-run`, `weekly` (launchd), `clean`.

## 10) Weekly schedule
- Create a launchd plist to run `make weekly` every Monday 6am; document load/unload commands.

## 11) Clean baseline & schema lock
- Provide commands to reset the master CSV to the latest snapshot; enforce schema via `select_columns` to prevent drift on future appends.

---

## Example prompts to execute
- Authenticate and run:
```
sf org login web --alias your-org --set-default --instance-url https://login.salesforce.com
export SF_ACCESS_TOKEN=$(sf org display --json | jq -r '.result.accessToken')
export SF_INSTANCE_URL=$(sf org display --json | jq -r '.result.instanceUrl')
make run
```

- Validate output vs manual export:
```
python -m src.pipeline.validate \
  --sample "/Users/<you>/Documents/Data Sets/Inspection Report Export - Cur Quarter - 09.17.2025.csv" \
  --file data/output/opportunities_weekly_master.csv \
  --key "Opportunity ID" --strict
```

- Resolve IDs if Analytics API returns IDs in name fields:
```
Update transforms to include resolve_ids_to_names for Opportunity.Name, Opportunity.Account.Name, Opportunity.Owner.Name, and Account Owner, then rerun and revalidate.
```

## Troubleshooting prompts
- Session expired: refresh `SF_ACCESS_TOKEN` and `SF_INSTANCE_URL` from `sf org display --json`.
- Columns mismatch: adjust `rename_columns`, `select_columns`, `cast_dtypes`, `coalesce_columns` to mirror manual export.
- Values mismatch: run validator in strict mode and show top 3 mismatched columns with examples.

---

## Minimal checklist for replication
- [ ] `requirements.txt`, `Makefile`, `README.md`
- [ ] `src/pipeline/{cli.py,salesforce_export.py,transformer.py,validate.py}`
- [ ] `configs/weekly_opportunities.yaml` and `configs/weekly_deal_contribution.yaml`
- [ ] `data/output/history/`, `data/output/opportunities_weekly_master.csv`, `data/output/deal_contribution_master.csv`
- [ ] Docs in `docs/`

---

## Add second report: Deal Contribution
- Create `configs/weekly_deal_contribution.yaml` using report name "Argo - Weekly Export - Deal Contribution" (ID: 00Oed000005aqGXEAY)
- Implement currency extraction and code parsing for split/opportunity amounts
- Rename columns to match manual export headers (e.g., "Deal Contribution: ID")
- Append to `data/output/deal_contribution_master.csv` with dedupe key "Deal Contribution: ID"
- Update `Makefile` `weekly` target to run both reports
