# Data Pipeline Makefile
# Provides convenient shortcuts for common operations

.PHONY: help install test run dry-run list-reports list-projects status clean run-tableau-data-pipeline

# Default target
help:
	@echo "Data Pipeline - Salesforce to Tableau"
	@echo ""
	@echo "Available commands:"
	@echo "  make install                    - Install dependencies"
	@echo "  make run                        - Run full pipeline (weekly_opportunities.yaml)"
	@echo "  make run-tableau-data-pipeline  - Run all three reports (Opportunities, Deal Contribution, Activity)"
	@echo "  make dry-run                    - Validate config without executing (weekly_opportunities.yaml)"
	@echo "  make list-reports               - List Salesforce reports"
	@echo "  make list-projects              - List Tableau projects"
	@echo "  make status                     - Show last pipeline run status"
	@echo "  make test                       - Run basic validation"
	@echo "  make clean                      - Clean up generated files"
	@echo ""
	@echo "Custom config:"
	@echo "  make run CONFIG=path/to/config.yaml"

# Install dependencies
install:
	@echo "Installing dependencies..."
	pip install -r requirements.txt

# Run pipeline with sample config
run:
	@echo "Ensuring venv and dependencies..."
	@test -x .venv/bin/python || (python3 -m venv .venv && .venv/bin/python -m pip install -r requirements.txt)
	@echo "Preparing Salesforce credentials (prefer sf CLI, fallback to .env)..."
	@# Prefer .env first
	@set -a; [ -f .env ] && . ./.env; set +a; \
	if [ -n "$$SF_ACCESS_TOKEN" ] && [ -n "$$SF_INSTANCE_URL" ]; then \
	  echo "Using .env access token creds: $$SF_INSTANCE_URL"; \
	elif [ -n "$$SF_USERNAME" ] && [ -n "$$SF_PASSWORD" ] && [ -n "$$SF_SECURITY_TOKEN" ]; then \
	  echo "Using .env username/password creds for Salesforce"; \
	else \
	  # Fall back to sf CLI if .env not set
	  SF_RAW=$$(sf org display --json 2>/dev/null || true); \
	  SF_JSON=$$(printf "%s" "$$SF_RAW" | python3 -c 'import sys; s=sys.stdin.read(); i=s.find("{"); print(s[i:] if i!=-1 else "")'); \
	  if [ -n "$$SF_JSON" ] && echo "$$SF_JSON" | jq -e '.result | has("accessToken") and has("instanceUrl")' >/dev/null 2>/dev/null; then \
	    export SF_ACCESS_TOKEN=$$(echo $$SF_JSON | jq -r '.result.accessToken'); \
	    export SF_INSTANCE_URL=$$(echo $$SF_JSON | jq -r '.result.instanceUrl'); \
	    echo "Using sf CLI org: $$SF_INSTANCE_URL"; \
	  else \
	    echo "ERROR: No Salesforce credentials found in .env and no sf CLI org detected."; \
	    echo "Fill .env (SF_USERNAME/SF_PASSWORD/SF_SECURITY_TOKEN) or login via 'sf org login'."; \
	    exit 2; \
	  fi; \
	fi; \
	.venv/bin/python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml

# Run with custom config
run-custom:
	@echo "Running pipeline with custom config: $(CONFIG)"
	@test -x .venv/bin/python || (python3 -m venv .venv && .venv/bin/python -m pip install -r requirements.txt)
	@echo "Preparing Salesforce credentials (prefer sf CLI, fallback to .env)..."
	@# Prefer .env first
	@set -a; [ -f .env ] && . ./.env; set +a; \
	if [ -n "$$SF_ACCESS_TOKEN" ] && [ -n "$$SF_INSTANCE_URL" ]; then \
	  echo "Using .env access token creds: $$SF_INSTANCE_URL"; \
	elif [ -n "$$SF_USERNAME" ] && [ -n "$$SF_PASSWORD" ] && [ -n "$$SF_SECURITY_TOKEN" ]; then \
	  echo "Using .env username/password creds for Salesforce"; \
	else \
	  # Fall back to sf CLI if .env not set
	  SF_RAW=$$(sf org display --json 2>/dev/null || true); \
	  SF_JSON=$$(printf "%s" "$$SF_RAW" | python3 -c 'import sys; s=sys.stdin.read(); i=s.find("{"); print(s[i:] if i!=-1 else "")'); \
	  if [ -n "$$SF_JSON" ] && echo "$$SF_JSON" | jq -e '.result | has("accessToken") and has("instanceUrl")' >/dev/null 2>/dev/null; then \
	    export SF_ACCESS_TOKEN=$$(echo $$SF_JSON | jq -r '.result.accessToken'); \
	    export SF_INSTANCE_URL=$$(echo $$SF_JSON | jq -r '.result.instanceUrl'); \
	    echo "Using sf CLI org: $$SF_INSTANCE_URL"; \
	  else \
	    echo "ERROR: No Salesforce credentials found in .env and no sf CLI org detected."; \
	    echo "Fill .env (SF_USERNAME/SF_PASSWORD/SF_SECURITY_TOKEN) or login via 'sf org login'."; \
	    exit 2; \
	  fi; \
	fi; \
	.venv/bin/python -m src.pipeline.cli run --config $(CONFIG)

# Dry run to validate config
dry-run:
	@echo "Validating config (dry run)..."
	@test -x .venv/bin/python || (python3 -m venv .venv && .venv/bin/python -m pip install -r requirements.txt)
	.venv/bin/python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml --dry-run

# List Salesforce reports
list-reports:
	@echo "Listing Salesforce reports..."
	python -m src.pipeline.cli list-reports

# List Tableau projects
list-projects:
	@echo "Listing Tableau projects..."
	python -m src.pipeline.cli list-projects

# Show last run status
status:
	@echo "Pipeline status:"
	@test -x .venv/bin/python || (python3 -m venv .venv && .venv/bin/python -m pip install -r requirements.txt)
	.venv/bin/python -m src.pipeline.cli status

# Basic validation test
test:
	@echo "Running basic validation..."
	python -c "import src.pipeline.salesforce_export, src.pipeline.transformer, src.pipeline.tableau_publish, src.pipeline.cli; print('All modules imported successfully')"

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf data/output/*.csv
	rm -rf data/cache/*
	rm -rf __pycache__/
	rm -rf src/__pycache__/
	rm -rf src/pipeline/__pycache__/
	find . -name "*.pyc" -delete

# Run Tableau data pipeline (all three reports):
run-tableau-data-pipeline:
	@echo "Running Tableau data pipeline for Opportunities..."
	source .venv/bin/activate && export SF_ACCESS_TOKEN=$$(sf org display --json | jq -r '.result.accessToken') && export SF_INSTANCE_URL=$$(sf org display --json | jq -r '.result.instanceUrl') && python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml
	@echo "Running Tableau data pipeline for Deal Contribution..."
	source .venv/bin/activate && export SF_ACCESS_TOKEN=$$(sf org display --json | jq -r '.result.accessToken') && export SF_INSTANCE_URL=$$(sf org display --json | jq -r '.result.instanceUrl') && python -m src.pipeline.cli run --config configs/weekly_deal_contribution.yaml
	@echo "Running Tableau data pipeline for Activity..."
	source .venv/bin/activate && export SF_ACCESS_TOKEN=$$(sf org display --json | jq -r '.result.accessToken') && export SF_INSTANCE_URL=$$(sf org display --json | jq -r '.result.instanceUrl') && python -m src.pipeline.cli run --config configs/weekly_activity.yaml


