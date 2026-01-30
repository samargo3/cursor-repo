# Account-Level Contract Analysis Guide

## Overview

The **AccountOpportunityFilesRetriever** action enables **account-level contract analysis** by retrieving files from all Opportunities associated with an Account. This is perfect for:

- 🤖 **AI-powered contract analysis** across multiple deals
- 📊 **Cross-opportunity document comparison**
- ✅ **Account-wide compliance checking**
- 📋 **Contract portfolio review**
- 🔍 **Risk assessment across customer relationships**

---

## What It Does

Unlike the single-opportunity file retriever, this action:

1. Takes an **Account ID** as input
2. Finds **all Opportunities** for that Account
3. Retrieves **all files** from those Opportunities in one efficient query
4. **Groups files by Opportunity** for organized analysis
5. Returns **aggregated summary** perfect for AI/Prompt Builder
6. Provides **account-level insights** across the entire relationship

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Multi-Opportunity Retrieval** | Gets files from all opportunities at once |
| **Efficient Querying** | Uses optimized SOQL to minimize queries |
| **Grouped Results** | Files organized by opportunity |
| **AI-Ready Output** | Formatted summaries for Prompt Builder |
| **Filtering** | Filter by file types across all opportunities |
| **Limiting** | Control files per opportunity or total |
| **Complete Metadata** | Full file details for each document |

---

## Input Parameters

| Parameter | Required | Type | Example | Description |
|-----------|----------|------|---------|-------------|
| **Account ID** | ✓ | ID | `{!accountId}` | The Account to analyze |
| **File Types Filter** | ✗ | Text | `pdf,docx` | Comma-separated extensions |
| **Max Files Per Opportunity** | ✗ | Number | `5` | Limit per opportunity |
| **Max Total Files** | ✗ | Number | `20` | Total limit across all |

---

## Output Parameters

### Summary Outputs

| Output | Type | Description |
|--------|------|-------------|
| **Success** | Boolean | Operation success status |
| **Error Message** | Text | Error details if failed |
| **Account ID** | ID | The Account ID queried |
| **Account Name** | Text | Name of the Account |
| **Opportunity Count** | Number | Total opportunities found |
| **Total File Count** | Number | Total files across all opps |
| **Total Size** | Number | Combined size in bytes |
| **Formatted Total Size** | Text | Human-readable size |
| **Aggregated File Summary** | Text | AI-friendly formatted summary |
| **Message** | Text | Result message |

### Detailed Output

| Output | Type | Description |
|--------|------|-------------|
| **Files By Opportunity** | Collection | List of OpportunityFiles objects |

### OpportunityFiles Object

Each item in the collection contains:

| Field | Type | Description |
|-------|------|-------------|
| **Opportunity ID** | ID | Opportunity identifier |
| **Opportunity Name** | Text | Name of the opportunity |
| **Opportunity Stage** | Text | Current stage |
| **Opportunity Amount** | Currency | Deal amount |
| **File Count** | Number | Files for this opportunity |
| **Total Size** | Number | Size for this opportunity |
| **Formatted Total Size** | Text | Readable size |
| **File Summary** | Text | Summary for this opportunity |
| **File Details** | Collection | List of FileDetail objects |

---

## Example Output

### Aggregated File Summary (AI-Ready)

```
ACCOUNT-LEVEL CONTRACT ANALYSIS
==================================================

Account: Acme Corporation
Total Opportunities: 3
Opportunities with Files: 3
Total Contract Files: 8
Total Size: 12.5 MB

==================================================

OPPORTUNITY 1: Enterprise Deal Q1
Stage: Proposal/Price Quote
Amount: $500,000
Files: 3 (5.2 MB)
----------------------------------------
  1. Master Service Agreement.pdf
     Type: PDF | Size: 2.5 MB | Uploaded: 2024-01-15 10:30 AM
  2. Statement of Work.docx
     Type: DOCX | Size: 1.8 MB | Uploaded: 2024-01-16 2:15 PM
  3. Pricing Schedule.xlsx
     Type: XLSX | Size: 890 KB | Uploaded: 2024-01-17 9:00 AM

OPPORTUNITY 2: Renewal Deal
Stage: Negotiation/Review
Amount: $250,000
Files: 2 (3.1 MB)
----------------------------------------
  1. Renewal Contract.pdf
     Type: PDF | Size: 2.3 MB | Uploaded: 2024-02-01 11:45 AM
  2. Amendment 1.pdf
     Type: PDF | Size: 810 KB | Uploaded: 2024-02-05 3:20 PM

OPPORTUNITY 3: Expansion Deal
Stage: Prospecting
Amount: $150,000
Files: 3 (4.2 MB)
----------------------------------------
  1. SOW Expansion.docx
     Type: DOCX | Size: 1.9 MB | Uploaded: 2024-03-10 1:00 PM
  2. MSA Amendment.pdf
     Type: PDF | Size: 1.5 MB | Uploaded: 2024-03-12 4:30 PM
  3. Security Addendum.pdf
     Type: PDF | Size: 800 KB | Uploaded: 2024-03-13 10:15 AM
```

---

## Use Case: AI Contract Analysis Across Multiple Opportunities

### Step-by-Step Flow Setup

**Flow Type:** Screen Flow or Autolaunched Flow  
**Starting Context:** Account Record Page or Opportunity Record Page

#### Flow Structure

**1. Get Account ID**

If starting from Opportunity page:
```
Element: Get Records
Object: Opportunity
Conditions: Id = {!recordId}
Store: $Record
Assign: accountId = {!$Record.AccountId}
```

If starting from Account page:
```
Variable: accountId = {!recordId}
```

**2. Get Account Opportunity Files**

```
Element: Action
Action: Get Account Opportunity Files

Input Variables:
  - Account ID: {!accountId}
  - File Types Filter: "pdf,docx"
  - Max Files Per Opportunity: leave blank (get all)
  - Max Total Files: leave blank (get all)

Output Variables:
  - Success → varSuccess
  - Aggregated File Summary → varFileSummary
  - Total File Count → varTotalFiles
  - Files By Opportunity → varFilesByOpp
```

**3. Check Success**

```
Element: Decision
Condition: {!varSuccess} Equals True

Outcome: Success
  → Continue to prompt generation

Outcome: Failure
  → Show error screen
```

**4. Generate AI Prompt**

```
Element: Action
Action: Generate Prompt with Template

Template: Account Contract Analysis

Context Variables:
  - Account Name: {!Get_Account_Opportunity_Files.Account_Name}
  - File Summary: {!Get_Account_Opportunity_Files.Aggregated_File_Summary}
  - Total Files: {!Get_Account_Opportunity_Files.Total_File_Count}
  - Opportunity Count: {!Get_Account_Opportunity_Files.Opportunity_Count}
```

**5. Display Results**

```
Element: Screen
Title: "Contract Analysis for {!Get_Account_Opportunity_Files.Account_Name}"

Components:
  - Display Text: Account summary
  - Display Text: AI analysis results
  - Display Text: Recommendations
```

---

## Prompt Template Example

### Template: Account Contract Analysis

```yaml
Name: Account Contract Analysis
Description: Analyzes all contracts across opportunities for an account
Category: Contract Management
```

**Prompt Body:**

```
You are a legal and sales operations expert analyzing contracts for a customer account.

CONTEXT:
{!GetAccountOpportunityFiles.Aggregated_File_Summary}

ANALYSIS TASKS:

1. COMMON TERMS ANALYSIS
   - Identify payment terms across all contracts
   - Find common SLA/uptime requirements
   - Note liability caps and limitations
   - Highlight any special terms

2. CONSISTENCY CHECK
   - Are payment terms consistent across opportunities?
   - Are there conflicting clauses between contracts?
   - Do newer contracts reference older agreements?
   - Are amendments properly linked?

3. RISK ASSESSMENT
   - Identify non-standard or risky terms
   - Flag any missing standard documents
   - Assess overall risk level (Low/Medium/High)
   - Note any compliance concerns

4. MISSING DOCUMENTS
   Standard documents for each opportunity should include:
   - Master Service Agreement (MSA) or Contract
   - Statement of Work (SOW)
   - Pricing/Quote document
   - Security/Compliance documents (if applicable)
   
   List any missing documents by opportunity.

5. CONTRACT VALUE ANALYSIS
   - What is the total contract value across opportunities?
   - Are there volume discounts or account-level terms?
   - Note any recurring revenue terms

6. RECOMMENDATIONS
   - Suggest contract consolidation opportunities
   - Recommend standardization of terms
   - Propose risk mitigation strategies
   - Identify upsell/cross-sell opportunities based on contracts

FORMAT YOUR RESPONSE:
Use clear sections with headers for each analysis task.
Be specific and reference opportunity names when citing examples.
Prioritize findings by importance (Critical, Important, Informational).
```

**Input Resources:**

| Resource | Source | Value |
|----------|--------|-------|
| Account Name | Flow Variable | `{!accountName}` |
| File Summary | Flow Action Output | `{!GetAccountOpportunityFiles.Aggregated_File_Summary}` |
| Total Files | Flow Action Output | `{!GetAccountOpportunityFiles.Total_File_Count}` |
| Opportunity Count | Flow Action Output | `{!GetAccountOpportunityFiles.Opportunity_Count}` |

**Output Variables:**

| Variable | Description |
|----------|-------------|
| Analysis Text | Complete AI analysis |
| Risk Level | Overall risk (Low/Medium/High) |
| Recommendations | List of recommendations |

---

## Advanced Use Cases

### 1. Executive Account Review

**Scenario:** Prepare for executive business review with key account

```
Flow:
1. Get Account Opportunity Files (pdf,docx only)
2. Generate AI analysis
3. Create summary dashboard
4. Send email to account team with insights
```

### 2. Contract Renewal Preparation

**Scenario:** Preparing for account renewal, need to review all existing contracts

```
Flow:
1. Get Account Opportunity Files
2. Filter for contracts older than 12 months
3. Analyze for renewal opportunities
4. Create renewal proposal based on existing terms
```

### 3. Compliance Audit

**Scenario:** Legal team needs to audit all contracts for compliance

```
Flow:
1. Get Account Opportunity Files
2. Check for required security addendums
3. Verify payment terms compliance
4. Flag any non-standard terms
5. Generate compliance report
```

### 4. Cross-Opportunity Pricing Analysis

**Scenario:** Analyze pricing consistency across opportunities

```
Flow:
1. Get Account Opportunity Files (xlsx, pdf with "pricing")
2. AI extracts pricing from each document
3. Compare pricing across opportunities
4. Flag inconsistencies or volume discount opportunities
```

---

## Looping Through Files By Opportunity

If you need to process files programmatically:

### Loop Configuration

```
Element: Loop
Collection Variable: {!Get_Account_Opportunity_Files.Files_By_Opportunity}
Current Item Variable: CurrentOpportunity (OpportunityFiles type)
```

### Inside Loop - Access Properties

```
Current Opportunity:
  - Name: {!CurrentOpportunity.Opportunity_Name}
  - Stage: {!CurrentOpportunity.Opportunity_Stage}
  - Amount: {!CurrentOpportunity.Opportunity_Amount}
  - File Count: {!CurrentOpportunity.File_Count}

Nested Loop - Files for This Opportunity:
  Collection: {!CurrentOpportunity.File_Details}
  Current Item: CurrentFile (FileDetail type)
  
  Access:
    - Title: {!CurrentFile.Title}
    - Extension: {!CurrentFile.File_Extension}
    - Size: {!CurrentFile.Formatted_Size}
    - Download URL: {!CurrentFile.Download_URL}
```

### Example: Build Custom Report

```
Assignment:
  reportText = {!reportText} & "Opportunity: " & {!CurrentOpportunity.Opportunity_Name} & "\n"
  reportText = {!reportText} & "Files: " & {!CurrentOpportunity.File_Count} & "\n"
  reportText = {!reportText} & "Total Size: " & {!CurrentOpportunity.Formatted_Total_Size} & "\n\n"
```

---

## Filtering Strategies

### Get Contract Documents Only

```
Input:
  - File Types Filter: "pdf,docx"
```

This retrieves only PDFs and Word documents (typical contracts).

### Get Recent Documents Only

Use in combination with Date filters in Flow:

```
1. Get Account Opportunity Files (all types)
2. Loop through Files By Opportunity
3. Filter File Details where Created Date > Last 90 Days
4. Build filtered collection
```

### Get Documents by Opportunity Stage

```
1. Get Account Opportunity Files
2. Loop through Files By Opportunity
3. Filter where Opportunity Stage = "Negotiation/Review"
4. Process only negotiation-stage files
```

---

## Performance Optimization

### Efficient Querying

The action uses optimized SOQL:
- **2 queries total** (Account validation + file retrieval)
- Bulk retrieval of all files in one query
- No queries inside loops
- Efficient for accounts with many opportunities

### Recommended Limits

For optimal performance:

| Scenario | Max Files Per Opp | Max Total Files |
|----------|-------------------|-----------------|
| **Quick Analysis** | 5 | 20 |
| **Standard Review** | 10 | 50 |
| **Comprehensive Audit** | Leave blank | Leave blank |
| **Large Accounts** | 5 | 100 |

### Governor Limits

| Limit Type | Usage |
|------------|-------|
| SOQL Queries | 2 (Account + Files) |
| Records Retrieved | Depends on files, typically <2000 |
| Heap Size | Minimal (metadata only) |
| CPU Time | Low (~100-500ms) |

---

## Error Handling

### Check Success Status

Always check the Success variable:

```
Decision: Check Success
  Outcome: Success = True
    → Process files normally
    
  Outcome: Success = False
    → Display error message
    → Log error for troubleshooting
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Account not found" | Invalid Account ID | Verify recordId is an Account |
| "No opportunities found" | Account has no opportunities | This is informational, not an error |
| "Error retrieving files" | SOQL/permission issue | Check user permissions |

### Handling No Files Scenario

```
Decision: Has Files?
  Condition: {!Total_File_Count} Greater Than 0
  
  Outcome: Has Files
    → Continue with analysis
    
  Outcome: No Files
    → Display message: "No contracts found for this account"
    → Suggest uploading files
```

---

## Integration with Agentforce

### Agentforce Agent Configuration

**Agent Name:** Account Contract Analyzer

**Agent Instructions:**
```
You are an account contract analysis expert. When invoked:

1. Use the Get Account Opportunity Files action to retrieve all contracts
2. Analyze the contracts for:
   - Payment terms consistency
   - Risk factors
   - Missing documents
   - Renewal opportunities
3. Provide actionable recommendations
4. Summarize findings in executive format
```

**Available Actions:**
- Get Account Opportunity Files
- Send Email
- Create Task
- Update Opportunity

**Example Agent Conversation:**

```
User: "Analyze contracts for Acme Corporation"

Agent: 
1. [Calls: Get Account Opportunity Files with Account ID]
2. [Receives: 8 files across 3 opportunities]
3. [Analyzes: Contract terms and consistency]
4. [Responds with summary]

Agent Response:
"I've analyzed 8 contract files across 3 opportunities for Acme Corporation.

KEY FINDINGS:
- All 3 opportunities have MSAs with consistent payment terms (Net 30)
- Missing SOW for the Expansion Deal opportunity
- Liability cap varies: $500K (Enterprise), $250K (Renewal), $150K (Expansion)
  
RECOMMENDATIONS:
1. Create SOW for Expansion Deal before proceeding
2. Standardize liability caps based on deal size
3. Consider master account agreement to consolidate terms

RISK LEVEL: Medium
Would you like me to create a task for the missing SOW?"
```

---

## Best Practices

### 1. Start from the Right Context

✅ **Best:** Start from Account record page  
✅ **Good:** Start from Opportunity page (get Account first)  
❌ **Avoid:** Hardcoding Account IDs  

### 2. Use Appropriate Filters

✅ **Contracts:** Use `pdf,docx` filter  
✅ **Proposals:** Use `pdf,docx,pptx` filter  
✅ **All Docs:** Leave filter blank  

### 3. Set Reasonable Limits

✅ **Quick Review:** Max 5 files per opportunity  
✅ **Full Audit:** No limits  
✅ **Large Accounts:** Set max total files (e.g., 50-100)  

### 4. Leverage AI Effectively

✅ **Do:** Provide full context in prompt  
✅ **Do:** Ask specific questions  
✅ **Do:** Request structured output  
❌ **Don't:** Assume AI has context beyond what you provide  

### 5. Handle Edge Cases

✅ **No Files:** Show helpful message  
✅ **One Opportunity:** Still works, shows account level  
✅ **Many Files:** Use limits to avoid overwhelming output  

---

## Comparison with Single-Opportunity Action

| Feature | Single Opportunity | Account-Level |
|---------|-------------------|---------------|
| **Input** | Opportunity ID | Account ID |
| **Scope** | One opportunity | All opportunities |
| **Queries** | 2 per call | 2 total (bulk) |
| **Best For** | Individual deal analysis | Account portfolio review |
| **Output** | Flat file list | Grouped by opportunity |
| **Use Case** | Screen flows, single deal | AI analysis, executive reviews |

### When to Use Each

**Use OpportunityFileRetriever when:**
- Analyzing a single deal
- Displaying files on Opportunity page
- Simple file list needed
- Quick lookups

**Use AccountOpportunityFilesRetriever when:**
- Analyzing multiple deals
- Account-level contract review
- AI-powered cross-opportunity analysis
- Executive business reviews
- Compliance audits

---

## Testing

Comprehensive test class included: **AccountOpportunityFilesRetriever_Test.cls**

**Test Coverage:** ~95%

**Run Tests:**

```bash
sf apex run test \
  --class-names AccountOpportunityFilesRetriever_Test \
  --result-format human \
  --target-org [your-org-alias]
```

---

## Deployment

### Quick Deploy

```bash
cd demo-igniters

sf project deploy start \
  --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever.cls \
  --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever_Test.cls \
  --target-org [your-org-alias]

# Run tests
sf apex run test \
  --class-names AccountOpportunityFilesRetriever_Test \
  --result-format human \
  --target-org [your-org-alias]
```

See **OPPORTUNITY_FILES_DEPLOYMENT.md** for additional deployment options.

---

## Summary

The **AccountOpportunityFilesRetriever** action enables powerful **account-level contract analysis** by:

✅ Retrieving files from all opportunities at once  
✅ Grouping files by opportunity for organized analysis  
✅ Providing AI-ready formatted summaries  
✅ Enabling cross-opportunity comparison  
✅ Supporting compliance and risk assessment  
✅ Powering executive business reviews  

**Perfect for AI-powered contract analysis across your customer accounts!** 🚀

---

## Next Steps

1. ✅ Deploy the action to your org
2. ✅ Create a test flow on an Account page
3. ✅ Build your first Prompt Template
4. ✅ Configure Agentforce agent (optional)
5. ✅ Train users on account-level analysis

**Happy analyzing!** 📊

