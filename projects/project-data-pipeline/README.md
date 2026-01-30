# Salesforce → Tableau Data Pipeline

![Python](https://img.shields.io/badge/Python-3.9%2B-blue)
![Salesforce CLI](https://img.shields.io/badge/Salesforce%20CLI-required-00A1E0)
![Platform](https://img.shields.io/badge/Platform-macOS-informational)
![Docs](https://img.shields.io/badge/Docs-available-brightgreen)

Automated weekly export of a Salesforce report with transformations, ID→Name resolution, and a master CSV tailored for Tableau Desktop refresh.


## Why this project
- Manual Salesforce exports are slow, error-prone, and inconsistent across users.
- The Analytics API often returns internal IDs; this pipeline resolves them to readable names.
- Produces a master CSV with a stable schema that mirrors manual exports for seamless Tableau Desktop refresh.

## What this does
- Exports multiple Salesforce reports (Opportunities, Deal Contribution, Activity)
- Resolves internal IDs (Opportunity, Account, User, Contact) to human-readable names
- Normalizes currency fields and types
- Cleans HTML content from text fields
- Enforces column names and order to mirror manual Salesforce export
- Appends to master CSVs with deduplication (or resets to a clean baseline)
- Optional weekly scheduling via macOS launchd

## Project structure
```
project-data-pipeline/
  configs/
    weekly_opportunities.yaml          # Weekly Opportunities pipeline config
    weekly_deal_contribution.yaml      # Weekly Deal Contribution pipeline config
    weekly_activity.yaml               # Weekly Activity pipeline config

  data/
    output/
      history/                         # Daily snapshots (date-stamped)
      opportunities_weekly_master.csv  # Master CSV for Tableau (Opportunities)
      deal_contribution_master.csv     # Master CSV for Tableau (Deal Contribution)
      activity_master.csv              # Master CSV for Tableau (Activity)

  src/
    pipeline/
      cli.py                      # Entry point (run pipeline)
      salesforce_export.py        # Salesforce export via Analytics API
      transformer.py              # YAML-driven transforms + ID resolution
      validate.py                 # Schema/value validator

  docs/
    SALESFORCE_TO_TABLEAU_PIPELINE.md
    TECHNICAL_IMPLEMENTATION.md
    EXECUTIVE_SUMMARY.md
    QUICK_START_GUIDE.md

  Makefile                        # Common commands
  requirements.txt
  README.md
  archive/                        # Non-essential/example files moved here
  logs/                           # (optional) runtime logs
```

## Getting started

1) Setup environment
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2) Salesforce auth (via Salesforce CLI)
```bash
sf org login web --alias your-org --set-default --instance-url https://login.salesforce.com
export SF_ACCESS_TOKEN=$(sf org display --json | jq -r '.result.accessToken')
export SF_INSTANCE_URL=$(sf org display --json | jq -r '.result.instanceUrl')
```

3) Configure the pipeline
- Open `configs/weekly_opportunities.yaml`
- Set `report_id` to your Salesforce report (e.g., `00O...`)
- Review/adjust the transform steps (ID resolution, renames, dtypes)

4) Run the pipeline
```bash
# Opportunities
python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml

# Deal Contribution
python -m src.pipeline.cli run --config configs/weekly_deal_contribution.yaml

# Activity
python -m src.pipeline.cli run --config configs/weekly_activity.yaml
```
Outputs will be written to `data/output/history/`. Masters:
- Opportunities → `data/output/opportunities_weekly_master.csv`
- Deal Contribution → `data/output/deal_contribution_master.csv`
- Activity → `data/output/activity_master.csv`

## Common commands (Makefile)
```bash
make install        # Install dependencies
make run            # Run sample pipeline
make dry-run        # Load sample config and print plan (no changes)
make weekly         # Schedule weekly run for ALL THREE reports
make clean          # Clean generated outputs (safe)

# Direct runs
python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml
python -m src.pipeline.cli run --config configs/weekly_deal_contribution.yaml
python -m src.pipeline.cli run --config configs/weekly_activity.yaml
```

## Validating output vs a manual Salesforce export
If you have a reference CSV (manual export), validate schema/values:
```bash
python -m src.pipeline.validate \
  --sample "/Users/<you>/Documents/Data Sets/Inspection Report Export - Cur Quarter - 09.17.2025.csv" \
  --file data/output/opportunities_weekly_master.csv \
  --key "Opportunity ID" --strict
```

Deal Contribution validation:
```bash
python -m src.pipeline.validate \
  --sample "/Users/<you>/Documents/Data Sets/Deal Contribution Export.csv" \
  --file data/output/deal_contribution_master.csv \
  --key "Deal Contribution: ID" --strict
```

## Notes
- The master CSV schema is locked to match manual exports (column names and order).
- ID→Name resolution uses SOQL in batches for Opportunity, Account, and User IDs.
- Currency fields are parsed from Salesforce's OrderedDict format and cast to floats.

## Documentation
- See `docs/SALESFORCE_TO_TABLEAU_PIPELINE.md` for a solution overview
- See `docs/QUICK_START_GUIDE.md` to replicate
- See `docs/TECHNICAL_IMPLEMENTATION.md` for deep technical details
- See `docs/EXECUTIVE_SUMMARY.md` for leadership-facing summary
- See `docs/REPLICATE_WITH_CURSOR_AI.md` for copy-paste prompts to recreate this with a Cursor AI agent