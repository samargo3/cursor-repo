#!/bin/bash
# Automated pipeline runner script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Load environment
source .venv/bin/activate

# Get Salesforce tokens
export SF_ACCESS_TOKEN=$(sf org display --json | jq -r '.result.accessToken')
export SF_INSTANCE_URL=$(sf org display --json | jq -r '.result.instanceUrl')

# Run specific pipeline
case "$1" in
    "weekly"|"tableau-data-pipeline")
        echo "$(date): Running Tableau data pipeline for all reports..."
        python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml
        python -m src.pipeline.cli run --config configs/weekly_deal_contribution.yaml
        python -m src.pipeline.cli run --config configs/weekly_activity.yaml
        ;;
    "business_daily")
        echo "$(date): Running business daily pipeline for all reports..."
        python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml
        python -m src.pipeline.cli run --config configs/weekly_deal_contribution.yaml
        python -m src.pipeline.cli run --config configs/weekly_activity.yaml
        ;;
    "daily_all")
        echo "$(date): Running daily pipeline for all reports..."
        python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml
        python -m src.pipeline.cli run --config configs/weekly_deal_contribution.yaml
        python -m src.pipeline.cli run --config configs/weekly_activity.yaml
        ;;
    "opportunities")
        echo "$(date): Running opportunities pipeline..."
        python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml
        ;;
    "deal_contribution")
        echo "$(date): Running deal contribution pipeline..."
        python -m src.pipeline.cli run --config configs/weekly_deal_contribution.yaml
        ;;
    "activity")
        echo "$(date): Running activity pipeline..."
        python -m src.pipeline.cli run --config configs/weekly_activity.yaml
        ;;
    *)
        echo "Usage: $0 {weekly|tableau-data-pipeline|business_daily|daily_all|opportunities|deal_contribution|activity}"
        exit 1
        ;;
esac

echo "$(date): Pipeline run completed"
