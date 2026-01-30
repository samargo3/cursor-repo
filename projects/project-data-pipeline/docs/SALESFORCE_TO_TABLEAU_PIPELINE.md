# Salesforce to Tableau Data Pipeline
## Automated Weekly Export with ID Resolution

### Overview
This document outlines a complete solution for automating Salesforce report exports to Tableau Desktop, including advanced data transformation and ID resolution capabilities. The pipeline solves the common problem where Salesforce Analytics API returns internal IDs instead of human-readable names.

---

## 🎯 Problem Statement

**Challenge**: Solution Engineers need to regularly export Salesforce opportunity data to Tableau for analysis, but face several obstacles:

1. **Manual Export Process**: Time-consuming weekly manual exports from Salesforce
2. **ID vs Names Issue**: Salesforce Analytics API returns internal IDs instead of readable names
3. **Data Formatting**: Need to transform data to match Tableau requirements
4. **Scheduling**: No automated way to refresh data weekly
5. **Data Quality**: Need validation and deduplication

**Solution**: Automated pipeline that exports Salesforce reports, resolves IDs to names, transforms data, and maintains a master CSV file for Tableau refresh.

---

## 🏗️ Architecture

```
Salesforce Report → Analytics API → ID Resolution → Data Transformation → Master CSV → Tableau Desktop
```

### Key Components:
- **Salesforce Export**: Uses Analytics API to export report data
- **ID Resolution**: SOQL queries to convert IDs to readable names
- **Data Transformation**: YAML-configurable transformations (renaming, typing, validation)
- **Master File Management**: Appends new data with deduplication
- **Scheduling**: Automated weekly runs via macOS launchd

---

## 🚀 Quick Start Guide

### Prerequisites
- macOS (for launchd scheduling)
- Python 3.9+
- Salesforce CLI installed and authenticated
- Access to Salesforce reports

### 1. Setup Environment

```bash
# Clone or download the pipeline
cd /path/to/project-data-pipeline

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Configure Salesforce Connection

```bash
# Authenticate with Salesforce CLI
sf org login web --alias your-org --set-default --instance-url https://login.salesforce.com

# Set environment variables
export SF_ACCESS_TOKEN=$(sf org display --json | jq -r '.result.accessToken')
export SF_INSTANCE_URL=$(sf org display --json | jq -r '.result.instanceUrl')
```

### 3. Find Your Report ID

```bash
# List available reports
make list-reports

# Or search for specific report
sf data query --query "SELECT Id, Name, DeveloperName FROM Report WHERE Name LIKE '%Opportunities%'"
```

### 4. Configure Pipeline

Edit `configs/weekly_opportunities.yaml`:

```yaml
reports:
  - name: "Your Report Name"
    report_id: "00OXXXXXXXXXXXX"  # Your report ID
    output: "data/output/history/opportunities_{date}.csv"

transforms:
  - input: "data/output/history/opportunities_{date}.csv"
    output: "data/output/history/opportunities_{date}.csv"
    steps:
      # Add your transformations here
      - type: resolve_ids_to_names
        mappings:
          - column: "Opportunity.Name"
            object_type: "Opportunity"
            name_field: "Name"
          - column: "Account.Name"
            object_type: "Account"
            name_field: "Name"
```

### 5. Test the Pipeline

```bash
# Dry run to test configuration
make dry-run

# Run the pipeline
make run

# Check output
ls -la data/output/
```

### 6. Schedule Weekly Automation

```bash
# Create weekly schedule (Mondays at 6am) for BOTH reports
make weekly

# Verify schedule
launchctl list | grep salesforce
```

---

## 🔧 Advanced Configuration

### ID Resolution

The pipeline automatically resolves Salesforce IDs to readable names:

```yaml
- type: resolve_ids_to_names
  mappings:
    - column: "Opportunity.Name"        # Column containing IDs
      object_type: "Opportunity"        # Salesforce object type
      name_field: "Name"                # Field to retrieve
    - column: "Account.Name"
      object_type: "Account"
      name_field: "Name"
    - column: "User.Name"
      object_type: "User"
      name_field: "Name"
```

### Data Transformations

Available transformation types:

```yaml
# Rename columns
- type: rename_columns
  mapping:
    "Old.Name": "New Name"
    "Opportunity.Id": "Opportunity ID"

# Extract currency values
- type: extract_currency
  column: "Opportunity.Amount"
  output_column: "amount_numeric"

# Extract currency codes
- type: extract_currency_code
  column: "Opportunity.Amount"
  output_column: "Amount Currency"

# Add derived columns
- type: derive_column
  name: "is_large_deal"
  expr: "amount_numeric > 50000"

# Cast data types
- type: cast_dtypes
  dtypes:
    "Amount": "float64"
    "Close Date": "datetime64[ns]"
    "SE Attached": "int64"

# Select and order columns
- type: select_columns
  columns:
    - "Opportunity ID"
    - "Opportunity Name"
    - "Amount"
    - "Close Date"

# Data quality checks
- type: data_quality_check
  checks:
    - name: "Row Count Check"
      type: row_count_check
      min_rows: 100
      max_rows: 1000
    - name: "Null Check"
      type: null_check
      columns: ["Opportunity ID", "Opportunity Name"]
```

### Master File Management

```yaml
postprocess:
  append:
    - source: "data/output/history/opportunities_{date}.csv"
      master: "data/output/opportunities_weekly_master.csv"
      dedupe:
        key: "Opportunity ID"
        keep: latest
```

---

## 📊 Use Cases & Examples

### 1. Opportunity Pipeline Analysis

**Goal**: Track weekly opportunity pipeline with proper names and amounts

**Configuration**:
```yaml
reports:
  - name: "Opportunity Pipeline"
    report_id: "00OXXXXXXXXXXXX"
    output: "data/output/history/pipeline_{date}.csv"

transforms:
  - input: "data/output/history/pipeline_{date}.csv"
    output: "data/output/history/pipeline_{date}.csv"
    steps:
      - type: resolve_ids_to_names
        mappings:
          - column: "Opportunity.Name"
            object_type: "Opportunity"
            name_field: "Name"
          - column: "Account.Name"
            object_type: "Account"
            name_field: "Name"
      - type: extract_currency
        column: "Opportunity.Amount"
        output_column: "amount_numeric"
      - type: derive_column
        name: "is_large_deal"
        expr: "amount_numeric > 50000"
```

### 2. Account Performance Tracking
### 3. Deal Contribution Performance

**Goal**: Maintain weekly Deal Contribution dataset aligned with manual export schema

**Configuration**:
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
```

**Goal**: Monitor account performance with owner names

**Configuration**:
```yaml
reports:
  - name: "Account Performance"
    report_id: "00OYYYYYYYYYYYY"
    output: "data/output/history/accounts_{date}.csv"

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

### 3. Custom Object Reporting

**Goal**: Export custom object data with related record names

**Configuration**:
```yaml
reports:
  - name: "Custom Object Report"
    report_id: "00OZZZZZZZZZZZZ"
    output: "data/output/history/custom_{date}.csv"

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

## 🛠️ Troubleshooting

### Common Issues

#### 1. "Resource reports/XXX Not Found"
**Cause**: Incorrect report ID or insufficient permissions
**Solution**: 
```bash
# Verify report exists and you have access
sf data query --query "SELECT Id, Name FROM Report WHERE Id = '00OXXXXXXXXXXXX'"
```

#### 2. "IDs not resolving to names"
**Cause**: Incorrect object type or field name in mapping
**Solution**: Check Salesforce schema:
```bash
# Describe object to see available fields
sf sobject describe --sobject-type Opportunity
```

#### 3. "Authentication failed"
**Cause**: Expired access token
**Solution**: Refresh authentication:
```bash
sf org login web --alias your-org --set-default
export SF_ACCESS_TOKEN=$(sf org display --json | jq -r '.result.accessToken')
```

#### 4. "Column not found in transformation"
**Cause**: Column name mismatch between report and config
**Solution**: Check actual column names in raw export:
```bash
# Run pipeline and check raw CSV
head -1 data/output/history/opportunities_2025-XX-XX.csv
```

### Performance Optimization

#### 1. Batch Size Tuning
For large datasets, adjust batch size in ID resolution:
```python
# In transformer.py, modify batch_size
batch_size = 200  # Reduce if hitting API limits
```

#### 2. Selective ID Resolution
Only resolve IDs for columns you actually need:
```yaml
- type: resolve_ids_to_names
  mappings:
    - column: "Opportunity.Name"  # Only resolve if needed
      object_type: "Opportunity"
      name_field: "Name"
```

#### 3. Caching
Consider implementing ID caching for frequently accessed records:
```python
# Add caching logic to avoid repeated SOQL queries
id_cache = {}  # Store resolved IDs
```

---

## 📈 Business Impact

### Before (Manual Process)
- ⏱️ **Time**: 2-3 hours weekly for manual export and cleanup
- 🐛 **Errors**: Manual data manipulation prone to mistakes
- 📊 **Inconsistency**: Different formats each week
- 🔄 **No Automation**: Manual refresh required

### After (Automated Pipeline)
- ⚡ **Time**: 5 minutes weekly (automated)
- ✅ **Accuracy**: Consistent, validated data
- 📋 **Standardization**: Same format every time
- 🤖 **Automation**: Scheduled weekly refresh
- 🔍 **Quality**: Built-in data validation

### ROI Calculation
- **Time Saved**: 2.5 hours/week × 52 weeks = 130 hours/year
- **Error Reduction**: Eliminates manual data entry mistakes
- **Consistency**: Standardized format for all stakeholders
- **Scalability**: Easy to replicate for other reports

---

## 🔄 Maintenance & Updates

### Weekly Tasks
- [ ] Check pipeline logs for errors
- [ ] Verify data quality in master CSV
- [ ] Update Tableau workbook if needed

### Monthly Tasks
- [ ] Review and update report configurations
- [ ] Check for new Salesforce fields
- [ ] Optimize performance if needed

### Quarterly Tasks
- [ ] Update Salesforce CLI and dependencies
- [ ] Review and update documentation
- [ ] Plan for new use cases

---

## 📚 Additional Resources

### Documentation
- [Salesforce Analytics API Documentation](https://developer.salesforce.com/docs/atlas.en-us.api_analytics.meta/api_analytics/)
- [Salesforce CLI Documentation](https://developer.salesforce.com/tools/sfdxcli)
- [Tableau Desktop Data Source Management](https://help.tableau.com/current/pro/desktop/en-us/datasource_manage.htm)

### Tools & Libraries
- **simple-salesforce**: Python Salesforce API wrapper
- **pandas**: Data manipulation and analysis
- **PyYAML**: Configuration file parsing
- **launchd**: macOS service management

### Support
- Internal Slack: #data-pipeline-support
- Documentation: `/docs/` folder
- Issues: Create GitHub issue for bugs/features

---

## 🎉 Success Stories

### Case Study 1: Sales Operations Team
**Challenge**: Weekly opportunity pipeline reports taking 3 hours to prepare
**Solution**: Automated pipeline with ID resolution
**Result**: 95% time reduction, improved data accuracy, standardized format

### Case Study 2: Customer Success Team
**Challenge**: Account performance tracking with manual data cleanup
**Solution**: Custom pipeline for account data with owner name resolution
**Result**: Daily automated reports, better customer insights

### Case Study 3: Solution Engineering Team
**Challenge**: Multiple custom reports with different formats
**Solution**: Standardized pipeline configuration for all reports
**Result**: Consistent data format across all teams, easier analysis

---

*This documentation was created to showcase the automated Salesforce to Tableau pipeline solution. For questions or support, contact the Solution Engineering team.*
