# Einstein Lead Scoring Setup Guide

This guide provides Solution Engineers with a complete process for setting up Einstein Lead Scoring with high-quality demo data. It covers lead generation, deployment, and opportunity optimization for realistic customer demonstrations.

## 🎯 Overview

This guide will help you:
- Generate 1000+ high-tech B2B leads optimized for Einstein Lead Scoring
- Deploy leads to any Salesforce org safely
- Optimize opportunity data distribution for professional demos
- Set up Einstein Lead Scoring with proper prerequisites

## 🚀 Quick Start

### Prerequisites
1. **Salesforce CLI installed and authenticated**
   ```bash
   sfdx org list  # Verify you have org connections
   ```

2. **Target Salesforce org** (Enterprise, Performance, or Unlimited Edition)
   - Einstein Lead Scoring requires qualifying editions
   - Ensure you have System Administrator access

3. **Node.js installed** (for running generation scripts)

### Complete Setup in 3 Steps

#### Step 1: Generate Einstein-Optimized Leads
```bash
cd /path/to/demo-igniters
node scripts/generate-einstein-leads.js 1000
```
This creates `data/einstein-leads.csv` with 1000 high-tech B2B leads.

#### Step 2: Deploy Leads to Your Org
```bash
node scripts/deploy-standard-leads.js
```
This safely deploys leads using your existing proven method.

#### Step 3: Optimize Opportunity Data (Optional)
```bash
node scripts/optimize-opportunities.apex
```
This redistributes opportunities for better demo presentation.

---

## 📋 Detailed Instructions

### 1. Lead Generation for Einstein Lead Scoring

#### What Makes These Leads "Einstein-Optimized"?

Our lead generator creates data specifically designed for Einstein Lead Scoring:

**Industry Focus:**
- Technology, SaaS, AI/ML, FinTech, HealthTech, EdTech
- High-tech B2B companies with realistic names
- Industry-specific job titles and lead sources

**Data Completeness:**
- All standard Lead fields populated
- Realistic email addresses and phone numbers
- Proper company metrics (revenue, employees)
- Geographic distribution across major US cities

**Scoring-Ready Fields:**
- `Company` - Realistic tech company names
- `Industry` - High-tech industries
- `LeadSource` - B2B-appropriate sources
- `Title` - Decision-maker titles
- `AnnualRevenue` - Realistic revenue ranges
- `NumberOfEmployees` - Company size metrics
- `Website` - Company websites

#### Generate Custom Lead Sets

**Default (1000 leads):**
```bash
node scripts/generate-einstein-leads.js
```

**Custom quantity:**
```bash
node scripts/generate-einstein-leads.js 500
```

**Custom company/industry:**
```bash
node scripts/generate-custom-leads.js "TechCorp Solutions" "techcorp.com" "Technology" 200
```

### 2. Safe Lead Deployment

#### Why Our Method is Safe

We use your existing proven deployment method:
- **Apex-based insertion** (most reliable)
- **Batch processing** (50 leads per batch)
- **Error handling** and rollback capability
- **No data loss** - only adds new leads

#### Deploy to Different Orgs

**Default org:**
```bash
node scripts/deploy-standard-leads.js
```

**Specific org:**
```bash
# Update the target org in the script, or modify the command
sfdx force:apex:execute -f scripts/deploy-standard-leads.apex --target-org your-org-alias
```

#### Verify Deployment

Check your lead count:
```bash
sfdx force:data:soql:query --query "SELECT COUNT() FROM Lead" --target-org your-org-alias
```

### 3. Opportunity Data Optimization

#### What This Optimization Does

Our optimization script addresses common demo data issues:

**Before Optimization:**
- ❌ One rep has 63% of all opportunities
- ❌ 62% of opportunities are "Closed Won"
- ❌ All opportunities created on same date
- ❌ Unrealistic distribution

**After Optimization:**
- ✅ Balanced rep distribution (8+ reps with meaningful workloads)
- ✅ 40% Closed Won, 60% active pipeline
- ✅ Realistic stage progression
- ✅ Professional demo appearance

#### Run Opportunity Optimization

```bash
sfdx force:apex:execute -f scripts/optimize-opportunities.apex --target-org your-org-alias
```

#### Verify Results

Check new distribution:
```bash
# Stage distribution
sfdx force:data:soql:query --query "SELECT StageName, COUNT(Id) FROM Opportunity GROUP BY StageName ORDER BY COUNT(Id) DESC" --target-org your-org-alias

# Owner distribution  
sfdx force:data:soql:query --query "SELECT Owner.Name, COUNT(Id) FROM Opportunity GROUP BY Owner.Name ORDER BY COUNT(Id) DESC" --target-org your-org-alias
```

---

## 🧠 Einstein Lead Scoring Setup

### Prerequisites Verification

#### 1. Data Requirements ✅
- **1000+ leads** (you now have 1000+)
- **120+ conversions** (leads with various statuses)
- **6+ months of data** (leads span multiple months)
- **Rich field data** (all standard fields populated)

#### 2. Salesforce Edition ✅
- Enterprise, Performance, or Unlimited Edition required
- Einstein Platform license included

#### 3. User Permissions ✅
- System Administrator access
- "Customize Application" permission
- "Modify All Data" permission

### Enable Einstein Lead Scoring

1. **Navigate to Setup:**
   ```
   Setup → Einstein → Lead Scoring → Get Started
   ```

2. **Follow the Setup Wizard:**
   - Review field inclusion/exclusion
   - Configure lead segmentation (optional)
   - Set up scoring models

3. **Wait for Processing:**
   - Initial processing: 24-48 hours
   - Look for `Einstein_Score__c` field on Lead records

### Monitor and Customize

#### Check Scoring Status
```bash
sfdx force:data:soql:query --query "SELECT Id, Name, Einstein_Score__c FROM Lead WHERE Einstein_Score__c != null LIMIT 10" --target-org your-org-alias
```

#### View Insights
- Go to Setup → Einstein → Lead Scoring → Insights
- Monitor model accuracy and performance
- Adjust field inclusion as needed

---

## 📊 Demo Best Practices

### Lead Data Demo Scripts

#### Show Lead Distribution
```sql
-- Industry distribution
SELECT Industry, COUNT(Id) FROM Lead GROUP BY Industry ORDER BY COUNT(Id) DESC

-- Lead source effectiveness  
SELECT LeadSource, COUNT(Id) FROM Lead GROUP BY LeadSource ORDER BY COUNT(Id) DESC

-- Geographic distribution
SELECT State, COUNT(Id) FROM Lead GROUP BY State ORDER BY COUNT(Id) DESC
```

#### Demonstrate Einstein Scoring
```sql
-- High-scoring leads
SELECT Name, Company, Industry, Einstein_Score__c FROM Lead WHERE Einstein_Score__c > 80 ORDER BY Einstein_Score__c DESC

-- Score distribution
SELECT Einstein_Score__c, COUNT(Id) FROM Lead WHERE Einstein_Score__c != null GROUP BY Einstein_Score__c ORDER BY Einstein_Score__c DESC
```

### Opportunity Demo Scripts

#### Show Balanced Pipeline
```sql
-- Stage progression
SELECT StageName, COUNT(Id), SUM(Amount) FROM Opportunity GROUP BY StageName ORDER BY COUNT(Id) DESC

-- Rep performance
SELECT Owner.Name, COUNT(Id), SUM(Amount) FROM Opportunity GROUP BY Owner.Name ORDER BY COUNT(Id) DESC

-- Deal size distribution
SELECT Type, COUNT(Id), AVG(Amount) FROM Opportunity GROUP BY Type ORDER BY COUNT(Id) DESC
```

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Lead Generation Fails
**Problem:** Script errors or missing dependencies
**Solution:**
```bash
# Check Node.js version
node --version

# Install dependencies
npm install

# Run with verbose output
node scripts/generate-einstein-leads.js 100 2>&1 | tee generation.log
```

#### 2. Deployment Errors
**Problem:** Apex compilation errors or governor limits
**Solution:**
```bash
# Check org connection
sfdx org list

# Verify org permissions
sfdx force:user:display --target-org your-org-alias

# Run smaller batches
# Edit script to use BATCH_SIZE = 25 instead of 50
```

#### 3. Einstein Scoring Not Working
**Problem:** No scores appearing after 48 hours
**Solution:**
- Verify org edition (Enterprise+ required)
- Check data quality (complete fields, realistic values)
- Ensure sufficient lead volume (1000+ leads)
- Contact Salesforce Support if needed

#### 4. Opportunity Optimization Issues
**Problem:** Script fails or doesn't improve distribution
**Solution:**
```bash
# Check current distribution first
sfdx force:data:soql:query --query "SELECT Owner.Name, COUNT(Id) FROM Opportunity GROUP BY Owner.Name" --target-org your-org-alias

# Run optimization in smaller batches
# Edit script to process 100 opportunities at a time
```

---

## 📁 File Reference

### Generated Files
- `data/einstein-leads.csv` - Generated lead data
- `scripts/generate-einstein-leads.js` - Lead generation script
- `scripts/deploy-standard-leads.js` - Deployment script
- `scripts/optimize-opportunities.apex` - Opportunity optimization

### Key Scripts Explained

#### `generate-einstein-leads.js`
- Creates high-tech B2B companies
- Generates realistic contact information
- Populates all Einstein-important fields
- Ensures proper data distribution

#### `deploy-standard-leads.js`
- Uses proven Apex deployment method
- Processes in safe 50-lead batches
- Includes error handling and verification
- Maintains data integrity

#### `optimize-opportunities.apex`
- Redistributes opportunities across reps
- Moves opportunities to realistic stages
- Updates probabilities and close dates
- Creates balanced demo data

---

## 🎯 Success Metrics

### What Success Looks Like

#### Lead Data Quality
- ✅ 1000+ leads with complete data
- ✅ Realistic company names and industries
- ✅ Proper email/phone formatting
- ✅ Geographic distribution across US

#### Opportunity Distribution
- ✅ No single rep has >25% of opportunities
- ✅ Balanced stage distribution (40% closed, 60% active)
- ✅ Realistic close dates and probabilities
- ✅ Variety in opportunity types

#### Einstein Lead Scoring
- ✅ Einstein_Score__c field populated
- ✅ Scores range from 0-100
- ✅ Higher scores for better-qualified leads
- ✅ Scoring insights available in Setup

### Verification Commands

```bash
# Lead count and quality
sfdx force:data:soql:query --query "SELECT COUNT(), AVG(AnnualRevenue) FROM Lead" --target-org your-org-alias

# Opportunity distribution
sfdx force:data:soql:query --query "SELECT StageName, COUNT(Id) FROM Opportunity GROUP BY StageName" --target-org your-org-alias

# Einstein scoring status
sfdx force:data:soql:query --query "SELECT COUNT() FROM Lead WHERE Einstein_Score__c != null" --target-org your-org-alias
```

---

## 📞 Support and Resources

### Additional Documentation
- `CUSTOM_LEADS_GUIDE.md` - Custom lead generation options
- `DEPLOYMENT_GUIDE.md` - General deployment guidance
- `OPPORTUNITY_OPTIMIZATION_SUMMARY.md` - Optimization results

### Salesforce Resources
- [Einstein Lead Scoring Setup](https://help.salesforce.com/s/articleView?id=sf.einstein_lead_scoring_setup.htm)
- [Einstein Platform Documentation](https://developer.salesforce.com/docs/atlas.en-us.einstein_platform.meta/einstein_platform/)
- [Salesforce CLI Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)

### Best Practices
- Always test in a sandbox first
- Keep backups of important data
- Document any customizations
- Monitor Einstein scoring accuracy over time

---

## 🚀 Next Steps

After completing this setup:

1. **Enable Einstein Lead Scoring** in your org
2. **Wait 24-48 hours** for initial processing
3. **Review scoring insights** in Setup → Einstein
4. **Customize field inclusion** based on your business needs
5. **Set up lead scoring rules** and automation
6. **Train your team** on interpreting lead scores

Your org is now ready for professional Einstein Lead Scoring demonstrations! 🎉

