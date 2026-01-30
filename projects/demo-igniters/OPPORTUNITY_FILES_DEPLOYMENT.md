# Opportunity Files Retriever - Deployment Guide

## Overview

This guide walks you through deploying the **OpportunityFileRetriever** Apex action to your Salesforce org and setting it up for use in Flows and Prompt Templates.

---

## What Gets Deployed

### Apex Classes
1. **OpportunityFileRetriever.cls** - Main invocable action
2. **OpportunityFileRetriever_Test.cls** - Test class (>95% coverage)

### Sample Flow
3. **Display_Opportunity_Files.flow** - Example screen flow

### Documentation
4. **OPPORTUNITY_FILES_RETRIEVER_GUIDE.md** - Complete usage guide
5. **OPPORTUNITY_FILES_QUICK_REFERENCE.md** - Quick reference card
6. **OPPORTUNITY_FILES_DEPLOYMENT.md** - This file

---

## Prerequisites

✅ Salesforce CLI installed  
✅ Connected to target org  
✅ User has Deploy metadata permission  
✅ Lightning Experience enabled  
✅ ContentDocument access enabled  

---

## Deployment Steps

### Option 1: Deploy via Salesforce CLI

#### Step 1: Navigate to Project Directory

```bash
cd demo-igniters
```

#### Step 2: Deploy Apex Classes

```bash
sf project deploy start \
  --source-dir force-app/main/default/classes/OpportunityFileRetriever.cls \
  --source-dir force-app/main/default/classes/OpportunityFileRetriever_Test.cls \
  --target-org [your-org-alias]
```

#### Step 3: Run Tests

```bash
sf apex run test \
  --class-names OpportunityFileRetriever_Test \
  --result-format human \
  --target-org [your-org-alias]
```

#### Step 4: Deploy Sample Flow (Optional)

```bash
sf project deploy start \
  --source-dir force-app/main/default/flows/Display_Opportunity_Files.flow-meta.xml \
  --target-org [your-org-alias]
```

---

### Option 2: Deploy via VS Code (Salesforce Extension Pack)

1. Open VS Code with Salesforce Extension Pack installed
2. Right-click on `OpportunityFileRetriever.cls`
3. Select **SFDX: Deploy Source to Org**
4. Repeat for `OpportunityFileRetriever_Test.cls`
5. Verify deployment in Output panel

---

### Option 3: Deploy via Workbench

1. Go to [workbench.developerforce.com](https://workbench.developerforce.com)
2. Login to your org
3. Go to **Migration > Deploy**
4. Upload a ZIP containing:
   - `classes/OpportunityFileRetriever.cls`
   - `classes/OpportunityFileRetriever.cls-meta.xml`
   - `classes/OpportunityFileRetriever_Test.cls`
   - `classes/OpportunityFileRetriever_Test.cls-meta.xml`
   - `package.xml`
5. Check **Run All Tests** (or specific test)
6. Click **Next** and **Deploy**

---

### Option 4: Manual Deployment via Setup

1. Login to Salesforce
2. Go to **Setup > Custom Code > Apex Classes**
3. Click **New**
4. Copy/paste contents of `OpportunityFileRetriever.cls`
5. Click **Save**
6. Repeat steps 3-5 for `OpportunityFileRetriever_Test.cls`
7. Run test from **Setup > Apex Test Execution**

---

## Verification

### Verify Apex Class Deployment

1. Go to **Setup > Apex Classes**
2. Search for **OpportunityFileRetriever**
3. Click on the class name
4. Verify it shows "Active" status
5. Check the API version is 59.0 or higher

### Verify Test Coverage

```bash
# Via CLI
sf apex get test \
  --class-name OpportunityFileRetriever_Test \
  --target-org [your-org-alias]
```

Or in Setup:
1. Go to **Setup > Apex Test Execution**
2. Click **View Test History**
3. Find **OpportunityFileRetriever_Test**
4. Verify coverage is >75% (should be ~95%)

### Verify Action is Available in Flow

1. Go to **Setup > Flows**
2. Create a new flow or open existing flow
3. Click **+** to add an element
4. Select **Action**
5. Search for **Get Opportunity Files**
6. Verify it appears in the search results
7. Select it and verify input/output parameters are visible

---

## Post-Deployment Configuration

### 1. Grant Permissions

Ensure users have these permissions:

**Object Permissions:**
- Read on `Opportunity`
- Read on `ContentDocument`
- Read on `ContentVersion`
- Read on `ContentDocumentLink`

**System Permissions:**
- View Content in Portals (if using Experience Cloud)
- API Enabled

### 2. Add Flow to Opportunity Page (Optional)

If you deployed the sample flow:

1. Go to **Setup > Lightning App Builder**
2. Edit the Opportunity Record Page
3. Add a **Flow** component
4. Select **Display Opportunity Files**
5. Set recordId to **{!recordId}**
6. Save and activate

### 3. Create Prompt Template (Optional)

1. Go to **Setup > Prompt Builder**
2. Click **New Prompt Template**
3. Add a **Flow** step
4. Add **Get Opportunity Files** action
5. Use output in prompt body
6. Save and test

---

## Usage Examples

### Example 1: Add to Screen Flow

1. **Setup > Flows > New Flow**
2. Select **Screen Flow**
3. Add **Get Records** element (get Opportunity)
4. Add **Action** element:
   - Action: Get Opportunity Files
   - Opportunity ID: `{!Get_Records.Id}`
5. Add **Screen** element
6. Add **Display Text** component
7. Insert `{!Get_Opportunity_Files.File_List}`
8. Save and activate

### Example 2: Use in Prompt Template

1. **Setup > Prompt Builder > New Template**
2. Template name: "Analyze Opportunity Files"
3. Add **Resource**:
   - Type: Flow Action
   - Action: Get Opportunity Files
   - Input: `{!$Input:Opportunity.Id}`
4. Prompt body:
   ```
   Analyze these files:
   {!Get_Opportunity_Files.File_Summary}
   
   Provide recommendations...
   ```
5. Save template

### Example 3: Record-Triggered Flow

1. **Setup > Flows > New Flow**
2. Select **Record-Triggered Flow**
3. Object: Opportunity
4. Trigger: Record is updated
5. Condition: Stage changes to "Proposal Sent"
6. Add **Action**: Get Opportunity Files
7. Add **Send Email** with file list
8. Activate

---

## Troubleshooting

### Issue: Class Not Found in Flow

**Solution:**
1. Verify class is deployed and active
2. Check class has `@InvocableMethod` annotation
3. Clear Flow Builder cache (Ctrl/Cmd + Shift + R)
4. Try in incognito/private browser window

### Issue: Test Fails

**Solution:**
1. Check test error message
2. Verify user has ContentDocument permissions
3. Run test as user with proper permissions
4. Check governor limits aren't exceeded

### Issue: Permission Denied

**Solution:**
1. Grant Read access on ContentDocument objects
2. Verify user profile has API enabled
3. Check sharing rules on Opportunity
4. Ensure user can see files in UI

### Issue: Files Not Returned

**Solution:**
1. Verify files are actually linked to Opportunity
2. Check file type filter isn't too restrictive
3. Verify user has access to files
4. Check if files are archived

---

## Rollback

To remove the deployment:

### Via CLI

```bash
sf project delete source \
  --metadata ApexClass:OpportunityFileRetriever \
  --metadata ApexClass:OpportunityFileRetriever_Test \
  --target-org [your-org-alias]
```

### Via Setup

1. Go to **Setup > Apex Classes**
2. Find **OpportunityFileRetriever**
3. Click **Del** (delete)
4. Repeat for test class
5. Note: Cannot delete if referenced in active Flows

---

## Security Considerations

### Data Access
- Action uses `with sharing` - respects org sharing rules
- Users can only retrieve files they have access to
- No elevation of privileges

### File Access
- Download/view URLs work within Salesforce security
- External users need proper sharing settings
- Files respect record-level security

### Best Practices
- Grant minimum required permissions
- Test with different user profiles
- Monitor file access logs
- Review sharing rules periodically

---

## Performance Notes

### Limits
- Respects SOQL governor limits
- No callouts performed
- Efficient query structure
- Safe for batch operations

### Optimization
- Use file type filters to reduce query size
- Set max files limit for large attachments
- Consider caching for multiple calls
- Avoid in large loops without bulkification

### Governor Limits
- Max 100 SOQL queries per transaction
- Max 50,000 records retrieved per transaction
- No CPU time concerns for normal use
- No heap size concerns for normal use

---

## Monitoring

### Check Usage

```sql
-- Query from Developer Console
SELECT Id, StartTime, Status, NumberOfErrors 
FROM AsyncApexJob 
WHERE ApexClass.Name = 'OpportunityFileRetriever_Test'
ORDER BY StartTime DESC
LIMIT 10
```

### Check Debug Logs

1. **Setup > Debug Logs**
2. Add trace flag for your user
3. Set Apex Code to FINEST
4. Run flow/action
5. Review log file

### Monitor Flow Errors

1. **Setup > Process Automation Settings**
2. Enable **Error Emails**
3. Errors will be sent to flow owner
4. Check **Paused Flow Interviews** for failures

---

## Updates and Maintenance

### To Update the Class

1. Deploy new version of `OpportunityFileRetriever.cls`
2. Deploy updated test class if needed
3. Run tests to verify
4. Deactivate/reactivate flows if needed
5. Clear browser cache

### Version Compatibility

- **API Version:** 59.0 or higher
- **Lightning Experience:** Required
- **Classic:** Not supported (URLs are Lightning-specific)
- **Mobile:** Supported

---

## Support Resources

- **Full Guide:** `OPPORTUNITY_FILES_RETRIEVER_GUIDE.md`
- **Quick Reference:** `OPPORTUNITY_FILES_QUICK_REFERENCE.md`
- **Test Class:** `OpportunityFileRetriever_Test.cls`
- **Sample Flow:** `Display_Opportunity_Files.flow`

---

## Success Checklist

After deployment, verify:

- ✅ Apex class is deployed and active
- ✅ Test class passes with >75% coverage
- ✅ Action appears in Flow Builder
- ✅ Can add action to test flow
- ✅ Action returns expected results
- ✅ Users have necessary permissions
- ✅ Sample flow works (if deployed)
- ✅ Documentation is accessible

---

**Deployment Complete! 🎉**

Proceed to `OPPORTUNITY_FILES_RETRIEVER_GUIDE.md` for usage instructions.

