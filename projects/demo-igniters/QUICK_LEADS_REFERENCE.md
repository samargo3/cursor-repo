# ⚡ Quick Lead Generation Reference

## 🚀 One-Command Process

### Interactive Mode (Easiest)
```bash
npm run leads:quick
```
*Prompts for company, website, industry, and lead count*

### Direct Command
```bash
npm run leads:custom "Company Name" "website.com" "Industry" 200
```

## 📋 Pre-built Templates
```bash
# Technology (200 leads)
npm run leads:tech

# Healthcare (150 leads)
npm run leads:healthcare

# Financial Services (200 leads)
npm run leads:finance

# Manufacturing (150 leads)
npm run leads:manufacturing

# Retail (100 leads)
npm run leads:retail
```

## 🎯 Supported Industries
1. Technology
2. Healthcare
3. Financial Services
4. Manufacturing
5. Retail
6. Education
7. Real Estate
8. Consulting
9. Legal Services
10. Government

## 📊 What Gets Generated

### Company Data
- Industry-specific company names
- Realistic employee counts
- Appropriate revenue ranges
- Geographic distribution

### Contact Data
- Realistic names and titles
- Email addresses using your website domain
- Phone numbers and locations
- Industry-appropriate job titles

### Lead Information
- Industry-specific lead sources
- Realistic status distribution
- Recent creation dates
- Detailed descriptions

## 📁 Output
- **CSV File**: `data/leads-{company}-{timestamp}.csv`
- **Auto-deployment**: Direct to Salesforce org
- **Status**: Real-time feedback and confirmation

## 🔧 Example Usage

### Technology Demo
```bash
npm run leads:custom "CloudTech" "cloudtech.com" "Technology" 300
```

### Healthcare Demo
```bash
npm run leads:custom "MedCare" "medcare.org" "Healthcare" 200
```

### Interactive Demo
```bash
npm run leads:quick
# Enter: "Acme Corp"
# Enter: "acme.com"
# Select: Technology
# Enter: 250
```

## ⚡ Pro Tips
- Use your actual company name for authenticity
- Provide website domain without http:// or www.
- Start with 100-200 leads for testing
- Scale up to 500+ for full demos
- Check generated CSV before deployment















