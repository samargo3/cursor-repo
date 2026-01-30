# Account Contract Analysis - Step-by-Step Tutorial

This tutorial walks you through setting up **AI-powered account-level contract analysis** using the AccountOpportunityFilesRetriever action and Prompt Builder.

---

## What You'll Build

By the end of this tutorial, you'll have:

✅ A Screen Flow that analyzes all contracts for an Account  
✅ A Prompt Template that uses AI to analyze contracts  
✅ A working solution on the Account record page  
✅ Automated insights across multiple opportunities  

**Time to Complete:** 30-45 minutes

---

## Prerequisites

Before you begin:

- [ ] OpportunityFileRetriever.cls deployed (from Part 1)
- [ ] AccountOpportunityFilesRetriever.cls deployed  
- [ ] User has access to Prompt Builder  
- [ ] Test Account with 2-3 Opportunities and attached files  
- [ ] Lightning Experience enabled  

---

## Part 1: Deploy the Action

### Step 1: Deploy Apex Classes

```bash
cd /Users/sargo/Documents/demo-igniters/demo-igniters

sf project deploy start \
  --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever.cls \
  --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever_Test.cls \
  --target-org [your-org-alias]
```

### Step 2: Verify Deployment

```bash
sf apex run test \
  --class-names AccountOpportunityFilesRetriever_Test \
  --result-format human \
  --target-org [your-org-alias]
```

Expected output: All tests pass with >90% coverage

### Step 3: Verify Action is Available

1. Go to **Setup > Flows**
2. Click **New Flow**
3. Add an **Action** element
4. Search for **"Get Account Opportunity Files"**
5. ✅ Confirm it appears in search results

---

## Part 2: Create Test Data

### Step 1: Create Test Account

1. Go to **Accounts** tab
2. Click **New**
3. Enter:
   - Account Name: **Acme Corporation (Test)**
   - Save

### Step 2: Create Test Opportunities

Create 3 opportunities for this account:

**Opportunity 1:**
- Name: **Enterprise Deal Q1**
- Account: Acme Corporation (Test)
- Stage: Proposal/Price Quote
- Close Date: 30 days from today
- Amount: $500,000

**Opportunity 2:**
- Name: **Renewal Deal**
- Account: Acme Corporation (Test)
- Stage: Negotiation/Review
- Close Date: 45 days from today
- Amount: $250,000

**Opportunity 3:**
- Name: **Expansion Deal**
- Account: Acme Corporation (Test)
- Stage: Prospecting
- Close Date: 60 days from today
- Amount: $150,000

### Step 3: Upload Test Files

For each opportunity, upload 1-2 files:

**Enterprise Deal Q1:**
- Upload: MSA.pdf (or any PDF, rename to "MSA Contract")
- Upload: SOW.docx (or any Word doc, rename to "Statement of Work")

**Renewal Deal:**
- Upload: Renewal.pdf (rename to "Renewal Contract")

**Expansion Deal:**
- Upload: Expansion.pdf (rename to "Expansion Proposal")

**Total:** 4 files across 3 opportunities

---

## Part 3: Create the Prompt Template

### Step 1: Go to Prompt Builder

1. Setup > Prompt Builder
2. Click **New Prompt Template**

### Step 2: Configure Template Basics

**Template Name:** Account Contract Analysis  
**Description:** Analyzes all contracts across opportunities for an account  
**Category:** Contract Management  
**Type:** Flex  

### Step 3: Add Input Resources

Click **New Resource** for each:

**Resource 1:**
- Name: `accountName`
- Type: Text
- Description: Name of the Account

**Resource 2:**
- Name: `opportunityCount`
- Type: Number
- Description: Number of opportunities

**Resource 3:**
- Name: `totalFiles`
- Type: Number
- Description: Total number of files

**Resource 4:**
- Name: `fileSummary`
- Type: Text (Long)
- Description: Complete file summary from action

### Step 4: Write the Prompt

Copy this into the Prompt Body:

```
You are a legal and sales operations expert analyzing contracts for a customer account.

ACCOUNT INFORMATION:
- Account Name: {!$Input:accountName}
- Total Opportunities: {!$Input:opportunityCount}
- Total Contract Files: {!$Input:totalFiles}

DOCUMENTS:
{!$Input:fileSummary}

ANALYSIS TASKS:

1. DOCUMENT INVENTORY
List all contracts found, organized by opportunity. Note the document type (MSA, SOW, Amendment, etc.)

2. PAYMENT TERMS
If any payment terms are mentioned or can be inferred, summarize them. Note if terms are consistent across contracts.

3. RISK ASSESSMENT
Based on the documents present (or missing), assess risk level:
- Low Risk: All standard documents present
- Medium Risk: Some documents missing
- High Risk: Critical documents missing or concerning patterns

4. MISSING DOCUMENTS
Identify any standard documents that appear to be missing:
- Master Service Agreement (MSA)
- Statement of Work (SOW)  
- Pricing/Quote documents
- Security/Compliance documents

5. RECOMMENDATIONS
Provide 3-5 specific recommendations for:
- Document completion
- Contract standardization
- Risk mitigation
- Next steps

FORMAT:
Use clear sections with headers.
Be specific and cite opportunity names.
Prioritize findings by importance.
Keep recommendations actionable.
```

### Step 5: Test the Prompt

1. Click **Test Prompt**
2. Fill in sample inputs:
   - accountName: "Acme Corporation"
   - opportunityCount: 3
   - totalFiles: 4
   - fileSummary: (paste a sample summary or use dummy text)
3. Click **Generate**
4. Review the AI response
5. Adjust prompt if needed

### Step 6: Save and Activate

1. Click **Save**
2. Click **Activate**
3. Note the Prompt Template API Name (you'll need it for the flow)

---

## Part 4: Create the Screen Flow

### Step 1: Create New Flow

1. Setup > Flows
2. Click **New Flow**
3. Select **Screen Flow**
4. Click **Create**

### Step 2: Add Input Variable

Click **New Resource**:
- Resource Type: **Variable**
- API Name: `recordId`
- Data Type: **Text**
- Available for input: ✅ **Checked**
- Available for output: ❌ **Unchecked**

This will receive the Account ID when launched from the record page.

### Step 3: Add Action - Get Account Opportunity Files

1. Click **+** on canvas
2. Select **Action**
3. Search: "Get Account Opportunity Files"
4. Select it
5. Label: **Get Account Opportunity Files**

**Configure Inputs:**
- Account ID: `{!recordId}`
- File Types Filter: `pdf,docx`
- Max Files Per Opportunity: (leave blank)
- Max Total Files: (leave blank)

**Store Outputs:** (create these variables as needed)
- Success → `varSuccess` (Boolean)
- Account Name → `varAccountName` (Text)
- Opportunity Count → `varOppCount` (Number)
- Total File Count → `varTotalFiles` (Number)
- Aggregated File Summary → `varFileSummary` (Text)
- Files By Opportunity → `varFilesByOpp` (Record Collection)

6. Click **Done**

### Step 4: Add Decision - Check Success

1. Click **+** after the action
2. Select **Decision**
3. Label: **Check Success**

**Outcome 1: Success**
- Label: Success
- Condition: `{!varSuccess}` Equals `True`

**Default Outcome:**
- Label: Failed

### Step 5: Add Action - Call Prompt Template

From **Success** outcome:

1. Click **+**
2. Select **Action**
3. Search: "Prompt Template" or your specific template name
4. Select **Account Contract Analysis** template

**Configure Inputs:**
- accountName: `{!varAccountName}`
- opportunityCount: `{!varOppCount}`
- totalFiles: `{!varTotalFiles}`
- fileSummary: `{!varFileSummary}`

**Store Output:**
- Response → `varAnalysis` (Text - Long)

5. Click **Done**

### Step 6: Add Screen - Display Analysis

1. Click **+** after prompt action
2. Select **Screen**
3. Label: **Display Contract Analysis**

**Add Components:**

**Component 1: Display Text (Header)**
- Label: (leave empty)
- API Name: Header
- Content:
```html
<p><b style="font-size: 18px;">Contract Analysis for {!varAccountName}</b></p>
<p>Analyzed {!varTotalFiles} files across {!varOppCount} opportunities</p>
<p>&nbsp;</p>
```

**Component 2: Display Text (Analysis)**
- Label: (leave empty)
- API Name: Analysis
- Content: `{!varAnalysis}`

**Component 3: Display Text (File Details)** (Optional)
- Label: **Document Inventory**
- API Name: FileDetails
- Content: `{!varFileSummary}`
- In Advanced: Set "Collapsible" section

**Screen Settings:**
- Show Previous: ✅ Checked
- Show Finish: ✅ Checked
- Show Pause: ❌ Unchecked

4. Click **Done**

### Step 7: Add Screen - Error Screen

From **Failed** outcome:

1. Click **+**
2. Select **Screen**
3. Label: **Error Screen**

**Add Component: Display Text**
- Content:
```html
<p><b style="color: red;">Error</b></p>
<p>Unable to retrieve contract files. Please try again.</p>
```

4. Click **Done**

### Step 8: Save the Flow

1. Click **Save**
2. Flow Label: **Account Contract Analysis**
3. Flow API Name: **Account_Contract_Analysis**
4. Description: **Analyzes all contracts across opportunities for an account using AI**
5. Click **Save**

### Step 9: Activate the Flow

1. Click **Activate**
2. Confirm activation

---

## Part 5: Add Flow to Account Page

### Step 1: Edit Account Page Layout

1. Go to any Account record
2. Click ⚙️ (Setup gear) > **Edit Page**
3. Lightning App Builder opens

### Step 2: Add Flow Component

1. From left sidebar, find **Flow** component
2. Drag it to the desired location (e.g., below Related Lists)
3. Click on the Flow component

### Step 3: Configure Flow Component

In properties panel:
- **Flow:** Select **Account Contract Analysis**
- **Pass record ID into this variable:** Select `recordId`
- **Label:** "Contract Analysis" (or leave blank)
- **Height:** 600px (or adjust as needed)

### Step 4: Save and Activate

1. Click **Save**
2. Click **Activate**
3. If prompted, assign to Account record page
4. Click **Save**

---

## Part 6: Test the Solution

### Step 1: Navigate to Test Account

1. Go to your test account: **Acme Corporation (Test)**
2. Scroll down to where you added the Flow component

### Step 2: Run the Analysis

1. The flow should load automatically
2. Or click **Start** if it's a button
3. Wait for processing (5-15 seconds)

### Step 3: Review Results

You should see:

**Header:**
```
Contract Analysis for Acme Corporation (Test)
Analyzed 4 files across 3 opportunities
```

**AI Analysis:** (example)
```
1. DOCUMENT INVENTORY
--------------------
Opportunity: Enterprise Deal Q1
- MSA Contract.pdf (Master Service Agreement)
- Statement of Work.docx (SOW)

Opportunity: Renewal Deal
- Renewal Contract.pdf (Renewal Agreement)

Opportunity: Expansion Deal
- Expansion Proposal.pdf (Proposal)

2. PAYMENT TERMS
--------------------
Unable to determine specific payment terms from filenames alone. 
Recommend reviewing documents for Net 30/60/90 terms.

3. RISK ASSESSMENT
--------------------
Risk Level: LOW-MEDIUM

Rationale:
- All opportunities have at least one contract document
- Enterprise Deal has both MSA and SOW (good)
- Renewal Deal has renewal contract (appropriate)
- Expansion Deal only has proposal (acceptable for Prospecting stage)

4. MISSING DOCUMENTS
--------------------
- Expansion Deal: Consider adding SOW once deal progresses
- All opportunities: No pricing documents visible
- No security/compliance addendums found

5. RECOMMENDATIONS
--------------------
1. PRICING DOCUMENTATION: Upload pricing schedules for all opportunities 
   to ensure transparent pricing management.

2. SECURITY REVIEW: For Enterprise Deal ($500K), ensure security 
   questionnaire and compliance documents are completed.

3. RENEWAL OPTIMIZATION: Review Renewal Deal contract for upsell 
   opportunities; compare terms with original MSA.

4. EXPANSION PREPARATION: As Expansion Deal progresses, prepare SOW 
   and ensure terms align with existing agreements.

5. CENTRALIZED STORAGE: Consider account-level master agreement to 
   consolidate terms across opportunities.
```

### Step 4: Verify File Details Section

Expand the "Document Inventory" collapsible section to see:
```
ACCOUNT-LEVEL CONTRACT ANALYSIS
==================================================

Account: Acme Corporation (Test)
Total Opportunities: 3
...
```

---

## Part 7: Enhance and Customize

### Optional Enhancements

**1. Add Email Notification**

After AI analysis, send results to account owner:

```
Element: Send Email
To: {!Account.Owner.Email}
Subject: Contract Analysis Complete - {!varAccountName}
Body: {!varAnalysis}
```

**2. Create Task for Follow-Up**

Create a task based on recommendations:

```
Element: Create Records
Object: Task
Fields:
  - Subject: "Complete contract analysis follow-up"
  - Description: {!varAnalysis}
  - Related To: {!recordId}
  - Owner: Current User
  - Due Date: 7 days from now
```

**3. Add File Count Filter**

Before the action, add a decision:

```
Decision: Has Enough Opportunities?
Condition: Opportunity Count < 2

If True: Show message "Need at least 2 opportunities"
If False: Continue with analysis
```

**4. Add Stage Filter**

Modify the prompt to focus on specific stages:

```
Only analyze opportunities in these stages:
- Proposal/Price Quote
- Negotiation/Review
- Closed Won

Ignore Prospecting stage opportunities.
```

---

## Troubleshooting

### Issue: Flow doesn't appear on page

**Solution:**
- Verify flow is activated
- Check recordId variable is set to "Available for input"
- Refresh the Account page
- Clear browser cache

### Issue: No files retrieved

**Solution:**
- Verify files are attached to opportunities
- Check opportunities belong to the account
- Verify user has file access permissions
- Try without file type filter

### Issue: AI response is generic

**Solution:**
- Ensure fileSummary is being passed correctly
- Check prompt template has detailed instructions
- Verify AI model is properly configured
- Add more context to the prompt

### Issue: "Error retrieving files"

**Solution:**
- Check user has ContentDocument read permission
- Verify Account ID is valid
- Review debug logs for specific error
- Test action standalone in Flow Debugger

---

## Best Practices

### 1. File Naming Conventions

Encourage users to use descriptive file names:
- ✅ "Acme_MSA_2024.pdf"
- ✅ "Acme_SOW_Q1_Enterprise.docx"
- ❌ "Document1.pdf"
- ❌ "Untitled.docx"

### 2. Document Organization

Create guidelines for file uploads:
- MSA/Contracts on first opportunity
- SOWs on each opportunity
- Amendments linked to original contracts
- Pricing documents clearly labeled

### 3. Regular Reviews

Schedule regular contract reviews:
- Quarterly account reviews
- Before renewal dates
- When adding new opportunities
- During executive business reviews

### 4. AI Prompt Refinement

Continuously improve your prompt:
- Add industry-specific terms
- Include company policy references
- Refine based on actual results
- A/B test different prompts

---

## Next Steps

Now that you have the basic solution working:

1. ✅ **Test with Real Data:** Try with actual accounts
2. ✅ **Refine Prompt:** Adjust for your industry/needs
3. ✅ **Add Automations:** Email, tasks, alerts
4. ✅ **Train Users:** Document usage guidelines
5. ✅ **Monitor Usage:** Track adoption and feedback
6. ✅ **Scale:** Add to more account layouts
7. ✅ **Integrate:** Connect with other systems

---

## Summary

You've successfully built an **AI-powered account-level contract analysis solution**:

✅ Retrieves files from all opportunities  
✅ Uses AI to analyze contracts  
✅ Provides actionable insights  
✅ Accessible directly from Account page  
✅ Automated and scalable  

**Time saved:** 30-60 minutes per account review  
**Insights gained:** Risk assessment, missing docs, recommendations  
**Next action:** Roll out to your sales and legal teams!

---

## Additional Resources

- **ACCOUNT_CONTRACT_ANALYSIS_GUIDE.md** - Complete reference
- **OPPORTUNITY_FILES_RETRIEVER_GUIDE.md** - Single opportunity analysis
- **Salesforce Prompt Builder Docs** - AI configuration

---

**Congratulations! You're now analyzing contracts with AI! 🎉**

