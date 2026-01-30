# Contract Analysis Flows - Quick Comparison

## Overview

This document compares the **Opportunity-level** and **Account-level** contract analysis flows.

---

## Side-by-Side Comparison

| Aspect | Opportunity Flow (Existing) | Account Flow (New) |
|--------|---------------------------|-------------------|
| **Location** | Opportunity record page | Account record page |
| **Scope** | Single opportunity's files | All opportunities for account |
| **Primary Goal** | Verify compliance with standards | **Compare** terms across opportunities |
| **Data Source** | `{!$RelatedList:Opportunity_Snapshot.CombinedAttachments.Records}` | `AccountOpportunityFilesRetriever` Apex action |
| **Analysis Focus** | Is THIS contract compliant? | Are contracts CONSISTENT across opportunities? |
| **Output** | Checklist of terms found/missing | Comparison table + inconsistencies |

---

## Prompt Comparison

### Opportunity Flow Prompt (Existing)

**Key characteristics:**
- ✅ Analyzes ONE opportunity
- ✅ Checks against company standards
- ✅ Produces a compliance checklist
- ✅ Uses Related List for files

**Prompt snippet:**
```
You are a highly specialized Contractual Clause Analyst for the Deal Desk team. 
Your task is to analyze ALL of the document(s) attached to this opportunity 
and compare its terms against approved company standards.

Only analyze information in these files: 
{!$RelatedList:Opportunity_Snapshot.CombinedAttachments.Records}
```

### Account Flow Prompt (New)

**Key characteristics:**
- ✅ Analyzes MULTIPLE opportunities
- ✅ **Compares** terms across opportunities
- ✅ Identifies **inconsistencies** between contracts
- ✅ Uses Apex action for file retrieval

**Prompt snippet:**
```
You are a highly specialized Contractual Clause Analyst for the Deal Desk team. 
Your task is to analyze ALL documents attached to this account's opportunities 
and COMPARE terms across opportunities to identify inconsistencies, risks, and differences.

DOCUMENTS TO ANALYZE:
{!$Input:fileSummary}

Your goal is to COMPARE contracts across opportunities and identify:
1. Inconsistencies in contract language between opportunities
2. Differences in key terms (payment, liability, SLAs, etc.)
3. Risks from conflicting terms
```

---

## Output Format Comparison

### Opportunity Flow Output

```
════════════════════════════════════════════════════════════════════════════
📄 EXECUTIVE SUMMARY
────────────────────────────────────────────────────────────────────────────
[Summary of THIS opportunity's contract]

════════════════════════════════════════════════════════════════════════════
✅ KEY TERMS CHECKLIST
────────────────────────────────────────────────────────────────────────────
Term                     | Found | File       | Key Quote
─────────────────────────|-------|────────────|──────────────────
Net 30 Payment Terms     | [Y/N] | [filename] | "[quote]"
Limitation of Liability  | [Y/N] | [filename] | "[quote]"
...
```

**Focus:** Did we FIND each term in this contract?

### Account Flow Output

```
════════════════════════════════════════════════════════════════════════════
📄 EXECUTIVE SUMMARY
────────────────────────────────────────────────────────────────────────────
[Summary highlighting consistency/differences ACROSS opportunities]

════════════════════════════════════════════════════════════════════════════
✅ KEY TERMS COMPARISON TABLE
────────────────────────────────────────────────────────────────────────────
Term                    | Opp 1   | Opp 2   | Opp 3   | Status      | Notes
────────────────────────|---------|---------|---------|-------------|──────────────
Payment Terms           | Net 30  | Net 60  | Net 30  | DIFFERS     | Opp 2 different
Limitation of Liability | $500K   | $500K   | $1M     | DIFFERS     | Opp 3 higher
Service Level Agreement | 99.9%   | 99.9%   | 99.9%   | Consistent  | All match
...

════════════════════════════════════════════════════════════════════════════
🔴 CRITICAL INCONSISTENCIES
────────────────────────────────────────────────────────────────────────────
1. Payment Terms Differ
   - Opportunity: Renewal Deal
   - Difference: Net 60 vs. standard Net 30
   - Risk: Revenue recognition delay
```

**Focus:** Are terms CONSISTENT across contracts?

---

## Flow Architecture Comparison

### Opportunity Flow

```
┌─────────────────┐
│ Start (Opp Page)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Get Files from  │
│ Related List    │ ← {!$RelatedList}
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Call Prompt     │
│ Template        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Display Results │
│ (1 Opportunity) │
└─────────────────┘
```

### Account Flow

```
┌─────────────────┐
│ Start (Acct Page)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Get Files from  │
│ ALL Opportunities│ ← Apex Action
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Decision:       │
│ Has Files?      │
└───┬─────────┬───┘
    │         │
   Yes       No
    │         │
    ▼         ▼
┌──────┐  ┌──────┐
│ AI   │  │Error │
│Prompt│  │Screen│
└──┬───┘  └──────┘
   │
   ▼
┌─────────────────┐
│ Display Results │
│ (All Opps)      │
└─────────────────┘
```

---

## When to Use Each Flow

### Use Opportunity Flow When:
- ✅ Deal Desk reviewing a specific deal
- ✅ Need to verify compliance for ONE contract
- ✅ Focused on "Does this meet our standards?"
- ✅ Working within a single opportunity

### Use Account Flow When:
- ✅ Preparing for account reviews (QBR)
- ✅ Need to spot inconsistencies across deals
- ✅ Managing enterprise accounts with multiple contracts
- ✅ Focused on "Are our contracts consistent?"
- ✅ Risk assessment at account level

---

## Key Technical Differences

### Data Retrieval

**Opportunity Flow:**
```apex
// Uses standard Related List
{!$RelatedList:Opportunity_Snapshot.CombinedAttachments.Records}
```

**Account Flow:**
```apex
// Uses custom Apex action
AccountOpportunityFilesRetriever.getFiles(accountId)
// Returns aggregated file summary across ALL opportunities
```

### Prompt Inputs

**Opportunity Flow:**
```
Input: File list from ONE opportunity
Output: Compliance checklist
```

**Account Flow:**
```
Inputs: 
  - accountName (Text)
  - opportunityCount (Number)
  - totalFiles (Number)
  - fileSummary (Text - Long, all opps aggregated)
Output: Comparison analysis
```

### Variables Needed

**Opportunity Flow:**
- recordId (Opportunity ID)
- varFileList (from related list)
- varAnalysis (AI output)

**Account Flow:**
- recordId (Account ID)
- varAccountName
- varOppCount
- varTotalFiles
- varFileSummary
- varAnalysisResult
- varSuccess

---

## Migration Path

If you want to convert an existing Opportunity flow to Account flow:

### Step 1: Change Data Source
❌ Remove: Related List reference  
✅ Add: AccountOpportunityFilesRetriever action

### Step 2: Update Prompt
❌ Remove: "analyze this opportunity"  
✅ Add: "compare across opportunities"

### Step 3: Modify Checklist
❌ Remove: Single Y/N checklist  
✅ Add: Comparison table (Opp 1 | Opp 2 | Opp 3)

### Step 4: Add Inconsistency Section
✅ Add: "CRITICAL INCONSISTENCIES" section to prompt

### Step 5: Change Page Location
❌ Remove: From Opportunity record page  
✅ Add: To Account record page

---

## Example Use Cases

### Opportunity Flow Example

**Scenario:** Deal Desk reviewing Enterprise Deal before approval

**Question:** "Does this contract meet our standards?"

**Action:** 
1. Open opportunity: "Acme Enterprise Deal"
2. Run flow
3. Review checklist

**Output:**
```
✅ Payment Terms: Found - Net 30 - Section 5.2
❌ Limitation of Liability: NOT FOUND
✅ Termination Clause: Found - 90 days - Section 8.1
```

**Decision:** Send back for revision (missing liability clause)

---

### Account Flow Example

**Scenario:** Account Manager preparing for Acme Corp QBR

**Question:** "Are our contracts with Acme consistent?"

**Action:**
1. Open account: "Acme Corporation"
2. Run flow
3. Review comparison

**Output:**
```
🔴 CRITICAL INCONSISTENCIES:

1. Payment Terms Differ
   - Enterprise Deal: Net 30
   - Renewal Deal: Net 60
   - Expansion Deal: Net 30
   Risk: Renewal has longer payment terms

2. Liability Cap Differs
   - Enterprise: $500K cap
   - Renewal: $500K cap  
   - Expansion: $1M cap
   Risk: Inconsistent risk exposure
```

**Decision:** Standardize payment terms and liability caps before next deal

---

## Quick Decision Tree

```
Need to analyze contracts?
         │
         ▼
    ┌─────────┐
    │ How many│
    │  opps?  │
    └────┬────┘
         │
    ┌────┴────┐
    │         │
   ONE     MULTIPLE
    │         │
    ▼         ▼
┌────────┐ ┌────────┐
│  OPP   │ │ACCOUNT │
│ FLOW   │ │ FLOW   │
└────────┘ └────────┘
    │         │
    ▼         ▼
Compliance  Consistency
 Check       Check
```

---

## Summary

| Question | Use This Flow |
|----------|---------------|
| "Does this contract meet our standards?" | **Opportunity Flow** |
| "Are our contracts consistent across the account?" | **Account Flow** |
| "What terms are in this SOW?" | **Opportunity Flow** |
| "Do all our deals have the same payment terms?" | **Account Flow** |
| "Is this deal compliant for legal review?" | **Opportunity Flow** |
| "What's our risk exposure across all deals?" | **Account Flow** |

---

## Next Steps

✅ Implement **Opportunity Flow** for deal approval process  
✅ Implement **Account Flow** for account reviews  
✅ Train Deal Desk on Opportunity Flow  
✅ Train Account Managers on Account Flow  
✅ Consider creating both flows for comprehensive coverage  

---

**Both flows complement each other - deploy both for complete contract visibility! 🎯**


