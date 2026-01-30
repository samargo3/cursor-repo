# Quick Start Guide
## Salesforce to Tableau Pipeline - 30 Minute Setup

### 🎯 What You'll Build
An automated pipeline that exports Salesforce reports, resolves IDs to names, and creates a master CSV file for Tableau Desktop refresh.

---

## ⚡ 30-Minute Setup

### Step 1: Environment Setup (5 minutes)

```bash
# 1. Navigate to your project directory
cd /path/to/your/project

# 2. Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt
```

### Step 2: Salesforce Authentication (5 minutes)

```bash
# 1. Login to Salesforce CLI
sf org login web --alias your-org --set-default --instance-url https://login.salesforce.com

# 2. Set environment variables
export SF_ACCESS_TOKEN=$(sf org display --json | jq -r '.result.accessToken')
export SF_INSTANCE_URL=$(sf org display --json | jq -r '.result.instanceUrl')

# 3. Test connection
python3 -c "from src.pipeline.salesforce_export import SalesforceExporter; SalesforceExporter()"
```

### Step 3: Find Your Report ID (5 minutes)

```bash
# Option 1: List all reports
make list-reports

# Option 2: Search for specific report
sf data query --query "SELECT Id, Name FROM Report WHERE Name LIKE '%Opportunities%'"

# Option 3: Get report ID from Salesforce URL
# https://yourorg.lightning.force.com/lightning/r/Report/00OXXXXXXXXXXXX/view
# Report ID is: 00OXXXXXXXXXXXX
```

### Step 4: Configure Pipeline (10 minutes)

Create `configs/my_report.yaml`:

```yaml
# Basic configuration for any Salesforce report
reports:
  - name: "My Report"
    report_id: "00OXXXXXXXXXXXX"  # Your report ID here
    output: "data/output/history/my_report_{date}.csv"

transforms:
  - input: "data/output/history/my_report_{date}.csv"
    output: "data/output/history/my_report_{date}.csv"
    steps:
      # Add snapshot date
      - type: add_constant_column
        name: snapshot_date
        value: {date}
      
      # Resolve IDs to names (adjust column names for your report)
      - type: resolve_ids_to_names
        mappings:
          - column: "Opportunity.Name"
            object_type: "Opportunity"
            name_field: "Name"
          - column: "Account.Name"
            object_type: "Account"
            name_field: "Name"
          - column: "User.Name"
            object_type: "User"
            name_field: "Name"
      
      # Rename columns to match your needs
      - type: rename_columns
        mapping:
          "Opportunity.Id": "Opportunity ID"
          "Opportunity.Name": "Opportunity Name"
          "Account.Name": "Account Name"
          "User.Name": "Owner Name"
      
      # Extract currency if needed
      - type: extract_currency
        column: "Opportunity.Amount"
        output_column: "amount_numeric"
      
      # Data quality checks
      - type: data_quality_check
        checks:
          - name: "Row Count Check"
            type: row_count_check
            min_rows: 1
            max_rows: 10000

# Append to master file
postprocess:
  append:
    - source: "data/output/history/my_report_{date}.csv"
      master: "data/output/my_report_master.csv"
      dedupe:
        key: "Opportunity ID"  # Adjust for your primary key
        keep: latest

# Disable Tableau publishing for now
publish:
  enabled: false
```

### Step 5: Test the Pipeline (3 minutes)

```bash
# 1. Dry run to test configuration
make dry-run --config configs/my_report.yaml

# 2. Run the pipeline
make run --config configs/my_report.yaml

# 3. Check the output
ls -la data/output/
head -5 data/output/my_report_master.csv
```

### Step 6: Schedule Automation (2 minutes)

```bash
# Schedule weekly runs (Mondays at 6am) for BOTH reports
make weekly

# Verify schedule is created
launchctl list | grep salesforce
```

---

## 🔧 Common Configurations

### For Opportunity Reports
```yaml
transforms:
  - input: "data/output/history/opportunities_{date}.csv"
    output: "data/output/history/opportunities_{date}.csv"
    steps:
      - type: resolve_ids_to_names
        mappings:
          - column: "Opportunity.Name"
            object_type: "Opportunity"
            name_field: "Name"
          - column: "Account.Name"
            object_type: "Account"
            name_field: "Name"
          - column: "Opportunity.Owner.Name"
            object_type: "User"
            name_field: "Name"
      - type: extract_currency
        column: "Opportunity.Amount"
        output_column: "amount_numeric"
      - type: derive_column
        name: "is_large_deal"
        expr: "amount_numeric > 50000"
```

### For Account Reports
```yaml
transforms:
  - input: "data/output/history/accounts_{date}.csv"
    output: "data/output/history/accounts_{date}.csv"
    steps:
      - type: resolve_ids_to_names
        mappings:
          - column: "Account.Name"
            object_type: "Account"
            name_field: "Name"
          - column: "Account.Owner.Name"
            object_type: "User"
            name_field: "Name"
      - type: cast_dtypes
        dtypes:
          "Annual Revenue": "float64"
          "Created Date": "datetime64[ns]"
```

### For Custom Objects
### For Deal Contribution Reports
```yaml
reports:
  - name: "Argo - Weekly Export - Deal Contribution"
    report_id: "00Oed000005aqGXEAY"
    output: "data/output/history/deal_contribution_{date}.csv"

transforms:
  - input: "data/output/history/deal_contribution_{date}.csv"
    output: "data/output/history/deal_contribution_{date}.csv"
    steps:
      - type: add_constant_column
        name: snapshot_date
        value: {date}
      - type: extract_currency
        column: "Deal_Contribution__c.Split_Amount__c"
        output_column: "split_amount_numeric"
      - type: extract_currency
        column: "Deal_Contribution__c.Opportunity_Amount__c"
        output_column: "opp_amount_numeric"
      - type: extract_currency
        column: "Deal_Contribution__c.Opportunity_Amount__c.CONVERT"
        output_column: "opp_amount_conv_numeric"
      - type: extract_currency_code
        column: "Deal_Contribution__c.Split_Amount__c"
        output_column: "Split Amount Currency"
      - type: extract_currency_code
        column: "Deal_Contribution__c.Opportunity_Amount__c"
        output_column: "Opportunity Amount Currency"
      - type: extract_currency_code
        column: "Deal_Contribution__c.Opportunity_Amount__c.CONVERT"
        output_column: "Opportunity Amount (converted) Currency"
      - type: rename_columns
        mapping:
          CUST_ID: "Deal Contribution: ID"
          Deal_Contribution__c.SE_Name__c: Contributor
          CDF1: "Weighted Value"
          FK_OPP_ID: "Opportunity: Opportunity ID"
          FK_NAME: "Opportunity: Opportunity Name"
          FK_ACC_NAME: "Opportunity: Account Name"
          FK_OPP_OWNER_NAME: "Opportunity: Opportunity Owner"
          split_amount_numeric: "Split Amount"
          opp_amount_numeric: "Opportunity Amount"
          opp_amount_conv_numeric: "Opportunity Amount (converted)"
          Deal_Contribution__c.Split_Percentage__c: "Split Percentage"
          BucketField_5981375: "Opp Status"
          FK_OPP_STAGE_NAME: "Opportunity: Stage"
          FK_OPP_ROLLUP_DESCRIPTION: "Opportunity: Owner Role"
          Deal_Contribution__c.Opportunity_Close_Date__c: "Opportunity Close Date"
      - type: select_columns
        columns:
          - "Deal Contribution: ID"
          - "Contributor"
          - "Weighted Value"
          - "Opportunity: Opportunity ID"
          - "Opportunity: Opportunity Name"
          - "Opportunity: Account Name"
          - "Opportunity: Opportunity Owner"
          - "Split Amount Currency"
          - "Split Amount"
          - "Opportunity Amount Currency"
          - "Opportunity Amount"
          - "Opportunity Amount (converted) Currency"
          - "Opportunity Amount (converted)"
          - "Split Percentage"
          - "Opp Status"
          - "Opportunity: Stage"
          - "Opportunity: Owner Role"
          - "Opportunity Close Date"

postprocess:
  append:
    - source: "data/output/history/deal_contribution_{date}.csv"
      master: "data/output/deal_contribution_master.csv"
      dedupe:
        key: "Deal Contribution: ID"
        keep: latest
```
```yaml
transforms:
  - input: "data/output/history/custom_{date}.csv"
    output: "data/output/history/custom_{date}.csv"
    steps:
      - type: resolve_ids_to_names
        mappings:
          - column: "Custom_Object__c.Name"
            object_type: "Custom_Object__c"
            name_field: "Name"
          - column: "Custom_Object__c.Related_Account__c"
            object_type: "Account"
            name_field: "Name"
```

---

## 🚨 Troubleshooting

### Common Issues & Solutions

#### 1. "Resource reports/XXX Not Found"
```bash
# Check if report exists and you have access
sf data query --query "SELECT Id, Name FROM Report WHERE Id = '00OXXXXXXXXXXXX'"
```

#### 2. "Authentication failed"
```bash
# Refresh your Salesforce connection
sf org login web --alias your-org --set-default
export SF_ACCESS_TOKEN=$(sf org display --json | jq -r '.result.accessToken')
```

#### 3. "Column not found in transformation"
```bash
# Check actual column names in your report
head -1 data/output/history/my_report_2025-XX-XX.csv
```

#### 4. "IDs not resolving to names"
```bash
# Verify object type and field names
sf sobject describe --sobject-type Opportunity
```

---

## 📊 Available Commands

```bash
# Pipeline operations
make run                    # Run the pipeline
make dry-run               # Test configuration without running
make clean                 # Clean output files
make weekly                # Schedule weekly automation

# Salesforce operations  
make list-reports          # List available reports
make list-projects         # List Tableau projects

# Development
make install               # Install dependencies
make test                  # Run tests
```

---

## 🎯 Next Steps

### 1. Customize for Your Data
- Adjust column mappings in the config
- Add specific transformations for your use case
- Configure data quality checks

### 2. Connect to Tableau
- Point Tableau Desktop to your master CSV file
- Set up automatic refresh
- Create your dashboards

### 3. Scale to Other Reports
- Create additional config files for other reports
- Schedule multiple pipelines
- Share with your team

### 4. Advanced Features
- Enable Tableau Server publishing
- Add more data quality checks
- Implement custom transformations

---

## 📚 Additional Resources

- **Full Documentation**: `docs/SALESFORCE_TO_TABLEAU_PIPELINE.md`
- **Technical Details**: `docs/TECHNICAL_IMPLEMENTATION.md`
- **Executive Summary**: `docs/EXECUTIVE_SUMMARY.md`
- **Support**: Internal Slack #data-pipeline-support

---

## ✅ Success Checklist

- [ ] Environment setup complete
- [ ] Salesforce authentication working
- [ ] Report ID identified
- [ ] Configuration file created
- [ ] Pipeline runs successfully
- [ ] Master CSV file generated
- [ ] Weekly automation scheduled
- [ ] Tableau connection established

**🎉 Congratulations! You now have an automated Salesforce to Tableau pipeline!**

---

*This quick start guide gets you up and running in 30 minutes. For advanced features and troubleshooting, refer to the comprehensive documentation.*
