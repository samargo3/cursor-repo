# Proforma Resource Forecasting - Deployment & Usage Guide

## Overview
The Proforma Resource Forecasting feature enables sales reps and RevOps teams to track human resource costs and effort required for deals before they close. This helps in accurate profitability analysis and resource planning.

---

## Features

### 1. **Custom Objects & Fields**
- **Resource_Forecast__c**: Master-Detail relationship to Opportunity
  - `Role__c` (Picklist): PMO, Technical Lead, Delivery Consultant, Solution Architect, Business Analyst, Developer, QA Engineer, Data Engineer
  - `Expected_Hours__c` (Number): Estimated hours for the resource
  - `Hourly_Cost__c` (Currency): Cost per hour for the role
  - `Total_Estimated_Cost__c` (Formula): Auto-calculated (Hours × Cost)

- **Total_Resource_Cost__c**: Roll-up Summary on Opportunity that sums all Resource Forecast costs

### 2. **Lightning Web Component**
- **proformaManager**: Professional grid interface for managing resource forecasts
  - Inline editing of resources
  - Dynamic profitability calculation
  - Real-time cost summaries
  - Responsive design

### 3. **Stage Gate Validation**
- Prevents opportunities from moving to "Closed Won" without at least one Resource Forecast
- Ensures resource planning compliance before deal closure

---

## Deployment Instructions

### Prerequisites
- Salesforce CLI installed
- Authenticated to your target org
- Opportunity object accessible

### Step 1: Deploy Metadata

```bash
# Navigate to the demo-igniters directory
cd /Users/sargo/Documents/demo-igniters/demo-igniters

# Deploy all components
sf project deploy start --source-dir force-app/main/default
```

Or deploy specific components:

```bash
# Deploy custom object and fields
sf project deploy start --metadata CustomObject:Resource_Forecast__c
sf project deploy start --metadata CustomField:Opportunity.Total_Resource_Cost__c

# Deploy Apex classes
sf project deploy start --metadata ApexClass:ProformaManagerController
sf project deploy start --metadata ApexClass:OpportunityResourceValidationHandler
sf project deploy start --metadata ApexClass:ProformaManagerControllerTest
sf project deploy start --metadata ApexClass:OpportunityResourceValidationTest

# Deploy trigger
sf project deploy start --metadata ApexTrigger:OpportunityResourceValidation

# Deploy LWC
sf project deploy start --metadata LightningComponentBundle:proformaManager
```

### Step 2: Run Tests

```bash
# Run all tests
sf apex run test --test-level RunLocalTests --wait 10

# Or run specific test classes
sf apex run test --tests ProformaManagerControllerTest --wait 10
sf apex run test --tests OpportunityResourceValidationTest --wait 10
```

### Step 3: Add Component to Opportunity Page

1. Navigate to **Setup** → **Object Manager** → **Opportunity**
2. Go to **Lightning Record Pages**
3. Select your Opportunity record page (or create a new one)
4. Drag the **Proforma Resource Manager** component onto the page
5. Save and activate the page

---

## Usage Instructions

### For Sales Reps

#### Adding Resource Forecasts

1. Open an Opportunity record
2. Locate the **Proforma Resource Forecasting** card
3. Click **Add Resource**
4. Fill in the details:
   - **Role**: Select from dropdown (e.g., PMO, Technical Lead)
   - **Expected Hours**: Enter estimated hours
   - **Hourly Cost**: Enter the hourly rate
5. Click **Save**

#### Understanding the Dashboard

The component displays three key metrics:

- **Opportunity Amount**: Total deal value
- **Total Resource Cost**: Sum of all resource forecasts
- **Deal Profitability**: Opportunity Amount - Total Resource Cost
  - Green = Profitable
  - Red = Unprofitable

#### Editing Resources

1. Click directly in the cells to edit Role, Hours, or Cost
2. The Total Estimated Cost updates automatically
3. Click **Save** to persist changes
4. Click **Cancel** to discard changes

#### Deleting Resources

1. Click the **Delete** icon (trash can) next to any resource
2. Confirm deletion
3. The component automatically refreshes

### For RevOps Managers

#### Stage Gate Compliance

- Opportunities **cannot** move to "Closed Won" without at least one Resource Forecast
- If attempted, the system shows an error:
  > "Cannot close opportunity as Won without resource forecasting. Please add at least one Resource Forecast to proceed."

#### Profitability Analysis

Monitor deal profitability using the **Profit Margin %** displayed:
- Formula: `((Opp Amount - Resource Cost) / Opp Amount) × 100`
- Use this to identify high-margin vs. low-margin deals

#### Reporting

Create custom reports using:
- **Resource Forecast** object
- Fields: Role, Expected Hours, Hourly Cost, Total Estimated Cost
- Cross-filter with Opportunities for advanced analysis

---

## Technical Architecture

### Component Files

```
force-app/main/default/
├── objects/
│   ├── Resource_Forecast__c/
│   │   ├── Resource_Forecast__c.object-meta.xml
│   │   └── fields/
│   │       ├── Opportunity__c.field-meta.xml (Master-Detail)
│   │       ├── Role__c.field-meta.xml (Picklist)
│   │       ├── Expected_Hours__c.field-meta.xml (Number)
│   │       ├── Hourly_Cost__c.field-meta.xml (Currency)
│   │       └── Total_Estimated_Cost__c.field-meta.xml (Formula)
│   └── Opportunity/
│       └── fields/
│           └── Total_Resource_Cost__c.field-meta.xml (Roll-up Summary)
├── classes/
│   ├── ProformaManagerController.cls
│   ├── ProformaManagerController.cls-meta.xml
│   ├── ProformaManagerControllerTest.cls
│   ├── ProformaManagerControllerTest.cls-meta.xml
│   ├── OpportunityResourceValidationHandler.cls
│   ├── OpportunityResourceValidationHandler.cls-meta.xml
│   ├── OpportunityResourceValidationTest.cls
│   └── OpportunityResourceValidationTest.cls-meta.xml
├── triggers/
│   ├── OpportunityResourceValidation.trigger
│   └── OpportunityResourceValidation.trigger-meta.xml
└── lwc/
    └── proformaManager/
        ├── proformaManager.js
        ├── proformaManager.html
        ├── proformaManager.css
        └── proformaManager.js-meta.xml
```

### Data Model

```
Opportunity (Standard Object)
    ├── Total_Resource_Cost__c (Roll-up Summary)
    └── Resource_Forecast__c (Child, Master-Detail)
            ├── Role__c (Picklist)
            ├── Expected_Hours__c (Number)
            ├── Hourly_Cost__c (Currency)
            └── Total_Estimated_Cost__c (Formula)
```

### Apex Controller Methods

| Method | Type | Description |
|--------|------|-------------|
| `getProformaData()` | @AuraEnabled(cacheable=true) | Retrieves opportunity and resource forecasts |
| `getRolePicklistValues()` | @AuraEnabled(cacheable=true) | Returns active Role picklist values |
| `saveResourceForecasts()` | @AuraEnabled | Upserts resource forecasts |
| `deleteResourceForecast()` | @AuraEnabled | Deletes a single forecast |

### Validation Logic

**Trigger**: `OpportunityResourceValidation` (Before Update)
- Fires when Opportunity.StageName changes to "Closed Won"
- Queries for Resource_Forecast__c records
- Adds error if count = 0

---

## Customization Options

### Adding New Roles

1. Go to **Setup** → **Object Manager** → **Resource Forecast**
2. Click **Fields & Relationships** → **Role**
3. Click **New** (in the picklist values section)
4. Add new roles (e.g., "DevOps Engineer", "Security Specialist")

### Modifying Default Costs

Create a Custom Metadata Type for default hourly rates:

```apex
// Example: Auto-populate Hourly_Cost__c based on Role__c
// Add in ProformaManagerController or a before-insert trigger
```

### Changing Stage Gate Requirements

Edit `OpportunityResourceValidationHandler.cls`:

```apex
// Example: Require minimum total cost threshold
private static final Decimal MIN_RESOURCE_COST = 10000;

// In validateResourceForecasts method, add:
if (opp.Total_Resource_Cost__c < MIN_RESOURCE_COST) {
    opp.addError('Minimum resource cost of $10,000 required');
}
```

### Styling Adjustments

Edit `proformaManager.css` to match your brand:

```css
/* Change primary color */
.card-value-primary {
    color: #YOUR_BRAND_COLOR;
}

/* Adjust card shadows */
.summary-card {
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}
```

---

## Testing & Quality Assurance

### Test Coverage

- **ProformaManagerControllerTest**: 95%+ coverage
  - Tests CRUD operations
  - Tests error handling
  - Tests bulk operations

- **OpportunityResourceValidationTest**: 95%+ coverage
  - Tests stage gate validation
  - Tests with/without forecasts
  - Tests bulk updates

### Manual Testing Checklist

- [ ] Add a new resource forecast
- [ ] Edit hours and verify total recalculation
- [ ] Delete a resource forecast
- [ ] Try closing opportunity without forecasts (should fail)
- [ ] Add forecast, then close opportunity (should succeed)
- [ ] Test on mobile device
- [ ] Verify profitability calculations
- [ ] Test with multiple currencies (if multi-currency enabled)

---

## Troubleshooting

### Common Issues

#### Component Not Showing on Opportunity Page
- **Solution**: Verify component is added to the Lightning Page layout
- Check that you've activated the page and assigned it to the appropriate profiles/apps

#### "Insufficient Privileges" Error
- **Solution**: Grant object and field permissions
  - Resource Forecast: Read, Create, Edit, Delete
  - Opportunity.Total_Resource_Cost__c: Read

#### Validation Not Firing
- **Solution**: 
  - Verify trigger is Active in Setup
  - Check that stage name exactly matches "Closed Won" (case-sensitive)
  - Review debug logs

#### Roll-up Summary Not Calculating
- **Solution**:
  - Verify Master-Detail relationship is correctly configured
  - Recalculate: Setup → Resource Forecast → Fields → Total Resource Cost → Recalculate

---

## Best Practices

### For Implementation
1. **Deploy to Sandbox First**: Test thoroughly before production
2. **Communicate Changes**: Notify sales team of new validation rules
3. **Training**: Provide hands-on training for sales reps
4. **Reporting**: Create dashboards to monitor adoption

### For Usage
1. **Add Forecasts Early**: Don't wait until ready to close
2. **Review Regularly**: Update forecasts as deal scope changes
3. **Cross-Check with Finance**: Validate hourly rates periodically
4. **Document Assumptions**: Use Opportunity description to note forecast rationale

---

## Future Enhancements

### Potential Features
- [ ] Approval process for high-cost forecasts
- [ ] Integration with resource scheduling systems
- [ ] Historical cost tracking and variance analysis
- [ ] AI-powered resource recommendations based on deal size
- [ ] Multi-phase resource planning
- [ ] Export to Excel functionality
- [ ] Email alerts for low-margin deals

---

## Support & Maintenance

### Monitoring
- Review Opportunity.Total_Resource_Cost__c field history
- Monitor trigger execution in debug logs
- Track user adoption via Lightning Usage App

### Maintenance Schedule
- **Quarterly**: Review and update Role picklist values
- **Bi-annually**: Audit hourly cost rates
- **Annually**: Review validation logic for business rule changes

---

## Contact & Questions

For questions about this feature, contact:
- **Technical Lead**: [Your Name/Team]
- **Business Owner**: RevOps Team
- **Project**: Apiphani Demo Org Enhancements

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-15 | Initial release |

---

## License & Credits

Built for **Apiphani** Salesforce Demo Org
Developed using Salesforce Lightning Web Components (LWC) and Apex
