# Sales Demo Hub - Complete Setup Guide

## 🎯 Overview

The **Sales Demo Hub** is a complete, branded demo experience for Salesforce with a gold theme. It includes:

✅ **Branded Application** with gold (#D4AF37) header color
✅ **Custom KPI Dashboard** showing real-time sales metrics
✅ **Demo Data Seeder** for realistic Accounts, Contacts, and Opportunities
✅ **Permission Set** for controlled access
✅ **NPM Scripts** for easy deployment and data management
✅ **Test Coverage** with comprehensive Apex tests

---

## 📦 What Was Deployed

### Apex Classes
- **DemoDataSeeder.cls** - Seeds and clears demo data
- **DemoKpiService.cls** - Provides KPI data and metrics for dashboard
- **DemoKpiService_Test.cls** - Test coverage for all functionality

### Lightning Web Component
- **demoKpiPanel** - Gold-themed dashboard with:
  - KPI cards (Revenue, Win Rate, Avg Deal Size, Active Accounts)
  - Sales pipeline visualization
  - Recent activity feed
  - Quick actions

### Static Resources
- **demoLogo.svg** - Gold-themed trophy logo for branding

### Metadata
- **Sales_Demo_Hub** app with navigation tabs
- **Demo_KPIs** custom tab
- **Demo_Home** Visualforce page
- **Demo_Permissions** permission set

---

## 🚀 Quick Start

### Access the Demo

1. **Open Sales Demo Hub App**
   ```bash
   sf org open --target-org a4sales-demo-org --path /lightning/app/Sales_Demo_Hub
   ```

2. **Click "Demo KPIs" tab** to view the dashboard

### Current Demo Data

Successfully seeded:
- ✅ **10 Accounts** (across Technology, Healthcare, Financial Services, Manufacturing, Retail)
- ✅ **26 Contacts** (2-3 per account with realistic roles)
- ✅ **17 Opportunities** (various stages from Prospecting to Closed Won)

---

## 📝 NPM Scripts

### Deployment & Setup
```bash
# Deploy all Sales Demo Hub components
npm run demo:deploy

# Assign permissions to user
npm run demo:permissions

# Full setup (deploy + permissions + seed)
npm run demo:setup

# Seed demo data
npm run demo:seed

# Reset demo data (clear + re-seed)
npm run demo:reset

# Clear demo data
npm run demo:clear
```

### Advanced Usage

You can pass a different org alias to any script:
```bash
node scripts/seed-demo-data.js my-other-org
node scripts/clear-demo-data.js my-other-org
node scripts/assign-demo-permissions.js my-other-org
```

---

## 🎨 Dashboard Features

### KPI Cards
1. **Total Revenue** - Sum of all opportunity amounts
2. **Win Rate** - Percentage of won opportunities
3. **Average Deal Size** - Mean opportunity value
4. **Active Accounts** - Total number of accounts

### Sales Pipeline
- Visual bar chart of opportunities by stage
- Shows count and total value per stage
- Click-through to opportunities

### Recent Activity
- Last 5 modified opportunities
- Quick navigation to records
- Status and amount display

### Quick Actions
- **Create Sample Opportunity** - Generates a test opp
- **Refresh Dashboard** - Updates all metrics

---

## 🎭 Demo Flow

### Recommended Demo Sequence

1. **Show the branded app**
   - Gold header color
   - Custom navigation tabs
   - Professional appearance

2. **Open Demo KPIs dashboard**
   - Highlight the 4 KPI cards
   - Show real-time data

3. **Review the pipeline**
   - Show distribution across stages
   - Click on pipeline items

4. **Interact with Recent Activity**
   - Click to view opportunity details
   - Show seamless navigation

5. **Create Sample Opportunity**
   - Click the button
   - Navigate to new record
   - Return and refresh dashboard

6. **Navigate to standard objects**
   - Use tabs: Accounts, Contacts, Opportunities
   - Show familiar Salesforce UI

---

## 🔧 Apex API Reference

### DemoDataSeeder Methods

```apex
// Seed all demo data
Map<String, Integer> results = DemoDataSeeder.seedAllDemoData();
// Returns: { 'accounts' => 10, 'contacts' => 26, 'opportunities' => 17 }

// Clear demo data
Map<String, Integer> results = DemoDataSeeder.clearDemoData();
// Returns: { 'accountsDeleted' => X, 'contactsDeleted' => Y, 'opportunitiesDeleted' => Z }
```

### DemoKpiService Methods

```apex
// Get all KPI data (cacheable)
DemoKpiService.KpiData data = DemoKpiService.getKpiData();

// Create sample opportunity
String oppId = DemoKpiService.createSampleOpportunity(accountId);
```

---

## 📊 Data Model

### Accounts
- **Name**: "Demo Corp - [Company Name]"
- **Industry**: Technology, Healthcare, Financial Services, Manufacturing, Retail
- **Type**: Customer, Prospect, Partner
- **Annual Revenue**: $1M - $3.5M
- **Employees**: 50 - 550
- **Full address** with phone and website

### Contacts
- **2-3 contacts per account**
- **Titles**: CEO, CFO, VP Sales, Director of Operations, IT Manager
- **Full contact info** with email and phone

### Opportunities
- **1-3 opportunities per account**
- **Stages**: Prospecting → Qualification → Needs Analysis → Value Proposition → Negotiation → Closed Won
- **Amount**: $50K - $300K
- **Type**: New Business, Existing Business, Renewal
- **Probability** matched to stage

---

## 🎨 Theming & Branding

### Gold Color Palette
- **Primary**: #D4AF37
- **Secondary**: #FFD700
- **Dark**: #B8941E
- **Light**: #F5E6D3

### Custom Styles
The dashboard uses:
- Gradient gold backgrounds
- Smooth transitions and hover effects
- Responsive design (mobile-friendly)
- SLDS-compliant styling

---

## 🧪 Testing

Run Apex tests:
```bash
sf apex run test --target-org a4sales-demo-org --class-names DemoKpiService_Test --result-format human
```

Expected coverage:
- ✅ DemoKpiService: 100%
- ✅ All methods tested
- ✅ Edge cases covered

---

## 🛠 Customization

### Modify Demo Data Volume

Edit `DemoDataSeeder.cls`:
```apex
// Line ~44 - Change account count
for (Integer i = 1; i <= 10; i++) {  // Change 10 to desired count
```

### Change Theming

Edit `demoKpiPanel.css`:
```css
:host {
    --gold-primary: #YOUR_COLOR;  /* Change color values */
}
```

### Add More KPIs

1. Update `DemoKpiService.cls` to add new metrics
2. Add new KPI cards in `demoKpiPanel.html`
3. Style in `demoKpiPanel.css`

---

## 🗂 File Structure

```
force-app/main/default/
├── applications/
│   └── Sales_Demo_Hub.app-meta.xml
├── classes/
│   ├── DemoDataSeeder.cls
│   ├── DemoDataSeeder.cls-meta.xml
│   ├── DemoKpiService.cls
│   ├── DemoKpiService.cls-meta.xml
│   ├── DemoKpiService_Test.cls
│   └── DemoKpiService_Test.cls-meta.xml
├── lwc/
│   └── demoKpiPanel/
│       ├── demoKpiPanel.css
│       ├── demoKpiPanel.html
│       ├── demoKpiPanel.js
│       └── demoKpiPanel.js-meta.xml
├── pages/
│   ├── Demo_Home.page
│   └── Demo_Home.page-meta.xml
├── permissionsets/
│   └── Demo_Permissions.permissionset-meta.xml
├── staticresources/
│   ├── demoLogo.svg
│   └── demoLogo.resource-meta.xml
└── tabs/
    └── Demo_KPIs.tab-meta.xml

scripts/
├── seed-demo-data.js
├── clear-demo-data.js
└── assign-demo-permissions.js
```

---

## 🎯 Use Cases

### Sales Kickoff Demos
- Show comprehensive sales metrics
- Display pipeline health
- Demonstrate data-driven insights

### Customer Presentations
- Professional branded experience
- Real-time KPI updates
- Interactive dashboard

### Training Sessions
- Use as learning environment
- Reset data easily
- Explore Salesforce features

---

## 🔐 Permissions

The **Demo_Permissions** permission set grants:
- ✅ Access to Sales Demo Hub app
- ✅ Apex class execution (DemoDataSeeder, DemoKpiService)
- ✅ Read/Create/Edit access to Account, Contact, Opportunity, Lead
- ✅ View All records for demo objects
- ✅ Tab visibility for all demo tabs

Assigned to: `sargo@a4salesdemo.com`

---

## 🎬 Next Steps

### Option 1: Enhance the Dashboard
- Add more visualizations (charts, graphs)
- Include forecast data
- Add filters and date ranges

### Option 2: Expand Demo Data
- Add more accounts and opportunities
- Include different industries
- Add closed/lost opportunities

### Option 3: Create FlexiPage
- Build custom app homepage
- Add dashboard to record pages
- Create mobile-optimized views

### Option 4: Integration
- Connect to external systems
- Add Einstein features
- Include Flow automations

---

## 🐛 Troubleshooting

### Dashboard Not Loading
```bash
# Verify component is deployed
sf project deploy report --target-org a4sales-demo-org

# Check permissions
sf org assign permset --name Demo_Permissions --target-org a4sales-demo-org
```

### No Data Showing
```bash
# Re-seed data
npm run demo:reset
```

### Styling Issues
```bash
# Re-deploy LWC
sf project deploy start --target-org a4sales-demo-org --metadata LightningComponentBundle:demoKpiPanel
```

---

## 📞 Support

For issues or questions:
1. Check the deployment logs
2. Verify permission set assignment
3. Confirm demo data exists (run SOQL query)
4. Review browser console for LWC errors

### Verify Data
```bash
sf data query --query "SELECT COUNT() FROM Account WHERE Name LIKE 'Demo Corp%'" --target-org a4sales-demo-org
sf data query --query "SELECT COUNT() FROM Opportunity WHERE Name LIKE 'Demo -%'" --target-org a4sales-demo-org
```

---

## 🎉 Success!

Your Sales Demo Hub is now fully deployed and ready to use!

**Current Status:**
- ✅ All components deployed
- ✅ Permissions assigned
- ✅ Demo data seeded (10 accounts, 26 contacts, 17 opportunities)
- ✅ Dashboard accessible at Demo KPIs tab

**Access your demo:**
```bash
sf org open --target-org a4sales-demo-org
```

Then navigate to: **Sales Demo Hub app → Demo KPIs tab**

Enjoy your beautiful, gold-themed sales dashboard! 🏆

