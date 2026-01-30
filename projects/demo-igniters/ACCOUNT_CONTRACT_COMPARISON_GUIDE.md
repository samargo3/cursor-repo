# Account Contract Comparison Flow - Step-by-Step Guide

This guide shows you how to create a **Screen Flow on the Account page** that analyzes MSAs and SOW files across multiple opportunities and **compares contract terms** to identify inconsistencies.

---

## Overview

**What this flow does:**
- Runs from an Account record page
- Retrieves all MSA and SOW files from related opportunities
- Uses AI to analyze and **compare** contract terms across documents
- Highlights differences, inconsistencies, and risks
- Displays results in a formatted screen

**Time to Complete:** 30-40 minutes

---

## Prerequisites

Before you begin:

- ✅ AccountOpportunityFilesRetriever.cls deployed
- ✅ Access to Prompt Builder
- ✅ Test Account with 2+ opportunities
- ✅ MSA/SOW files attached to opportunities
- ✅ Lightning Experience enabled

---

## Part 1: Create the Prompt Template

### Step 1: Navigate to Prompt Builder

1. Go to **Setup**
2. In Quick Find, type **"Prompt Builder"**
3. Click **Prompt Builder**
4. Click **New Prompt Template**

### Step 2: Configure Template Basics

Fill in these fields:

| Field | Value |
|-------|-------|
| **Template Name** | Account Multi-Opportunity Contract Comparison |
| **Template API Name** | Account_Multi_Opportunity_Contract_Comparison |
| **Description** | Analyzes and compares contract terms across multiple opportunities for an account |
| **Object** | Leave blank (we'll pass data manually) |
| **Template Type** | Flex |

Click **Next**

### Step 3: Add Input Resources

You need to create **4 input resources**. For each one:

Click **+ New Resource** and fill in:

**Resource 1:**
- Resource Type: **Input**
- API Name: `accountName`
- Data Type: **Text**
- Description: `Name of the Account being analyzed`
- Required: ✅ Checked

**Resource 2:**
- Resource Type: **Input**
- API Name: `opportunityCount`
- Data Type: **Number**
- Description: `Number of opportunities with files`
- Required: ✅ Checked

**Resource 3:**
- Resource Type: **Input**
- API Name: `totalFiles`
- Data Type: **Number**
- Description: `Total number of contract files`
- Required: ✅ Checked

**Resource 4:**
- Resource Type: **Input**
- API Name: `fileSummary`
- Data Type: **Text Area (Long)**
- Description: `Complete file summary from AccountOpportunityFilesRetriever action`
- Required: ✅ Checked

### Step 4: Write the Prompt

Copy and paste this prompt into the **Prompt Template Body**:

```
You are a highly specialized Contractual Clause Analyst for the Deal Desk team. Your task is to analyze ALL documents attached to this account's opportunities and COMPARE terms across opportunities to identify inconsistencies, risks, and differences.

════════════════════════════════════════════════════════════════════════════
ACCOUNT CONTEXT
════════════════════════════════════════════════════════════════════════════

Account Name: {!$Input:accountName}
Number of Opportunities: {!$Input:opportunityCount}
Total Contract Files: {!$Input:totalFiles}

════════════════════════════════════════════════════════════════════════════
DOCUMENTS TO ANALYZE
════════════════════════════════════════════════════════════════════════════

{!$Input:fileSummary}

════════════════════════════════════════════════════════════════════════════
ANALYSIS INSTRUCTIONS
════════════════════════════════════════════════════════════════════════════

Your goal is to COMPARE contracts across opportunities and identify:
1. Inconsistencies in contract language between opportunities
2. Differences in key terms (payment, liability, SLAs, etc.)
3. Risks from conflicting terms
4. Missing standard clauses
5. Recommendations for standardization

Format your response using the structure below:

════════════════════════════════════════════════════════════════════════════
📄 EXECUTIVE SUMMARY
────────────────────────────────────────────────────────────────────────────

[Provide 3-4 sentence summary highlighting:
- Total contracts analyzed across opportunities
- Key finding: are terms consistent or different?
- Overall risk level: Low/Medium/High
- Primary recommendation]

════════════════════════════════════════════════════════════════════════════
✅ KEY TERMS COMPARISON TABLE
────────────────────────────────────────────────────────────────────────────

Compare these terms ACROSS all opportunities. Use "Consistent" if terms match, or "DIFFERS" if they vary.

Term                    | Opp 1 | Opp 2 | Opp 3 | Status      | Notes
────────────────────────|-------|-------|-------|-------------|─────────────────────
Payment Terms           | [val] | [val] | [val] | Consistent/DIFFERS | [key difference]
Limitation of Liability | [val] | [val] | [val] | Consistent/DIFFERS | [key difference]
Service Level Agreement | [val] | [val] | [val] | Consistent/DIFFERS | [key difference]
Termination Clause      | [val] | [val] | [val] | Consistent/DIFFERS | [key difference]
Auto-Renewal Terms      | [val] | [val] | [val] | Consistent/DIFFERS | [key difference]
Indemnification         | [val] | [val] | [val] | Consistent/DIFFERS | [key difference]
Data Rights/Ownership   | [val] | [val] | [val] | Consistent/DIFFERS | [key difference]
Warranty Terms          | [val] | [val] | [val] | Consistent/DIFFERS | [key difference]

[Use "N/A" for terms not found. Use "Not Reviewed" if file content unavailable]

════════════════════════════════════════════════════════════════════════════
🔴 CRITICAL INCONSISTENCIES
────────────────────────────────────────────────────────────────────────────

[List ONLY significant differences that could cause legal/business risk]

1. [Inconsistency 1]
   - Opportunity: [Name]
   - Difference: [Explain]
   - Risk: [Impact]

2. [Inconsistency 2]
   - Opportunity: [Name]
   - Difference: [Explain]
   - Risk: [Impact]

[Or write "None found" if contracts are consistent]

════════════════════════════════════════════════════════════════════════════
⚠️ RISK ASSESSMENT          💡 RECOMMENDATIONS
────────────────────────────────────────────────────────────────────────────

**Overall Risk:** [Low/Medium/High]

**Risk Factors:**                **Actions to Take:**
• [Risk 1]                       1. [Recommendation 1]
• [Risk 2]                       2. [Recommendation 2]
• [Risk 3]                       3. [Recommendation 3]
                                 4. [Recommendation 4]
                                 5. [Recommendation 5]

════════════════════════════════════════════════════════════════════════════
❌ MISSING TERMS & DOCUMENTS
────────────────────────────────────────────────────────════────────────────

**Missing Standard Clauses:**
[List any standard clauses missing from contracts]

**Missing Documents:**
[List opportunities missing MSA, SOW, or other standard docs]

════════════════════════════════════════════════════════════════════════════
📋 DOCUMENT INVENTORY
────────────────────────────────────────────────────────────────────────────

[List all files by opportunity for reference]

Opportunity 1: [Name]
- [File 1]
- [File 2]

Opportunity 2: [Name]
- [File 1]

[etc.]

════════════════════════════════════════════════════════════════════════════
```

### Step 5: Test the Prompt (Optional but Recommended)

1. Click **Preview**
2. Fill in test values:
   - accountName: `Test Corp`
   - opportunityCount: `3`
   - totalFiles: `5`
   - fileSummary: (paste sample text or use: `Opportunity 1: Enterprise Deal - MSA.pdf, SOW.pdf | Opportunity 2: Renewal - Contract.pdf`)
3. Click **Generate**
4. Review AI output format
5. Adjust prompt if needed

### Step 6: Save and Activate

1. Click **Save**
2. Review the summary
3. Click **Activate**
4. Copy the **API Name** (you'll need it for the flow)
   - Should be: `Account_Multi_Opportunity_Contract_Comparison`

✅ **Checkpoint:** Your prompt template is ready!

---

## Part 2: Create the Screen Flow

### Step 1: Create New Flow

1. Setup > **Flows**
2. Click **New Flow**
3. Select **Screen Flow**
4. Click **Create**

### Step 2: Create Variables

You need to create **7 variables**. Click the **Manager** tab (left sidebar) or press **Ctrl/Cmd + K** and select "New Resource":

**Variable 1: Input Variable**
- Resource Type: **Variable**
- API Name: `recordId`
- Data Type: **Text**
- Available for input: ✅ **Checked**
- Available for output: ❌ Unchecked
- Description: `Account ID from the record page`

**Variable 2-7: Create these to store action outputs**

| API Name | Data Type | Available for Input | Description |
|----------|-----------|---------------------|-------------|
| `varAccountName` | Text | ❌ | Store account name |
| `varOppCount` | Number | ❌ | Store opportunity count |
| `varTotalFiles` | Number | ❌ | Store total file count |
| `varFileSummary` | Text Area (Long) | ❌ | Store file summary |
| `varAnalysisResult` | Text Area (Long) | ❌ | Store AI analysis result |
| `varSuccess` | Boolean | ❌ | Store action success status |

### Step 3: Add Action - Get Account Opportunity Files

1. Click **+** on the canvas (Start node)
2. Select **Action**
3. In search box, type: `Get Account Opportunity Files`
4. Select **Get Account Opportunity Files** action
5. Label: `Get Account Opportunity Files`
6. API Name: `Get_Account_Opportunity_Files`

**Configure Input Parameters:**

| Parameter | Value | Notes |
|-----------|-------|-------|
| Account ID | `{!recordId}` | Maps to account record |
| File Types Filter | `pdf,docx,doc` | Filter for contract files |
| Max Files Per Opportunity | *(leave blank)* | Get all files |
| Max Total Files | `20` | Reasonable limit |

**Store Output Values:**

| Output | Store In | Type |
|--------|----------|------|
| Success | `{!varSuccess}` | Boolean |
| Account Name | `{!varAccountName}` | Text |
| Opportunity Count | `{!varOppCount}` | Number |
| Total File Count | `{!varTotalFiles}` | Number |
| Aggregated File Summary | `{!varFileSummary}` | Text |

7. Click **Done**

### Step 4: Add Decision - Check if Files Retrieved

1. Click **+** after the action
2. Select **Decision**
3. Label: `Check Success`
4. API Name: `Check_Success`

**Configure Outcome 1: Success Path**
- Label: `Success`
- Outcome API Name: `Success`
- Condition Requirements: **All Conditions Are Met (AND)**
- Condition:
  - Resource: `{!varSuccess}`
  - Operator: **Equals**
  - Value: **{!$GlobalConstant.True}**

**Configure Outcome 2: Has Files**
- Label: `Has Files`
- Outcome API Name: `Has_Files`
- Add second outcome by clicking **+ New Outcome**
- Condition Requirements: **All Conditions Are Met (AND)**
- Conditions:
  - Resource: `{!varSuccess}`
  - Operator: **Equals**
  - Value: **{!$GlobalConstant.True}**
  - AND
  - Resource: `{!varTotalFiles}`
  - Operator: **Greater Than**
  - Value: `0`

Actually, let's simplify. Keep it as:

**Outcome: Success**
- Condition: `{!varSuccess}` Equals `True` AND `{!varTotalFiles}` Greater Than `0`

**Default Outcome:**
- Label: `Error`

4. Click **Done**

### Step 5: Add Action - Call Prompt Template

From the **Success** outcome path:

1. Click **+**
2. Select **Action**
3. In search, type your prompt template name: `Account Multi-Opportunity Contract Comparison`
4. Select the prompt template
5. Label: `Analyze Contracts with AI`
6. API Name: `Analyze_Contracts_with_AI`

**Map Input Parameters:**

| Prompt Input | Flow Variable | 
|--------------|---------------|
| accountName | `{!varAccountName}` |
| opportunityCount | `{!varOppCount}` |
| totalFiles | `{!varTotalFiles}` |
| fileSummary | `{!varFileSummary}` |

**Store Output:**
- Output: **Response** (or Generated Text)
- Store in: `{!varAnalysisResult}`

7. Click **Done**

### Step 6: Add Screen - Display Results

1. Click **+** after the prompt action
2. Select **Screen**
3. Label: `Display Contract Analysis`
4. API Name: `Display_Contract_Analysis`

**Configure Screen:**

**Component 1: Section (Optional)**
- Add a **Section** component
- Label: `Contract Comparison Results`

**Component 2: Display Text - Header**
- Find **Display Text** in components
- Drag to screen
- Label: *(leave empty)*
- API Name: `Header_Text`
- In the text box, click **</> (Source)** button and paste:

```html
<p style="font-size: 18px; font-weight: bold; color: #032d60;">🔍 Multi-Opportunity Contract Analysis</p>
<p style="font-size: 14px; color: #706e6b; margin-top: 8px;">
  <strong>Account:</strong> {!varAccountName}<br/>
  <strong>Opportunities Analyzed:</strong> {!varOppCount}<br/>
  <strong>Contract Files Reviewed:</strong> {!varTotalFiles}
</p>
<hr style="border: 0; border-top: 2px solid #e5e5e5; margin: 16px 0;" />
```

**Component 3: Display Text - AI Analysis**
- Add another **Display Text** component
- Label: *(leave empty)*
- API Name: `AI_Analysis_Output`
- In the text editor, insert: `{!varAnalysisResult}`
- In **Advanced** section:
  - Allow Rich Text: ✅ Checked (if available)

**Component 4: Display Text - Raw File Summary (Optional)**
- Add another **Display Text** component
- Label: `Document Details (Expand to View)`
- API Name: `Raw_File_Details`
- In the text editor, insert: `{!varFileSummary}`
- In **Advanced** section:
  - Make this collapsible or put in an accordion

**Screen Navigation Settings:**
- Show Previous: ❌ Unchecked
- Show Finish: ✅ Checked
- Finish Button Label: `Close`

5. Click **Done**

### Step 7: Add Screen - Error/No Files Screen

From the **Error** outcome path:

1. Click **+**
2. Select **Screen**
3. Label: `Error Screen`
4. API Name: `Error_Screen`

**Add Component: Display Text**
- API Name: `Error_Message`
- Click **</> Source** and paste:

```html
<div style="padding: 20px; background-color: #fef5e7; border-left: 4px solid #f39c12; border-radius: 4px;">
  <p style="font-size: 16px; font-weight: bold; color: #d35400; margin-bottom: 8px;">⚠️ Unable to Retrieve Contract Files</p>
  <p style="color: #7d6608; margin-bottom: 12px;">
    No contract files were found for this account. This could be because:
  </p>
  <ul style="color: #7d6608; margin-left: 20px;">
    <li>No opportunities exist for this account</li>
    <li>No files are attached to opportunities</li>
    <li>Files are not in supported formats (PDF, DOCX)</li>
  </ul>
  <p style="color: #7d6608; margin-top: 12px; font-style: italic;">
    Please ensure opportunities have MSA or SOW files attached.
  </p>
</div>
```

**Screen Navigation:**
- Show Finish: ✅ Checked
- Finish Button Label: `Close`

4. Click **Done**

### Step 8: Save the Flow

1. Click **Save**
2. Fill in:
   - Flow Label: `Account Contract Comparison`
   - Flow API Name: `Account_Contract_Comparison`
   - Description: `Analyzes and compares contract terms across all opportunities for an account`
   - API Version for Running the Flow: *(leave default)*
3. Click **Save**

### Step 9: Debug the Flow (Optional)

1. Click **Debug**
2. Set `recordId` to a test Account ID
3. Click **Run**
4. Check for errors
5. Fix any issues

### Step 10: Activate the Flow

1. Click **Activate**
2. Confirm activation
3. ✅ Flow is now ready to add to pages!

---

## Part 3: Add Flow to Account Page

### Step 1: Navigate to Account Record Page

1. Go to any **Account** record
2. Click the **⚙️ Setup Gear** (top right)
3. Select **Edit Page**
4. Lightning App Builder opens

### Step 2: Add Flow Component

1. In the **left sidebar**, find the **Components** section
2. Search for: **Flow**
3. Drag the **Flow** component to your desired location on the page
   - Recommended: Add below "Related Lists" or in a new tab
   - Or create a new tab called "Contract Analysis"

### Step 3: Configure the Flow Component

Click on the Flow component you just added. In the **properties panel** on the right:

**Configuration:**
- **Flow:** Select `Account Contract Comparison` (from dropdown)
- **Pass Record ID into this variable:** Select `recordId`
- **Input Attributes:** (should auto-populate)
  - recordId: `{!recordId}`

**Display Options:**
- **Label:** `Contract Analysis` (or leave blank)
- **Height:** `800px` (adjust based on preference)

### Step 4: Save the Page

1. Click **Save** (top right)
2. If it's a new page, name it: `Account Record Page`

### Step 5: Activate the Page

1. Click **Activation...**
2. Choose activation option:
   - **App, Record Type, and Profile:** For specific assignments
   - **Org Default:** To make it default for all accounts
3. For testing, choose **Org Default** and select:
   - **Desktop and phone**
   - Click **Next**
4. Select the **App** to assign to (e.g., Sales)
5. Click **Save**

---

## Part 4: Test Your Flow

### Step 1: Prepare Test Data

**Create a test account:**
1. Account Name: `Global Tech Solutions (Test)`
2. Save

**Create 2-3 opportunities:**

**Opportunity 1:**
- Name: `Enterprise License - 2024`
- Account: Global Tech Solutions (Test)
- Stage: Proposal/Price Quote
- Amount: $500,000
- Close Date: 30 days from today

**Opportunity 2:**
- Name: `Renewal - 2024`
- Account: Global Tech Solutions (Test)
- Stage: Negotiation/Review
- Amount: $250,000
- Close Date: 45 days from today

**Opportunity 3:**
- Name: `Expansion Deal`
- Account: Global Tech Solutions (Test)
- Stage: Closed Won
- Amount: $150,000
- Close Date: Today

**Upload files to each opportunity:**

For **Opportunity 1:**
- Upload 2 PDFs or Word docs
- Rename them: `MSA_Enterprise_2024.pdf` and `SOW_Enterprise_2024.docx`

For **Opportunity 2:**
- Upload 1 PDF
- Rename: `Renewal_Contract_2024.pdf`

For **Opportunity 3:**
- Upload 1 PDF
- Rename: `Expansion_MSA.pdf`

### Step 2: Run the Flow

1. Navigate to: **Global Tech Solutions (Test)** account
2. Scroll to the **Contract Analysis** section
3. The flow should auto-start (or click **Run Flow**)
4. Wait 5-15 seconds for processing
5. Review the analysis screen

### Step 3: Verify Output

You should see a screen with:

**Header:**
```
🔍 Multi-Opportunity Contract Analysis
Account: Global Tech Solutions (Test)
Opportunities Analyzed: 3
Contract Files Reviewed: 4
```

**AI Analysis:**
- Executive Summary
- Comparison table showing contract terms
- Inconsistencies (if any)
- Risk assessment
- Recommendations
- Missing terms
- Document inventory

### Step 4: Test Error Handling

1. Navigate to an account with **no opportunities**
2. Run the flow
3. Should show: "Unable to Retrieve Contract Files" screen
4. ✅ Error handling works!

---

## Part 5: Customize for Your Needs

### Option 1: Add Email Alert

After the AI analysis, send results to the account owner.

**Steps:**
1. Edit the flow
2. After the "Analyze Contracts with AI" action
3. Add: **Action > Send Email**
4. Configure:
   - To Address: `{!Account.Owner.Email}` (you'll need to query Account first)
   - Subject: `Contract Analysis Complete - {!varAccountName}`
   - Body: `{!varAnalysisResult}`
   - HTML Body: ✅ Checked

### Option 2: Create Follow-Up Task

Create a task for the account owner to review findings.

**Steps:**
1. After AI analysis
2. Add: **Create Records**
3. Object: **Task**
4. Set Field Values:
   - Subject: `Review Contract Analysis - {!varAccountName}`
   - Description: `{!varAnalysisResult}`
   - WhatId: `{!recordId}` (relates to account)
   - OwnerId: `{!$User.Id}` (or account owner)
   - Priority: High
   - Status: Not Started
   - ActivityDate: `{!$Flow.CurrentDate + 3}` (due in 3 days)

### Option 3: Save Results to Account

Store analysis results in a custom Long Text Area field on Account.

**Steps:**
1. Create custom field: **Contract_Analysis_Results__c** (Long Text Area, 131,072 chars)
2. Add to flow after AI analysis
3. Add: **Update Records**
4. Object: **Account**
5. Find Record: Where `Id` = `{!recordId}`
6. Set Field Values:
   - Contract_Analysis_Results__c: `{!varAnalysisResult}`
   - Contract_Analysis_Date__c: `{!$Flow.CurrentDate}` (if you create this field)

### Option 4: Filter by File Types

Only analyze specific file types.

**Modify Action Input:**
- File Types Filter: `pdf` (only PDFs)
- Or: `pdf,docx,doc,txt`

### Option 5: Add File Count Threshold

Only run analysis if there are enough files.

**After "Get Account Opportunity Files" action:**
1. Add **Decision**: Check File Count
2. Condition: `{!varTotalFiles}` Greater Than or Equal `2`
3. If true: Continue to AI analysis
4. If false: Show screen "Need at least 2 contract files"

---

## Troubleshooting

### Problem: Flow doesn't appear on Account page

**Solutions:**
- Verify flow is **Activated**
- Check `recordId` variable has "Available for input" ✅ checked
- Refresh the account page (Ctrl/Cmd + R)
- Clear browser cache
- Check page assignment (Activation settings)

### Problem: "No files retrieved" error

**Solutions:**
- Verify opportunities exist for the account
- Check files are attached to opportunities
- Ensure file types match filter (pdf, docx)
- Verify user has ContentDocument read permissions
- Check Sharing Settings for files

### Problem: AI response is too generic

**Solutions:**
- Ensure `varFileSummary` is being populated correctly
- Add **Debug** after action to verify file summary content
- Refine prompt template to be more specific
- Check file content is accessible (not just filenames)
- Increase detail in prompt instructions

### Problem: Flow times out

**Solutions:**
- Reduce `Max Total Files` to 10-15
- Simplify prompt template
- Check for large file sizes (AI may take longer)
- Split analysis into multiple prompts

### Problem: Formatting looks broken

**Solutions:**
- Ensure Display Text components use **Rich Text** mode
- Check HTML tags in prompt template are correct
- Test prompt in Prompt Builder first
- Use markdown instead of HTML in prompt

---

## Best Practices

### 1. File Naming Conventions

Train users to name files consistently:

✅ **Good Names:**
- `Acme_MSA_2024.pdf`
- `SOW_Enterprise_Q1_2024.docx`
- `Amendment_01_Acme.pdf`

❌ **Bad Names:**
- `Document1.pdf`
- `Untitled.docx`
- `final_final_v2.pdf`

### 2. Document Organization

Create guidelines:
- Attach MSAs to the **first/primary** opportunity
- Attach SOWs to **each** opportunity
- Use consistent file naming across opportunities
- Add document version numbers

### 3. Regular Analysis

Run analysis:
- Before QBRs (Quarterly Business Reviews)
- Before renewals
- When adding new opportunities
- During contract negotiations

### 4. Refine Prompts Over Time

- Collect user feedback on AI analysis quality
- Add industry-specific terms to prompt
- Reference your company's standard contract clauses
- A/B test different prompt variations

### 5. Security and Permissions

- Ensure only appropriate users can run the flow
- Consider profile-based page assignments
- Add field-level security for any custom fields
- Audit file access permissions

---

## Summary

You've successfully created:

✅ **Prompt Template** - Compares contracts across opportunities  
✅ **Screen Flow** - Retrieves files and calls AI  
✅ **Account Page Integration** - Accessible from any account  
✅ **Error Handling** - Graceful failure messages  
✅ **Formatted Output** - Clean, readable analysis  

**Time Saved:** 45-60 minutes per account review  
**Insights Gained:** Contract inconsistencies, risk assessment, recommendations  
**Next Step:** Roll out to your Deal Desk and Sales teams!

---

## Related Resources

- **ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md** - Alternative approach
- **OPPORTUNITY_FILES_RETRIEVER_GUIDE.md** - Single opportunity analysis
- **Salesforce Flow Documentation** - Flow best practices
- **Prompt Builder Guide** - AI prompt optimization

---

**🎉 Congratulations! You can now compare contracts across opportunities with AI!**

Questions? Check the troubleshooting section or Salesforce help docs.


