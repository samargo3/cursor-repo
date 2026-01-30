# Account Opportunity Files Retriever

> **Analyze all contracts across multiple opportunities for account-level insights**

---

## 🎯 What It Does

The **AccountOpportunityFilesRetriever** retrieves files from **all Opportunities** for a given Account and provides **aggregated analysis** perfect for:

- 🤖 **AI contract analysis** across multiple deals
- 📊 **Account-wide compliance checking**
- 🔍 **Cross-opportunity document comparison**
- 📋 **Executive business reviews**
- 💼 **Portfolio risk assessment**

---

## ⭐ Key Difference from Single-Opportunity Action

| Feature | OpportunityFileRetriever | AccountOpportunityFilesRetriever |
|---------|--------------------------|----------------------------------|
| **Input** | One Opportunity ID | One Account ID |
| **Scope** | Single opportunity | All opportunities for account |
| **Output** | Flat list of files | Files grouped by opportunity |
| **Best For** | Individual deal review | Account portfolio analysis |
| **SOQL Queries** | 2 per call | 2 total (bulk query) |
| **AI Use Case** | Single contract analysis | Cross-contract comparison |

---

## 🚀 Quick Start

### 1. Deploy

```bash
cd demo-igniters

sf project deploy start \
  --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever.cls \
  --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever_Test.cls \
  --target-org [your-org-alias]
```

### 2. Use in Flow

```
Action: Get Account Opportunity Files
Input:
  - Account ID: {!recordId}
  - File Types Filter: pdf,docx
Output:
  - Aggregated File Summary → Use in Prompt Template
  - Files By Opportunity → Loop for processing
```

### 3. Use in Prompt Template

```
You are analyzing contracts for this account:

{!GetAccountOpportunityFiles.Aggregated_File_Summary}

Analyze for risks, missing documents, and recommendations...
```

---

## 📖 Documentation

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **[ACCOUNT_FILES_README.md](./ACCOUNT_FILES_README.md)** | This file - Quick overview | Start here |
| **[ACCOUNT_CONTRACT_ANALYSIS_GUIDE.md](./ACCOUNT_CONTRACT_ANALYSIS_GUIDE.md)** | Complete usage guide | Building solutions |
| **[ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md](./ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md)** | Step-by-step walkthrough | First implementation |

**Related:** Single-opportunity docs
- [OPPORTUNITY_FILES_README.md](./OPPORTUNITY_FILES_README.md) - Single opportunity action
- [OPPORTUNITY_FILES_RETRIEVER_GUIDE.md](./OPPORTUNITY_FILES_RETRIEVER_GUIDE.md) - Detailed single-opp guide

---

## 💡 Primary Use Case: AI Contract Analysis

### The Problem

You need to analyze all contracts for a customer account:
- ❌ Manual review takes 30-60 minutes per account
- ❌ Files scattered across multiple opportunities
- ❌ Hard to spot inconsistencies between contracts
- ❌ Risk factors hidden across documents

### The Solution

**Automated AI-powered analysis in seconds:**

1. **Retrieve** all files from all opportunities at once
2. **Group** files by opportunity for context
3. **Analyze** using AI Prompt Template
4. **Get** actionable insights and recommendations

**Time saved:** 30-60 minutes per account  
**Insights gained:** Risk assessment, missing docs, term consistency  

---

## 🎯 Input Parameters

| Parameter | Required | Type | Example | Description |
|-----------|----------|------|---------|-------------|
| **Account ID** | ✓ | ID | `{!recordId}` | The Account to analyze |
| **File Types Filter** | ✗ | Text | `pdf,docx` | Comma-separated extensions |
| **Max Files Per Opportunity** | ✗ | Number | `5` | Limit files per opportunity |
| **Max Total Files** | ✗ | Number | `20` | Total file limit |

---

## 📤 Key Output Parameters

### For Display

| Output | Type | Example |
|--------|------|---------|
| **Account Name** | Text | "Acme Corporation" |
| **Opportunity Count** | Number | 3 |
| **Total File Count** | Number | 8 |
| **Formatted Total Size** | Text | "12.5 MB" |
| **Message** | Text | "Found 8 files across 3 opportunities" |

### For AI/Processing

| Output | Type | Description |
|--------|------|-------------|
| **Aggregated File Summary** | Text | Complete formatted summary for AI |
| **Files By Opportunity** | Collection | Loop through opportunities and files |

---

## 📊 Example Output

### Aggregated File Summary (for AI)

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

## 🔥 Real-World Examples

### Example 1: Executive Business Review

**Scenario:** Quarterly business review with key account

**Solution:**
1. Run Account Opportunity Files action
2. AI analyzes all contracts
3. Generate executive summary
4. Present insights to customer

**Output:**
- Contract portfolio overview
- Risk assessment across deals
- Renewal opportunities
- Upsell recommendations

### Example 2: Contract Compliance Audit

**Scenario:** Legal needs to audit all customer contracts

**Solution:**
1. Bulk process accounts
2. Check for required documents
3. Flag non-standard terms
4. Generate compliance report

**Output:**
- Missing document report
- Non-standard terms list
- Compliance score per account
- Remediation tasks

### Example 3: Renewal Preparation

**Scenario:** Preparing for account renewal

**Solution:**
1. Retrieve all existing contracts
2. Analyze current terms
3. Identify expansion opportunities
4. Prepare renewal proposal

**Output:**
- Current contract summary
- Term comparison analysis
- Pricing optimization suggestions
- Renewal proposal draft

---

## 🔧 Implementation Options

### Option A: Screen Flow (Recommended for MVP)

**Complexity:** Low  
**Time:** 30 minutes  
**Best For:** Quick implementation, user-initiated analysis

**Steps:**
1. Create Screen Flow
2. Add Get Account Opportunity Files action
3. Add Prompt Template call
4. Display results
5. Add to Account page

See: [ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md](./ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md)

### Option B: Autolaunched Flow

**Complexity:** Medium  
**Time:** 45 minutes  
**Best For:** Scheduled analysis, automated reports

**Steps:**
1. Create Autolaunched Flow
2. Get Records: Accounts to analyze
3. Loop through accounts
4. Call action for each
5. Aggregate results
6. Send report email

### Option C: Agentforce Agent

**Complexity:** Medium-High  
**Time:** 60 minutes  
**Best For:** Conversational analysis, on-demand insights

**Steps:**
1. Create Agentforce Agent
2. Add Get Account Opportunity Files as action
3. Configure instructions
4. Train agent on contract analysis
5. Deploy to users

---

## 🎓 Prompt Template Example

### Basic Template

```yaml
Name: Account Contract Analysis
Description: Analyzes contracts across all opportunities
```

**Prompt:**

```
You are a contract analysis expert.

ACCOUNT CONTEXT:
Account: {!$Input:accountName}
Opportunities: {!$Input:opportunityCount}
Total Files: {!$Input:totalFiles}

DOCUMENTS:
{!$Input:fileSummary}

ANALYZE FOR:
1. Document completeness (MSA, SOW, pricing for each opp)
2. Payment terms consistency
3. Risk factors (liability, SLA, penalties)
4. Missing documents
5. Recommendations

Provide clear, actionable insights.
```

### Advanced Template (Industry-Specific)

Add industry context:

```
INDUSTRY STANDARDS (SaaS):
- Standard payment terms: Net 30
- Required documents: MSA, SOW, DPA, SLA
- Liability cap: 12 months fees
- Uptime SLA: 99.9%

Flag any deviations from these standards.
```

---

## 📈 Performance & Limits

### Efficiency

| Metric | Value |
|--------|-------|
| **SOQL Queries** | 2 total (optimized bulk query) |
| **Processing Time** | 100-500ms typical |
| **Max Opportunities** | No practical limit |
| **Max Files** | Configurable (recommended: 50-100) |

### Governor Limits

✅ Safe for accounts with 100+ opportunities  
✅ Efficient bulk querying  
✅ No queries in loops  
✅ Minimal heap usage  

### Recommended Limits

| Account Size | Max Files Per Opp | Max Total Files |
|--------------|-------------------|-----------------|
| **Small** (1-5 opps) | No limit | No limit |
| **Medium** (6-20 opps) | 10 | 50 |
| **Large** (20+ opps) | 5 | 100 |

---

## ✅ Testing

### Test Class

**AccountOpportunityFilesRetriever_Test.cls**

**Coverage:** ~95%  
**Tests:** 10 comprehensive scenarios

**Run Tests:**

```bash
sf apex run test \
  --class-names AccountOpportunityFilesRetriever_Test \
  --result-format human \
  --target-org [your-org-alias]
```

### Manual Testing Checklist

- [ ] Account with multiple opportunities
- [ ] Account with no opportunities
- [ ] Opportunities with no files
- [ ] File type filtering
- [ ] File limits (per opp and total)
- [ ] Invalid Account ID
- [ ] Large account (20+ opps)
- [ ] AI prompt integration
- [ ] Error handling

---

## 🔐 Security

### Permissions Required

Users need:
- Read on **Account**
- Read on **Opportunity**
- Read on **ContentDocument**
- Read on **ContentDocumentLink**
- **API Enabled**

### Data Access

- Uses `with sharing` - respects org sharing rules
- Users see only files they have access to
- No privilege escalation
- Download URLs respect Salesforce security

---

## 🆚 Comparison Table

### When to Use Each Action

| Scenario | Use This Action |
|----------|-----------------|
| **Single deal analysis** | OpportunityFileRetriever |
| **Display files on Opportunity page** | OpportunityFileRetriever |
| **Quick file list** | OpportunityFileRetriever |
| **Account portfolio review** | AccountOpportunityFilesRetriever |
| **AI contract analysis across deals** | AccountOpportunityFilesRetriever |
| **Executive business review** | AccountOpportunityFilesRetriever |
| **Compliance audit** | AccountOpportunityFilesRetriever |
| **Cross-opportunity comparison** | AccountOpportunityFilesRetriever |

---

## 📦 What's Included

### Apex Classes
- `AccountOpportunityFilesRetriever.cls` - Main action (~500 lines)
- `AccountOpportunityFilesRetriever_Test.cls` - Test class (~400 lines)

### Documentation
- `ACCOUNT_FILES_README.md` - This file (overview)
- `ACCOUNT_CONTRACT_ANALYSIS_GUIDE.md` - Complete guide (~500 lines)
- `ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md` - Step-by-step tutorial (~600 lines)

### Related Files (Single Opportunity)
- `OpportunityFileRetriever.cls` - Single opportunity action
- Full documentation suite

---

## 🚦 Getting Started Path

### For Developers

1. ✅ Read this README
2. ✅ Deploy both actions (single + account)
3. ✅ Run tests
4. ✅ Review ACCOUNT_CONTRACT_ANALYSIS_GUIDE.md
5. ✅ Build test flow

### For Admins

1. ✅ Read this README
2. ✅ Follow ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md
3. ✅ Create Prompt Template
4. ✅ Build Screen Flow
5. ✅ Add to Account page
6. ✅ Train users

### For Users

1. ✅ Navigate to Account record
2. ✅ Scroll to Contract Analysis section
3. ✅ Click "Analyze Contracts"
4. ✅ Review AI insights
5. ✅ Take recommended actions

---

## 🎯 Success Metrics

Track these metrics to measure success:

| Metric | Target |
|--------|--------|
| **Time saved per review** | 30-60 minutes |
| **Accounts analyzed per week** | 10-20+ |
| **Missing docs identified** | 100% accuracy |
| **User adoption** | 80% of account managers |
| **Risk factors flagged** | Early identification |

---

## 🔄 Next Steps

### Immediate (Week 1)
1. Deploy to production/sandbox
2. Test with 3-5 real accounts
3. Refine prompt template
4. Train pilot users

### Short Term (Month 1)
1. Roll out to all account managers
2. Create usage guidelines
3. Monitor adoption
4. Gather feedback

### Long Term (Quarter 1)
1. Expand to other objects (Cases, Custom Objects)
2. Add automated scheduling
3. Integration with other systems
4. Advanced AI models

---

## 💬 Support

Need help?

1. **Documentation:**
   - Start with this README
   - Deep dive: ACCOUNT_CONTRACT_ANALYSIS_GUIDE.md
   - Step-by-step: ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md

2. **Testing:**
   - Run test class
   - Check sample flow
   - Use Flow Debugger

3. **Troubleshooting:**
   - Check permissions
   - Verify data setup
   - Review debug logs

---

## 🎉 Benefits

### For Sales Teams
- ⚡ **Faster account reviews** - Minutes instead of hours
- 📊 **Better insights** - AI-powered analysis
- ✅ **Complete documentation** - No contracts missed
- 🎯 **Focused actions** - Clear recommendations

### For Legal/Compliance
- 🔍 **Complete visibility** - All contracts in one view
- ⚠️ **Risk identification** - Automated flagging
- 📋 **Audit trails** - Document inventory
- ✅ **Compliance checking** - Automated validation

### For Executives
- 📊 **Portfolio insights** - Account-level view
- 💼 **Risk assessment** - Informed decisions
- 📈 **Revenue optimization** - Identify opportunities
- ⏱️ **Time savings** - Automated analysis

---

## 🏁 Summary

The **AccountOpportunityFilesRetriever** enables:

✅ **Multi-opportunity file retrieval** in one action  
✅ **AI-powered contract analysis** across deals  
✅ **Account-level insights** for better decisions  
✅ **Automated compliance** checking  
✅ **Executive-ready reports** in seconds  

**Perfect for account teams, legal, and executives who need comprehensive contract visibility!**

---

## 📚 Related Resources

- **Single Opportunity Action:** [OPPORTUNITY_FILES_README.md](./OPPORTUNITY_FILES_README.md)
- **Deployment Guide:** [OPPORTUNITY_FILES_DEPLOYMENT.md](./OPPORTUNITY_FILES_DEPLOYMENT.md)
- **Quick Reference:** [OPPORTUNITY_FILES_QUICK_REFERENCE.md](./OPPORTUNITY_FILES_QUICK_REFERENCE.md)

---

**Ready to analyze contracts with AI? Start here:** [ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md](./ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md) 🚀

