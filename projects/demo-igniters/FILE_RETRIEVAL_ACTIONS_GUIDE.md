# File Retrieval Actions - Complete Guide

> **Four powerful Apex actions to retrieve files from Salesforce for AI analysis, Flows, and reporting**

---

## 📦 Available Actions

| Action | Account Files | Opportunity Files | Status |
|--------|---------------|-------------------|---------|
| 1. **AccountComprehensiveFilesRetriever** | ✅ Direct | ✅ All Opportunities | ✅ Deployed |
| 2. **AccountOpportunityFilesRetriever** | ❌ No | ✅ All Opportunities | ✅ Deployed |
| 3. **AccountFilesRetriever** | ✅ Direct | ❌ No | ✅ Deployed |
| 4. **OpportunityFileRetriever** | ❌ No | ✅ Single Opportunity | ✅ Deployed |

---

## 🎯 Quick Decision Guide

### "I need ALL files for an account"
→ Use **AccountComprehensiveFilesRetriever**
- Gets account files AND opportunity files
- Complete inventory
- Best for comprehensive analysis

### "I need files from opportunities only"
→ Use **AccountOpportunityFilesRetriever**
- Gets files from all opportunities
- Grouped by opportunity
- Best for deal-specific contract analysis

### "I need files directly attached to account"
→ Use **AccountFilesRetriever**
- Gets only account-level attachments
- Best for corporate documents (NDAs, MSAs)

### "I need files from ONE opportunity"
→ Use **OpportunityFileRetriever**
- Gets files from single opportunity
- Best for individual deal analysis

---

## 📊 Detailed Comparison

### 1. AccountComprehensiveFilesRetriever (NEW) ⭐

**Action Name:** `Get All Account and Opportunity Files`

**What It Retrieves:**
- ✅ Files directly attached to Account (CombinedAttachments)
- ✅ Files from ALL related Opportunities (ContentDocumentLink)

**Input:**
- Account ID (required)
- File Types Filter (optional)
- Max Account Files (optional)
- Max Files Per Opportunity (optional)

**Output:**
- Account Files (collection)
- Opportunity Files (collection grouped by opportunity)
- Comprehensive Summary (formatted text)
- Total counts and sizes

**Use Cases:**
- Complete contract portfolio analysis
- Executive business reviews
- Compliance audits (all documents)
- M&A due diligence
- Complete AI context

**Example:**
```
Action: Get All Account and Opportunity Files
Input: Account ID = {!recordId}
Output: Comprehensive Summary → Pass to AI
```

**Documentation:** [ACCOUNT_COMPREHENSIVE_FILES_README.md](./ACCOUNT_COMPREHENSIVE_FILES_README.md)

---

### 2. AccountOpportunityFilesRetriever

**Action Name:** `Get Account Opportunity Files`

**What It Retrieves:**
- ❌ No account files
- ✅ Files from ALL related Opportunities

**Input:**
- Account ID (required)
- File Types Filter (optional)
- Max Files Per Opportunity (optional)
- Max Total Files (optional)

**Output:**
- Files By Opportunity (collection)
- Aggregated File Summary (formatted text)
- Opportunity Count
- Total file counts

**Use Cases:**
- Multi-opportunity contract analysis
- Cross-deal comparison
- Opportunity-specific compliance
- AI contract analysis (deals only)

**Example:**
```
Action: Get Account Opportunity Files
Input: Account ID = {!recordId}, File Types = pdf,docx
Output: Aggregated File Summary → Pass to AI
```

**Documentation:** [ACCOUNT_FILES_README.md](./ACCOUNT_FILES_README.md)

---

### 3. AccountFilesRetriever (NEW)

**Action Name:** `Get Account Files`

**What It Retrieves:**
- ✅ Files directly attached to Account (CombinedAttachments)
- ❌ No opportunity files

**Input:**
- Account ID (required)
- File Types Filter (optional)
- Max Files (optional)

**Output:**
- File Details (collection)
- File Summary (formatted text)
- File Count
- Total size

**Use Cases:**
- Account-level document management
- Corporate document analysis (NDAs, MSAs)
- Account plans and strategies
- Compliance docs (W-9, certificates)

**Example:**
```
Action: Get Account Files
Input: Account ID = {!recordId}, File Types = pdf
Output: File Summary → Display in screen
```

**Documentation:** [ACCOUNT_DIRECT_FILES_README.md](./ACCOUNT_DIRECT_FILES_README.md)

---

### 4. OpportunityFileRetriever

**Action Name:** `Get Opportunity Files`

**What It Retrieves:**
- ❌ No account files
- ✅ Files from ONE Opportunity

**Input:**
- Opportunity ID (required)
- File Types Filter (optional)
- Max Files (optional)

**Output:**
- File Details (collection)
- File Summary (formatted text)
- File Count
- Total size

**Use Cases:**
- Single deal analysis
- Opportunity page displays
- Individual contract review
- Deal-specific compliance

**Example:**
```
Action: Get Opportunity Files
Input: Opportunity ID = {!recordId}
Output: File List → Display on page
```

**Documentation:** [OPPORTUNITY_FILES_README.md](./OPPORTUNITY_FILES_README.md)

---

## 🔥 Common Scenarios

### Scenario 1: Executive Business Review

**Need:** Complete document inventory for QBR

**Action:** **AccountComprehensiveFilesRetriever** ⭐

**Why:** Need both account-level agreements AND all deal contracts

**Flow:**
1. Get All Account and Opportunity Files
2. Generate AI analysis of complete inventory
3. Create executive summary
4. Display on screen

---

### Scenario 2: Deal Desk Contract Analysis

**Need:** Analyze contracts across multiple deals for an account

**Action:** **AccountOpportunityFilesRetriever**

**Why:** Need all deal contracts, account-level docs not needed

**Flow:**
1. Get Account Opportunity Files (pdf,docx only)
2. AI compares terms across deals
3. Identify inconsistencies
4. Generate recommendations

---

### Scenario 3: Account Onboarding Checklist

**Need:** Check if required account docs are uploaded

**Action:** **AccountFilesRetriever**

**Why:** Only checking account-level documents (NDA, W-9, etc.)

**Flow:**
1. Get Account Files
2. Check for required documents:
   - NDA
   - W-9
   - Certificate of Insurance
3. Display checklist with status
4. Show upload button if missing

---

### Scenario 4: Opportunity Close Review

**Need:** Verify all docs present before closing deal

**Action:** **OpportunityFileRetriever**

**Why:** Only checking one opportunity's documents

**Flow:**
1. Get Opportunity Files
2. Check for:
   - Signed contract
   - SOW
   - Pricing document
3. Block close if missing
4. Create tasks

---

## 📋 Feature Matrix

| Feature | Comprehensive | Account Opps | Account Direct | Single Opp |
|---------|--------------|--------------|----------------|------------|
| Account Files | ✅ | ❌ | ✅ | ❌ |
| Opportunity Files | ✅ | ✅ | ❌ | ✅ |
| All Opportunities | ✅ | ✅ | N/A | ❌ |
| Grouped by Opp | ✅ | ✅ | N/A | N/A |
| File Type Filter | ✅ | ✅ | ✅ | ✅ |
| Max Files Limit | ✅ | ✅ | ✅ | ✅ |
| AI-Ready Summary | ✅ | ✅ | ✅ | ✅ |
| Source Tracking | ✅ | ✅ (Opp) | ✅ (Acct) | ✅ (Opp) |
| Complete Inventory | ✅ | ❌ | ❌ | ❌ |

---

## 🎓 Best Practices

### 1. Choose the Right Action

- **Complete analysis?** → Comprehensive
- **Deals only?** → Account Opportunities
- **Account docs only?** → Account Direct
- **One deal?** → Single Opportunity

### 2. Use File Type Filters

```
// Good - only contract files
fileTypes: "pdf,docx"

// Good - only images
fileTypes: "jpg,png"

// Avoid - getting everything when you need specific types
fileTypes: "" (blank)
```

### 3. Set Reasonable Limits

```
// Good for demos
maxFiles: 10

// Good for production with many files
maxFilesPerOpportunity: 5
maxAccountFiles: 10

// Avoid for large accounts
maxFiles: null (unlimited)
```

### 4. Cache Results in Flow

```
// Don't call action multiple times
❌ Call action → Display
   Call action again → Email
   Call action again → Create record

// Do call once, store results
✅ Call action → Store in variables
   Use variables → Display
   Use variables → Email
   Use variables → Create record
```

---

## 🚀 Deployment Status

All actions deployed to **my-new-org**:

```bash
# Check deployment
sf apex list --target-org my-new-org | grep -i "Files"

# Run all tests
sf apex run test \
  --class-names AccountComprehensiveFilesRetriever_Test,AccountOpportunityFilesRetriever_Test,AccountFilesRetriever_Test,OpportunityFileRetriever_Test \
  --target-org my-new-org
```

---

## 📚 Documentation Index

| Action | README | Guide | Tutorial |
|--------|--------|-------|----------|
| **Comprehensive** | [README](./ACCOUNT_COMPREHENSIVE_FILES_README.md) | - | - |
| **Account Opportunities** | [README](./ACCOUNT_FILES_README.md) | [Guide](./ACCOUNT_CONTRACT_ANALYSIS_GUIDE.md) | [Tutorial](./ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md) |
| **Account Direct** | [README](./ACCOUNT_DIRECT_FILES_README.md) | - | - |
| **Single Opportunity** | [README](./OPPORTUNITY_FILES_README.md) | [Guide](./OPPORTUNITY_FILES_RETRIEVER_GUIDE.md) | - |

---

## 🎯 Summary

You now have **4 powerful file retrieval actions**:

1. **Comprehensive** ⭐ - Everything (account + all opportunities)
2. **Account Opportunities** - All deals for an account
3. **Account Direct** - Account-level files only
4. **Single Opportunity** - One deal only

**Choose based on your use case:**
- Need everything? → **Comprehensive**
- Need deals only? → **Account Opportunities**
- Need account docs? → **Account Direct**
- Need one deal? → **Single Opportunity**

---

**All actions are production-ready and tested! 🚀**
