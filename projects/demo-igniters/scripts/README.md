# Lead Generation and Deployment Scripts

This directory contains scripts to generate 1000 realistic leads and deploy them to your Salesforce org for Einstein Lead Scoring.

## Prerequisites

1. **Salesforce CLI (SFDX)** installed
   ```bash
   npm install -g @salesforce/cli
   ```

2. **Authenticated to your Salesforce org**
   ```bash
   sfdx force:auth:web:login -a YourOrgAlias
   ```

3. **Node.js** (for running the generation script)

## Quick Start

### 1. Generate Leads
```bash
node scripts/generate-leads.js
```

This will create `data/leads.csv` with 1000 realistic leads including:
- Diverse company names and industries
- Realistic contact information
- Various lead sources and statuses
- Geographic distribution across US states
- Company sizes and revenue ranges
- Lead scores (0-100)

### 2. Deploy to Salesforce
```bash
node scripts/deploy-leads.js
```

This will attempt multiple import methods:
1. SFDX Data Import API
2. Bulk API
3. Custom Apex script (fallback)

## Generated Lead Data

The script generates leads with the following characteristics:

### **Demographics**
- 1000 unique leads
- 60+ different company names
- 20 different industries
- 20 different lead sources
- 10 different statuses
- 50 US states represented
- 50 major cities

### **Fields Included**
- **Required**: LastName, Company
- **Standard**: FirstName, Email, Phone, Industry, LeadSource, Status, Title, State, City, Country, AnnualRevenue, NumberOfEmployees, Description
- **Custom**: Company_Size__c, Lead_Score__c

### **Data Quality**
- Realistic email addresses (company and personal domains)
- Valid phone number formats
- Geographic consistency (city/state pairs)
- Appropriate job titles for industries
- Realistic company sizes and revenue ranges

## Einstein Lead Scoring Setup

After importing the leads:

1. **Enable Einstein Lead Scoring** (if not already enabled)
   - Go to Setup → Einstein Lead Scoring
   - Follow the setup wizard

2. **Wait for Processing**
   - Einstein typically takes 24-48 hours to process new data
   - Monitor the Einstein Lead Scoring dashboard

3. **Verify Data**
   - Check that leads have been imported
   - Verify custom fields are populated
   - Monitor lead scores as they're calculated

## Troubleshooting

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

If automated import fails, you can manually import:

1. Download the generated `data/leads.csv`
2. Go to Setup → Data Import Wizard
3. Select "Leads" as the object
4. Upload the CSV file
5. Map fields and import

## Customization

### Modify Lead Generation

Edit `scripts/generate-leads.js` to:
- Change the number of leads (`NUM_LEADS`)
- Add/remove fields
- Modify data distributions
- Add custom business logic

### Add Custom Fields

If your org has custom lead fields:

1. Add them to the `generateLeadData()` function
2. Update the CSV header in the generation script
3. Update the import plan in `deploy-leads.js`

### Industry-Specific Data

Modify the data arrays to focus on specific industries:
- Update `companies` array for your target market
- Adjust `industries` to match your business
- Customize `leadSources` for your marketing channels

## Data Privacy

The generated data is fictional and safe for demo purposes:
- Names are randomly generated
- Email addresses are fictional
- Phone numbers are not real
- Company names are generic

## Performance Notes

- **Generation**: ~1-2 seconds for 1000 leads
- **Deployment**: 2-5 minutes depending on method
- **Einstein Processing**: 24-48 hours for scoring

## Support

For issues with:
- **Script execution**: Check Node.js and SFDX installation
- **Data import**: Verify org permissions and field mappings
- **Einstein scoring**: Contact Salesforce support 