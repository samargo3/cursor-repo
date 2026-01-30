# 🎯 Custom Lead Generation Guide

This guide shows you how to quickly generate and deploy bulk, relevant leads based on company and website inputs using a simple, repeatable process.

## ⚡ Quick Start

### Method 1: Interactive Mode (Easiest)
```bash
npm run leads:quick
```
This will prompt you for:
- Company name
- Website
- Industry selection
- Number of leads
- Target Salesforce org

### Method 2: Direct Command
```bash
npm run leads:custom "Your Company" "yourcompany.com" "Technology" 200
```

### Method 3: Pre-built Industry Templates
```bash
# Technology leads
npm run leads:tech

# Healthcare leads
npm run leads:healthcare

# Financial Services leads
npm run leads:finance

# Manufacturing leads
npm run leads:manufacturing

# Retail leads
npm run leads:retail
```

## 🎯 How It Works

### 1. **Input Processing**
- Takes your company name and website
- Generates industry-specific company names
- Creates realistic email addresses using your website domain
- Produces industry-appropriate job titles and lead sources

### 2. **Smart Data Generation**
- **Company Names**: Industry-specific prefixes and suffixes
- **Job Titles**: Relevant to the selected industry
- **Lead Sources**: Industry-appropriate channels
- **Company Metrics**: Realistic employee counts and revenue based on industry
- **Email Addresses**: Uses your website domain for authenticity

### 3. **Automated Deployment**
- Saves leads to timestamped CSV files
- Deploys directly to your Salesforce org
- Provides deployment status and feedback

## 📊 Industry-Specific Features

### Technology
- **Companies**: TechCorp Solutions, Digital Dynamics, AI Innovations
- **Titles**: CTO, Software Engineer, Data Scientist, DevOps Engineer
- **Sources**: LinkedIn, GitHub, Tech Conference, Developer Meetup
- **Metrics**: 10-5,000 employees, $500K-$50M revenue

### Healthcare
- **Companies**: HealthCare Inc, MedTech Solutions, BioCare Systems
- **Titles**: Chief Medical Officer, Physician, Clinical Director
- **Sources**: Medical Conference, Professional Association, Medical Journal
- **Metrics**: 50-10,000 employees, $1M-$100M revenue

### Financial Services
- **Companies**: Finance Pro, Capital Solutions, Investment Corp
- **Titles**: CFO, Financial Analyst, Investment Manager
- **Sources**: Financial Conference, Professional Network, Financial Website
- **Metrics**: 100-20,000 employees, $5M-$500M revenue

### Manufacturing
- **Companies**: Manufacturing Corp, Industrial Solutions, Production Tech
- **Titles**: VP of Operations, Plant Manager, Production Manager
- **Sources**: Trade Show, Industry Conference, Supplier Referral
- **Metrics**: 200-15,000 employees, $2M-$200M revenue

### Retail
- **Companies**: Retail Solutions, Store Systems, E-commerce Pro
- **Titles**: VP of Sales, Store Manager, E-commerce Manager
- **Sources**: E-commerce, Social Media, Retail Conference
- **Metrics**: 20-10,000 employees, $500K-$100M revenue

## 🚀 Usage Examples

### Example 1: Technology Company
```bash
npm run leads:custom "CloudTech Solutions" "cloudtech.com" "Technology" 300
```
**Generates:**
- 300 technology-focused leads
- Companies like "TechCorp Solutions", "Digital Dynamics"
- Job titles like "CTO", "Software Engineer", "Data Scientist"
- Email addresses using "cloudtech.com" domain
- Realistic tech industry metrics

### Example 2: Healthcare Organization
```bash
npm run leads:custom "MedCare Systems" "medcare.com" "Healthcare" 150
```
**Generates:**
- 150 healthcare-focused leads
- Companies like "HealthCare Inc", "MedTech Solutions"
- Job titles like "Chief Medical Officer", "Physician"
- Email addresses using "medcare.com" domain
- Healthcare industry metrics and lead sources

### Example 3: Interactive Mode
```bash
npm run leads:quick
```
**Prompts for:**
```
Enter company name: Acme Corp
Enter website (e.g., company.com): acme.com
Select industry (1-10): 1
Number of leads to generate (default: 100): 250
Target Salesforce org (default: sargo@demo.com): my-demo-org
```

## 📁 Output Files

### CSV Structure
```csv
FirstName,LastName,Company,Email,Phone,Industry,LeadSource,Status,Title,State,City,Country,AnnualRevenue,NumberOfEmployees,Website,Description,CreatedDate,LastActivityDate
John,Smith,TechCorp Solutions,john.smith@acme.com,(555) 123-4567,Technology,LinkedIn,New,CTO,CA,San Francisco,United States,5000000,150,acme.com,Lead for TechCorp Solutions in Technology industry...
```

### File Naming
- Format: `leads-{company}-{timestamp}.csv`
- Example: `leads-acme-corp-1703123456789.csv`
- Location: `data/` directory

## 🔧 Customization Options

### 1. Modify Industry Templates
Edit `scripts/generate-custom-leads.js` to add new industries or modify existing ones:

```javascript
const industryPrefixes = {
    'Your Industry': ['Your', 'Custom', 'Industry', 'Prefixes'],
    // ... existing industries
};
```

### 2. Adjust Company Metrics
Modify revenue and employee ranges:

```javascript
const industryMetrics = {
    'Your Industry': {
        employees: { min: 50, max: 5000 },
        revenue: { min: 1000000, max: 50000000 }
    }
};
```

### 3. Custom Lead Sources
Add industry-specific lead sources:

```javascript
const industrySources = {
    'Your Industry': ['Custom Source 1', 'Custom Source 2', 'Trade Show'],
    // ... existing sources
};
```

## 🎯 Demo Scenarios

### Scenario 1: Technology Demo
```bash
# Generate tech leads
npm run leads:tech

# Or custom tech company
npm run leads:custom "InnovateTech" "innovatetech.com" "Technology" 500
```

### Scenario 2: Healthcare Demo
```bash
# Generate healthcare leads
npm run leads:healthcare

# Or custom healthcare organization
npm run leads:custom "HealthFirst" "healthfirst.org" "Healthcare" 300
```

### Scenario 3: Financial Services Demo
```bash
# Generate finance leads
npm run leads:finance

# Or custom financial institution
npm run leads:custom "CapitalBank" "capitalbank.com" "Financial Services" 400
```

## 🔍 Troubleshooting

### Common Issues

**"Company name is required"**
- Ensure you're providing the company name in quotes if it contains spaces
- Example: `"Acme Corporation"` not `Acme Corporation`

**"Website is required"**
- Provide the website domain without http:// or www.
- Example: `company.com` not `https://www.company.com`

**"Invalid industry selection"**
- Use one of the supported industries:
  - Technology, Healthcare, Financial Services, Manufacturing, Retail
  - Education, Real Estate, Consulting, Legal Services, Government

**"Deployment failed"**
- Check your Salesforce org connection
- Verify org permissions for lead creation
- Ensure the target org exists and is accessible

### Debug Commands
```bash
# Check Salesforce connection
sf org list

# Test org access
sf org display --target-org your-org-alias

# View deployment logs
sf project deploy report --job-id <job-id>
```

## 📈 Best Practices

### 1. **Realistic Company Names**
- Use your actual company name for authenticity
- The script will generate related company names in the same industry

### 2. **Website Domain**
- Use your actual website domain for email generation
- This creates more realistic and believable leads

### 3. **Industry Selection**
- Choose the industry that best matches your target market
- This ensures relevant job titles and company metrics

### 4. **Lead Volume**
- Start with 100-200 leads for testing
- Scale up to 500-1000 for full demos
- Consider org limits and performance

### 5. **Data Quality**
- Review generated CSV files before deployment
- Verify email formats and company names
- Check for any obvious data inconsistencies

## 🚀 Advanced Usage

### Batch Processing
```bash
# Generate leads for multiple companies
npm run leads:custom "TechCorp" "techcorp.com" "Technology" 200
npm run leads:custom "HealthCare" "healthcare.com" "Healthcare" 150
npm run leads:custom "FinancePro" "financepro.com" "Financial Services" 100
```

### Integration with Flows
```bash
# Generate leads and deploy flows
npm run leads:tech && npm run flow:deploy
```

### Complete Demo Setup
```bash
# Full demo environment with custom leads
npm run leads:custom "DemoCorp" "democorp.com" "Technology" 500 && npm run demo:setup
```

## 📞 Support

For issues with:
- **Lead generation**: Check input parameters and industry selection
- **CSV creation**: Verify data directory permissions
- **Salesforce deployment**: Check org connection and permissions
- **Customization**: Review the script structure and modify as needed

Your custom lead generation process is now ready for repeatable, efficient demo creation! 🎉















