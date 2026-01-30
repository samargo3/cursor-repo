# Lead Generation & Deployment Guide

This guide will help you generate 1000 realistic leads and deploy them to your Salesforce org for Einstein Lead Scoring.

## 🚀 Quick Start

### Prerequisites
1. **Salesforce CLI installed**
   ```bash
   npm install -g @salesforce/cli
   ```

2. **Authenticated to your Salesforce org**
   ```bash
   sfdx force:auth:web:login -a YourOrgAlias
   ```

3. **Node.js installed** (for running the generation script)

### Step 1: Generate Leads
```bash
npm run generate:leads
```
This creates `data/leads.csv` with 1000 realistic leads.

### Step 2: Deploy to Salesforce
```bash
npm run deploy:leads
```
This will import the leads using the best available method.

### Step 3: Complete Setup (One Command)
```bash
npm run setup:einstein
```
This runs both generation and deployment in sequence.

## 📊 Generated Data Overview

The script generates leads with:

- **1000 unique leads** across diverse industries
- **70+ different company names** from various sectors
- **20 different industries** (Technology, Healthcare, Financial Services, etc.)
- **20 different lead sources** (Web, LinkedIn, Trade Shows, etc.)
- **10 different statuses** (New, Qualified, Working, etc.)
- **50 US states** represented
- **Realistic contact information** with proper email formats
- **Company sizes and revenue ranges** for scoring
- **Lead scores** (0-100) for immediate testing

## 🔧 Customization Options

### Modify Lead Count
Edit `scripts/generate-leads.js`:
```javascript
const NUM_LEADS = 2000; // Change to desired number
```

### Add Custom Fields
If your org has custom lead fields:

1. **Add to generation script** (`scripts/generate-leads.js`):
   ```javascript
   return {
     // ... existing fields
     Custom_Field__c: 'Custom Value',
   };
   ```

2. **Update CSV header** in the same file
3. **Update import plan** in `scripts/deploy-leads.js`

### Industry-Specific Data
Modify the data arrays in `scripts/generate-leads.js`:
- `companies` - Target specific company types
- `industries` - Focus on your market
- `leadSources` - Match your marketing channels

## 🛠️ Deployment Methods

The deployment script tries multiple methods:

1. **SFDX Data Import API** (preferred)
2. **Bulk API** (fallback)
3. **Custom Apex Script** (manual fallback)

## 📈 Einstein Lead Scoring Setup

After importing leads:

1. **Enable Einstein Lead Scoring**
   - Go to Setup → Einstein Lead Scoring
   - Follow the setup wizard
   - Ensure you have the required permissions

2. **Wait for Processing**
   - Einstein typically takes 24-48 hours to process new data
   - Monitor the Einstein Lead Scoring dashboard

3. **Verify Data**
   - Check that leads were imported successfully
   - Verify custom fields are populated
   - Monitor lead scores as they're calculated

## 🔍 Troubleshooting

### Common Issues

**"SFDX CLI not found"**
```bash
npm install -g @salesforce/cli
```

**"Not connected to a Salesforce org"**
```bash
sfdx force:auth:web:login -a YourOrgAlias
```

**Import fails with field errors**
- Check that custom fields exist in your org
- Verify field types match (text, number, etc.)
- Ensure required fields are populated

**Bulk API limits exceeded**
- The script will automatically retry with smaller batches
- Consider running imports during off-peak hours

### Manual Import Alternative

If automated import fails:

1. Download the generated `data/leads.csv`
2. Go to Setup → Data Import Wizard
3. Select "Leads" as the object
4. Upload the CSV file
5. Map fields and import

## 📋 Field Mapping

The generated CSV includes these fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| FirstName | Text | No | Contact first name |
| LastName | Text | Yes | Contact last name |
| Company | Text | Yes | Company name |
| Email | Email | No | Contact email |
| Phone | Phone | No | Contact phone |
| Industry | Picklist | No | Industry classification |
| LeadSource | Picklist | No | How lead was acquired |
| Status | Picklist | No | Current lead status |
| Title | Text | No | Job title |
| State | Text | No | State/Province |
| City | Text | No | City |
| Country | Text | No | Country |
| Company_Size__c | Text | No | Company size range |
| AnnualRevenue | Text | No | Annual revenue range |
| NumberOfEmployees | Number | No | Employee count |
| Lead_Score__c | Number | No | Lead score (0-100) |
| Description | Text | No | Lead description |

## 🎯 Best Practices

### For Einstein Lead Scoring

1. **Ensure Data Quality**
   - All required fields are populated
   - Email addresses are valid format
   - Company names are realistic

2. **Diverse Data**
   - Mix of industries and company sizes
   - Various lead sources and statuses
   - Geographic distribution

3. **Realistic Scoring**
   - Lead scores range from 0-100
   - Distribution across different score ranges
   - Correlation with other fields

### For Production Use

1. **Test in Sandbox First**
   - Always test in a sandbox environment
   - Verify field mappings
   - Check data quality

2. **Monitor Performance**
   - Watch for API limits
   - Monitor import success rates
   - Track Einstein processing time

3. **Data Privacy**
   - Generated data is fictional
   - Safe for demo purposes
   - No real personal information

## 📞 Support

For issues with:
- **Script execution**: Check Node.js and SFDX installation
- **Data import**: Verify org permissions and field mappings
- **Einstein scoring**: Contact Salesforce support

## 📈 Performance Notes

- **Generation**: ~1-2 seconds for 1000 leads
- **Deployment**: 2-5 minutes depending on method
- **Einstein Processing**: 24-48 hours for scoring

## 🎉 Success Metrics

After successful deployment, you should see:

- ✅ 1000 leads imported to your org
- ✅ Diverse data across industries and geographies
- ✅ Realistic contact information
- ✅ Lead scores populated (0-100)
- ✅ Einstein Lead Scoring enabled and processing

Your Einstein Lead Scoring will now have sufficient data to work at its fullest potential! 