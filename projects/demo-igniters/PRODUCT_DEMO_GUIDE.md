# Product Demo Setup Guide for SEs

This guide helps Solution Engineers quickly create product catalogs and price book entries for their Salesforce demos.

## 🚀 Quick Start (Recommended)

### 1. Interactive Product Generator
The easiest way to create products for any demo:

```bash
npm run products:quick
```

This interactive script will:
- Show your available orgs
- Let you select a target org
- Choose from industry templates (Technology, Healthcare, Financial Services, etc.)
- Create custom products if needed
- Generate Product2 records and PricebookEntry records automatically

### 2. Template-Based Generation
For specific industries, use predefined templates:

```bash
# Technology company demo
npm run products:tech

# Healthcare demo  
npm run products:healthcare

# Financial Services demo
npm run products:finance

# Manufacturing demo
npm run products:manufacturing

# Retail demo
npm run products:retail

# Distribution demo
npm run products:distribution
```

## 📋 Available Templates

### Technology
- Cloud Platform ($299)
- Data Analytics ($199)
- Security Suite ($399)
- API Integration ($150)
- Consulting ($250)
- Training ($100)

### Healthcare
- Patient Management ($450)
- Electronic Health Records ($600)
- Telemedicine Platform ($350)
- Compliance Consulting ($300)
- Implementation ($200)
- Support & Maintenance ($150)

### Financial Services
- Risk Management ($500)
- Compliance Platform ($400)
- Trading System ($800)
- Audit Services ($350)
- Regulatory Consulting ($400)
- System Integration ($250)

### Manufacturing
- ERP System ($750)
- Quality Control ($300)
- Supply Chain Management ($450)
- Process Optimization ($200)
- Equipment Maintenance ($150)
- Training Programs ($100)

### Retail
- POS System ($200)
- Inventory Management ($150)
- E-commerce Platform ($300)
- Customer Analytics ($180)
- Store Setup ($120)
- Staff Training ($80)

### Distribution
- Import Services ($250)
- Export Solutions ($200)
- Customs Clearance ($150)
- Logistics Management ($300)
- Warehouse Services ($180)
- Supply Chain Solutions ($400)

## 🔧 Advanced Options

### Web Scraping
Extract products from a company website:

```bash
npm run products:scrape -- https://company-website.com/products your-org-alias
```

### Custom Generation
Generate products from a domain name:

```bash
npm run products:generate -- company.com 6 your-org-alias
```

### Manual Creation
Create products with specific details:

```bash
node scripts/generate-products.js company.com 5 your-org-alias
```

## 🎯 Common Demo Scenarios

### 1. New Customer Demo
```bash
# 1. Set up products
npm run products:quick

# 2. Generate leads (optional)
npm run leads:custom -- "Acme Corp" "acme.com" "Technology" 50

# 3. Open org
sf org open --target-org your-org-alias
```

### 2. Industry-Specific Demo
```bash
# Healthcare demo
npm run products:healthcare
npm run leads:healthcare

# Financial Services demo  
npm run products:finance
npm run leads:finance
```

### 3. Custom Company Demo
```bash
# Scrape products from their website
npm run products:scrape -- https://their-website.com your-org-alias

# Generate matching leads
npm run leads:custom -- "Their Company" "their-website.com" "Their Industry" 100
```

## 🛠️ Setup Requirements

### Prerequisites
1. **Salesforce CLI installed**
   ```bash
   npm install -g @salesforce/cli
   ```

2. **Authenticated orgs**
   ```bash
   sf org login web --alias your-org-alias
   ```

3. **Project dependencies**
   ```bash
   npm install
   ```

### Org Setup
- Ensure Standard Price Book is active
- Verify Product2 and PricebookEntry object access
- Check for multi-currency settings if needed

## 📊 Verification Commands

### Check Created Products
```bash
sf data query --query "SELECT Id, Name, ProductCode, Family FROM Product2 ORDER BY CreatedDate DESC LIMIT 10" --target-org your-org-alias
```

### Check Price Book Entries
```bash
sf data query --query "SELECT Id, Pricebook2Id, Product2Id, UnitPrice FROM PricebookEntry ORDER BY CreatedDate DESC LIMIT 10" --target-org your-org-alias
```

### Count Products
```bash
sf data query --query "SELECT COUNT() FROM Product2" --target-org your-org-alias
```

## 🧹 Cleanup

### Remove Products
```bash
# Find products to delete
sf data query --query "SELECT Id, Name FROM Product2 WHERE Name LIKE 'Company%'" --target-org your-org-alias

# Delete specific product
sf data delete record --sobject Product2 --record-id <Id> --target-org your-org-alias
```

### Remove Price Book Entries
```bash
# Find entries to delete
sf data query --query "SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN (SELECT Id FROM Product2 WHERE Name LIKE 'Company%')" --target-org your-org-alias

# Delete specific entry
sf data delete record --sobject PricebookEntry --record-id <Id> --target-org your-org-alias
```

## 🎨 Customization

### Add New Templates
Edit `scripts/quick-products.js` and add to the `getProductTemplates()` function:

```javascript
'Your Industry': [
    { name: 'Product 1', family: 'Software', price: 200 },
    { name: 'Product 2', family: 'Services', price: 150 },
    // ... more products
]
```

### Modify Existing Templates
Update product names, families, or prices in the same function.

### Create Custom Scripts
Add new npm scripts to `package.json`:

```json
"products:your-industry": "node scripts/generate-products.js yourcompany.com 6 your-org-alias"
```

## 🚨 Troubleshooting

### Common Issues

1. **"Standard Price Book not found"**
   - Ensure org has Standard Price Book
   - Check org permissions

2. **"UnitPrice field is required"**
   - Script handles this automatically with fallbacks
   - Check org's multi-currency settings

3. **"No orgs found"**
   - Authenticate first: `sf org login web --alias your-org-alias`
   - List orgs: `sf org list --all`

4. **Permission errors**
   - Verify Product2 and PricebookEntry object access
   - Check field-level security

### Debug Mode
Add `--verbose` to any sf command for detailed output:

```bash
sf data query --query "SELECT Id FROM Product2" --target-org your-org-alias --verbose
```

## 📞 Support

- Check the main [README.md](README.md) for project overview
- Review [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for CLI commands
- Use `npm run` to see all available scripts

## 🎯 Best Practices

1. **Use descriptive org aliases** (`dev`, `demo`, `customer-name`)
2. **Set project defaults** for frequently used orgs
3. **Clean up old products** before creating new ones
4. **Verify products** in the org after creation
5. **Document custom templates** for team reuse
6. **Test in sandbox** before production demos

---

**Quick Reference:**
- `npm run products:quick` - Interactive product creation
- `npm run products:scrape -- <url> <org>` - Scrape from website
- `npm run products:generate -- <domain> <count> <org>` - Generate from domain
- `sf org open --target-org <alias>` - Open org in browser










