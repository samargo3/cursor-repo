# Deal Desk Agent - Complete Deployment Plan

> **AI-Powered Contract Analysis Agent for Deal Desk Teams**

**Created:** November 24, 2025  
**Purpose:** Step-by-step guide to deploy an Agentforce agent that assists Deal Desk teams with contract analysis, standards compliance, and risk assessment

---

## 🎯 What You're Building

An **Agentforce Agent** that empowers your Deal Desk team to:

1. ✅ **Answer Questions** - Get instant answers about contract standards and requirements
2. ✅ **Analyze Trends** - Identify patterns across all contract files attached to opportunities
3. ✅ **Upload & Analyze** - Upload draft contracts for automated risk and compliance checking
4. ✅ **Verify Standards** - Check if contracts follow organizational standards
5. ✅ **Extract Insights** - Pull key terms and clauses from unstructured documents

**Business Value:**
- ⏱️ Reduce contract review time from **2 hours → 15 minutes**
- 💰 Save **$75K-100K annually** in manual review costs
- 📈 Improve compliance from **65% → 85%+**
- 🎯 Catch critical issues **before** contracts are signed
- 📊 Enable data-driven insights across your contract portfolio

---

## 📋 Prerequisites

### Required Salesforce Features
- [ ] **Salesforce Enterprise Edition or higher**
- [ ] **Agentforce** (formerly Einstein Bots)
- [ ] **Data Cloud 360** with Unstructured Data capability (for PDF/DOCX analysis)
- [ ] **Lightning Experience** enabled
- [ ] **Prompt Builder** access
- [ ] **Einstein AI** enabled

### Required Permissions
- [ ] Customize Application
- [ ] Manage Flows
- [ ] Manage Prompt Templates
- [ ] View Setup and Configuration
- [ ] Deploy metadata via Salesforce CLI

### Technical Requirements
- [ ] Salesforce CLI installed (`sf` command)
- [ ] Git installed (for version control)
- [ ] Node.js 18+ (for deployment scripts)
- [ ] Access to a Salesforce org (Production, Sandbox, or Scratch Org)

### Skills Needed
- Basic understanding of Salesforce Setup
- Familiarity with Flows
- Basic Apex reading ability (helpful but not required)
- Understanding of AI/RAG concepts (helpful but not required)

---

## 🗺️ High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│         AGENTFORCE AGENT                        │
│    (Deal Desk Contract Analysis Agent)         │
│                                                 │
│  Topics:                                        │
│  1. Contract Standards Inquiry                  │
│  2. Contract Upload & Analysis                  │
│  3. Trend Analysis                              │
│  4. Document Verification                       │
│  5. Standard Language Guidance                  │
└──────────────┬──────────────────────────────────┘
               │
      ┌────────┴─────────┐
      │                  │
┌─────▼──────┐    ┌─────▼────────────────┐
│ SALESFORCE │    │  DATA CLOUD 360      │
│ (Structured│    │  (Unstructured RAG)  │
│  Data)     │    │                      │
│            │    │ • Contract PDFs      │
│ • Accounts │    │ • MSAs, NDAs, SOWs   │
│ • Opps     │    │ • Order Forms        │
│ • Contracts│    │ • Amendments         │
│            │    │                      │
│ SOQL for   │    │ Vector Embeddings +  │
│ trends     │    │ Semantic Search      │
└────────────┘    └──────────────────────┘
      │                  │
      └────────┬─────────┘
               ▼
    ┌──────────────────────┐
    │  INVOCABLE ACTIONS   │
    │                      │
    │ • OpportunityFile    │
    │   Retriever          │
    │ • AccountOpportunity │
    │   FilesRetriever     │
    └──────────────────────┘
```

---

## 📅 Deployment Timeline

### **Phase 1: Foundation** (Week 1, Days 1-3)
- Environment setup
- Deploy Apex classes
- Create custom fields
- Upload sample contract data

### **Phase 2: Data Cloud Configuration** (Week 1, Days 4-5)
- Configure Data Cloud 360
- Set up data ingestion from ContentDocument
- Configure vector embeddings and RAG

### **Phase 3: Agent Build** (Week 2, Days 1-3)
- Create Agentforce agent
- Configure 5 agent topics
- Write agent instructions
- Create knowledge articles for standards

### **Phase 4: Testing & Refinement** (Week 2, Days 4-5)
- End-to-end testing
- Accuracy tuning
- UI/UX refinement
- Performance optimization

### **Phase 5: Production Deployment** (Week 3)
- Deploy to production
- User training
- Monitoring setup
- Feedback collection

**Total Time:** 2-3 weeks for full production deployment

---

## 🚀 Step-by-Step Deployment

## PHASE 1: FOUNDATION SETUP

### Step 1.1: Environment Verification

**Goal:** Ensure your Salesforce org has all required features

**Actions:**

1. **Check Data Cloud 360 availability:**
   ```bash
   sf org display --target-org your-org-alias
   ```

2. **Verify Agentforce is enabled:**
   - Go to **Setup** → **Einstein Setup**
   - Confirm "Einstein Bots" or "Agentforce" is enabled

3. **Verify Prompt Builder access:**
   - Go to **Setup** → **Prompt Builder**
   - Confirm you can create new prompts

4. **Check API access:**
   ```bash
   sf data query --query "SELECT Id FROM Account LIMIT 1" --target-org your-org-alias
   ```

**Expected Result:** All commands succeed, all features visible in Setup

**Troubleshooting:**
- If Data Cloud 360 not available → Contact your Salesforce AE
- If Agentforce not enabled → Enable in Einstein Setup
- If Prompt Builder missing → Check user permissions

---

### Step 1.2: Deploy Apex Classes

**Goal:** Deploy the OpportunityFileRetriever and AccountOpportunityFilesRetriever classes

**Actions:**

1. **Navigate to project directory:**
   ```bash
   cd /Users/sargo/Documents/demo-igniters/demo-igniters
   ```

2. **Set your target org:**
   ```bash
   sf config set target-org your-org-alias
   ```

3. **Deploy OpportunityFileRetriever:**
   ```bash
   sf project deploy start \
     --source-dir force-app/main/default/classes/OpportunityFileRetriever.cls \
     --source-dir force-app/main/default/classes/OpportunityFileRetriever.cls-meta.xml \
     --source-dir force-app/main/default/classes/OpportunityFileRetriever_Test.cls \
     --source-dir force-app/main/default/classes/OpportunityFileRetriever_Test.cls-meta.xml \
     --test-level RunLocalTests \
     --wait 10
   ```

4. **Deploy AccountOpportunityFilesRetriever:**
   ```bash
   sf project deploy start \
     --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever.cls \
     --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever.cls-meta.xml \
     --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever_Test.cls \
     --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever_Test.cls-meta.xml \
     --test-level RunLocalTests \
     --wait 10
   ```

5. **Verify deployment:**
   ```bash
   sf apex run test \
     --class-names OpportunityFileRetriever_Test,AccountOpportunityFilesRetriever_Test \
     --result-format human
   ```

**Expected Result:** All tests pass with >75% code coverage

**Verification Checklist:**
- [ ] Both classes deployed successfully
- [ ] All tests pass
- [ ] Actions visible in Flow Builder (Setup → Flows → New Flow → Add Action → Search "Opportunity Files")

---

### Step 1.3: Create Custom Fields

**Goal:** Add custom fields to Opportunity object for storing contract analysis data

**Actions:**

1. **Go to Setup → Object Manager → Opportunity → Fields & Relationships**

2. **Create these custom fields:**

   **Field 1: Contract Risk Level**
   - Field Label: `Contract Risk Level`
   - Field Name: `Contract_Risk_Level__c`
   - Data Type: Picklist
   - Values:
     - Low
     - Medium
     - High
     - Critical
   - Default: (blank)

   **Field 2: Payment Terms**
   - Field Label: `Payment Terms`
   - Field Name: `Payment_Terms__c`
   - Data Type: Text(100)

   **Field 3: Uptime SLA**
   - Field Label: `Uptime SLA`
   - Field Name: `Uptime_SLA__c`
   - Data Type: Percent(3, 2)

   **Field 4: Rollover Percentage**
   - Field Label: `Rollover Percentage`
   - Field Name: `Rollover_Percentage__c`
   - Data Type: Percent(3, 2)

   **Field 5: Contract Analysis Date**
   - Field Label: `Contract Analysis Date`
   - Field Name: `Contract_Analysis_Date__c`
   - Data Type: Date/Time

   **Field 6: Contract Analysis Summary**
   - Field Label: `Contract Analysis Summary`
   - Field Name: `Contract_Analysis_Summary__c`
   - Data Type: Long Text Area (32,000 characters)

   **Field 7: Missing Documents**
   - Field Label: `Missing Documents`
   - Field Name: `Missing_Documents__c`
   - Data Type: Long Text Area (5,000 characters)

3. **Add fields to Opportunity page layout:**
   - Go to Setup → Object Manager → Opportunity → Page Layouts
   - Edit your default layout
   - Add new section: "Contract Analysis"
   - Drag all new fields into this section

**Expected Result:** All 7 fields visible on Opportunity record page

---

### Step 1.4: Create Test Data

**Goal:** Create sample accounts, opportunities, and contract files for testing

**Option A: Use existing data (if you have it)**
- Identify 3-5 opportunities with real contract files attached
- Skip to Step 1.5

**Option B: Create sample data (recommended for demo/testing)**

1. **Create sample accounts:**

   ```javascript
   // Execute in Developer Console (Anonymous Apex)
   List<Account> accounts = new List<Account>{
       new Account(Name = 'TechCorp International', Industry = 'Technology', AnnualRevenue = 5000000),
       new Account(Name = 'DataFlow Systems', Industry = 'Software', AnnualRevenue = 3000000),
       new Account(Name = 'CloudVision Inc', Industry = 'Cloud Services', AnnualRevenue = 8000000)
   };
   insert accounts;
   System.debug('Created ' + accounts.size() + ' accounts');
   ```

2. **Create sample opportunities:**

   ```javascript
   List<Account> accounts = [SELECT Id FROM Account WHERE Name IN ('TechCorp International', 'DataFlow Systems', 'CloudVision Inc')];
   
   List<Opportunity> opps = new List<Opportunity>{
       new Opportunity(
           Name = 'TechCorp MSA Renewal',
           AccountId = accounts[0].Id,
           StageName = 'Negotiation/Review',
           CloseDate = Date.today().addDays(30),
           Amount = 500000
       ),
       new Opportunity(
           Name = 'DataFlow Enterprise Deal',
           AccountId = accounts[1].Id,
           StageName = 'Proposal/Price Quote',
           CloseDate = Date.today().addDays(45),
           Amount = 350000
       ),
       new Opportunity(
           Name = 'CloudVision Expansion',
           AccountId = accounts[2].Id,
           StageName = 'Prospecting',
           CloseDate = Date.today().addDays(60),
           Amount = 750000
       )
   };
   insert opps;
   System.debug('Created ' + opps.size() + ' opportunities');
   ```

3. **Create sample contract PDFs:**

   See `templates/starburst-contract-samples.md` for ready-to-use contract text.

   **For each opportunity:**
   - Create a Word document or PDF with sample contract text
   - Include these key sections:
     - Payment Terms (vary between Net 30, Net 45, Net 60)
     - Uptime SLA (vary between 99.5%, 99.9%, 99.95%)
     - Rollover Terms (vary between 5%, 10%, 15%)
     - Liability clauses
     - Termination clauses
   - Save as PDF

4. **Upload contract PDFs to Opportunities:**
   - Navigate to each Opportunity
   - Click **Files** tab
   - Upload PDFs (drag and drop)
   - Recommended file names:
     - `TechCorp_MSA_2025.pdf`
     - `TechCorp_Order_Form.pdf`
     - `DataFlow_Enterprise_Agreement.pdf`
     - `CloudVision_SOW.pdf`

**Expected Result:** 3 accounts, 3 opportunities, 4-6 PDF files attached

---

### Step 1.5: Verify File Retrieval

**Goal:** Test that the OpportunityFileRetriever action works correctly

**Actions:**

1. **Create a test flow:**
   - Setup → Flows → New Flow
   - Select **Screen Flow**

2. **Add input variable:**
   - Name: `recordId`
   - Data Type: Text
   - Available for input: ✅ Checked

3. **Add Action: Get Opportunity Files**
   - Search for "Get Opportunity Files"
   - Set Opportunity ID: `{!recordId}`
   - Store outputs:
     - File Count → `varFileCount`
     - File List → `varFileList`
     - File Summary → `varFileSummary`

4. **Add Screen:**
   - Add Display Text component
   - Content:
     ```
     File Count: {!varFileCount}
     
     Files:
     {!varFileList}
     ```

5. **Save and Activate:**
   - Flow Label: "Test File Retrieval"
   - Save and Activate

6. **Test the flow:**
   - Go to an Opportunity with files
   - Click ⚙️ → Edit Page
   - Add **Flow** component
   - Select "Test File Retrieval"
   - Set recordId to receive page variable
   - Save and test

**Expected Result:** Flow displays correct file count and list

**Troubleshooting:**
- If no files shown → Verify files are attached to Opportunity
- If permission error → Grant ContentDocument read access
- If action not found → Re-deploy OpportunityFileRetriever class

---

## PHASE 2: DATA CLOUD CONFIGURATION

### Step 2.1: Enable Data Cloud for Unstructured Data

**Goal:** Configure Data Cloud 360 to ingest and index contract PDFs

**Actions:**

1. **Navigate to Data Cloud Setup:**
   - Setup → Data Cloud → Getting Started

2. **Enable Unstructured Data:**
   - Click **Data Streams**
   - Click **New Data Stream**
   - Select **Salesforce**
   - Choose **ContentDocument** and **ContentVersion**
   - Name: "Contract Documents"
   - Click **Save**

3. **Configure Data Stream:**
   - Filter Criteria: `FileExtension IN ('pdf', 'docx', 'doc')`
   - Sync Schedule: Real-time (or hourly for demo)
   - Click **Activate**

4. **Wait for initial sync:**
   - Go to **Data Stream** monitor
   - Wait for "Syncing" → "Active"
   - Verify record count matches your uploaded files

**Expected Result:** Data Cloud shows synced ContentDocuments

---

### Step 2.2: Configure Vector Embeddings

**Goal:** Set up vector embeddings for semantic search (RAG)

**Actions:**

1. **Create Unstructured Data Model:**
   - Data Cloud → **Data Models**
   - Click **New Unstructured Data Model**
   - Name: `Contract_Documents`
   - Source: Contract Documents data stream

2. **Configure Chunking:**
   - Chunk Size: `1000` characters
   - Chunk Overlap: `200` characters
   - (These settings balance context vs. precision)

3. **Select Embedding Model:**
   - Model: `text-embedding-ada-002` (OpenAI)
   - Vector Dimension: 1536
   - (Alternative: Use Salesforce's native embedding model if available)

4. **Map Fields:**
   - **Content Field:** ContentVersion.VersionData (the actual file content)
   - **Metadata Fields:**
     - Title: ContentDocument.Title
     - FileExtension: ContentDocument.FileExtension
     - ContentSize: ContentDocument.ContentSize
     - CreatedDate: ContentDocument.CreatedDate
     - LinkedEntityId: ContentDocumentLink.LinkedEntityId (to link to Opportunity)

5. **Save and Deploy:**
   - Click **Save**
   - Click **Deploy**
   - Wait for deployment (5-30 minutes depending on document count)

**Expected Result:** Vector embeddings created for all contract documents

**Verification:**
- Go to Data Cloud → **Vector Search**
- Try a test query: "payment terms net 30"
- Should return relevant document chunks

---

### Step 2.3: Configure RAG Retrieval

**Goal:** Set up Retrieval-Augmented Generation for contract queries

**Actions:**

1. **Create RAG Configuration:**
   - Setup → **Einstein RAG**
   - Click **New RAG Configuration**
   - Name: `Contract_Analysis_RAG`
   - Description: "Retrieve contract clauses for agent analysis"

2. **Configure Retrieval Settings:**
   - **Data Source:** Contract_Documents (from Step 2.2)
   - **Top K Results:** `5` (return top 5 most relevant chunks)
   - **Similarity Threshold:** `0.75` (75% similarity minimum)
   - **Context Window:** `5000` tokens

3. **Configure Augmentation:**
   - **LLM Model:** GPT-4 (via Einstein)
   - **Temperature:** `0.2` (low = more factual, less creative)
   - **Max Tokens:** `2000`
   - **System Prompt:**
     ```
     You are a contract analysis expert. When answering questions:
     - Always cite the specific document and section
     - Quote the exact clause when possible
     - Identify deviations from standard terms
     - Flag high-risk provisions
     - Be precise and factual
     ```

4. **Add Response Formatting:**
   - **Citation Format:** `[Document: {title}, Section: {section}]`
   - **Structured Output:** JSON format for key fields
   - **Include Confidence Score:** ✅ Checked

5. **Save and Test:**
   - Click **Save**
   - Click **Test**
   - Test Query: "What are the payment terms for TechCorp?"
   - Verify response includes:
     - Quoted text from document
     - Document citation
     - Confidence score

**Expected Result:** RAG successfully retrieves and generates responses from contracts

---

### Step 2.4: Create Knowledge Articles for Standards

**Goal:** Create knowledge articles that define your organization's contract standards

**Actions:**

1. **Enable Salesforce Knowledge:**
   - Setup → Knowledge Settings
   - Enable Knowledge
   - Select **Lightning Knowledge**

2. **Create Article Type:**
   - Setup → Object Manager → Knowledge Article Types
   - Create **Contract_Standard**
   - Add custom fields:
     - Term Name (Text)
     - Standard Value (Text)
     - Acceptable Ranges (Text)
     - Non-Compliant Indicators (Text Area)
     - Risk Level (Picklist: Low, Medium, High, Critical)

3. **Create Standard Articles:**

   **Article 1: Payment Terms Standard**
   - Title: "Payment Terms Standard"
   - Term Name: "Payment Terms"
   - Standard Value: "Net 30 days"
   - Acceptable Ranges: "Net 30 - Net 45 days"
   - Non-Compliant: "Net 60+ days, Payment in advance, Milestone-based without milestones defined"
   - Risk Level: High (if non-compliant)

   **Article 2: Uptime SLA Standard**
   - Title: "Uptime SLA Standard"
   - Term Name: "Uptime / Availability SLA"
   - Standard Value: "99.9% uptime"
   - Acceptable Ranges: "99.5% - 99.9%"
   - Non-Compliant: "99.95%+ (difficult to achieve), <99.5% (too low)"
   - Risk Level: Critical (if >99.95%)

   **Article 3: Rollover Terms Standard**
   - Title: "Rollover Terms Standard"
   - Term Name: "Unused Capacity Rollover"
   - Standard Value: "Up to 10% rollover allowed"
   - Acceptable Ranges: "5% - 10%"
   - Non-Compliant: ">15% rollover"
   - Risk Level: High (if >15%)

   **Article 4: Liability Cap Standard**
   - Title: "Liability Cap Standard"
   - Term Name: "Limitation of Liability"
   - Standard Value: "Capped at 12 months of fees paid"
   - Acceptable Ranges: "6-12 months of fees"
   - Non-Compliant: "Unlimited liability, <6 months cap"
   - Risk Level: Critical (if unlimited)

   **Article 5: Termination Clause Standard**
   - Title: "Termination Rights Standard"
   - Term Name: "Termination for Convenience"
   - Standard Value: "Either party, 90 days notice"
   - Acceptable Ranges: "60-90 days notice"
   - Non-Compliant: "No termination rights, >90 days notice"
   - Risk Level: Medium

4. **Publish all articles**

5. **Create Knowledge Base:**
   - Setup → Knowledge → **Lightning Knowledge**
   - Create new knowledge base: "Deal Desk Standards"
   - Add all contract standard articles

**Expected Result:** 5+ knowledge articles defining contract standards

---

## PHASE 3: AGENT BUILD

### Step 3.1: Create the Agentforce Agent

**Goal:** Create the foundational Agentforce agent

**Actions:**

1. **Navigate to Agent Builder:**
   - Setup → **Einstein Setup** → **Agents** (or **Einstein Bots**)
   - Click **New Agent**

2. **Configure Agent Basics:**
   - **Agent Name:** `Deal Desk Contract Analysis Agent`
   - **API Name:** `Deal_Desk_Contract_Agent`
   - **Description:** "AI-powered contract analysis agent that helps Deal Desk teams analyze contracts, verify standards compliance, and identify risks in unstructured contract documents."
   - **Channel:** Salesforce (not Slack, not external)
   - **Object Context:** Opportunity (agent will work on Opportunity records)

3. **Configure Agent Greeting:**
   ```
   Hello! I'm your Deal Desk Contract Analysis Assistant. I can help you:
   
   • Answer questions about contract terms from uploaded documents
   • Analyze contracts for risk and compliance
   • Identify trends across all your contracts
   • Verify documents against organizational standards
   • Provide standard language for common clauses
   
   What would you like to know about your contracts today?
   ```

4. **Configure Agent Role & Instructions:**
   
   Click **Agent Instructions** and enter:
   
   ```
   You are an expert contract analysis assistant for a Deal Desk team. Your role is to:
   
   1. ANSWER QUESTIONS about contract terms
      - Search uploaded contract PDFs using semantic search
      - Quote exact clauses and cite source documents
      - Compare terms across multiple contracts
      - Explain implications of specific terms
   
   2. ANALYZE CONTRACTS for risk and compliance
      - Identify deviations from organizational standards
      - Flag high-risk provisions (>99.9% uptime, unlimited liability, etc.)
      - Calculate risk scores based on terms found
      - Recommend actions to mitigate risks
   
   3. PROVIDE TRENDS AND INSIGHTS
      - Calculate percentages of contracts with specific terms
      - Identify most common contract structures
      - Highlight outliers and anomalies
      - Suggest negotiation opportunities
   
   4. VERIFY STANDARDS COMPLIANCE
      - Check contracts against knowledge base standards
      - Flag non-compliant terms
      - Suggest standard language replacements
   
   5. GUIDE TO BEST PRACTICES
      - Provide standard clause templates
      - Explain why certain terms are preferred
      - Offer negotiation strategies
   
   IMPORTANT INSTRUCTIONS:
   - Always cite your sources with [Document: Title, Section: X]
   - If you find contradictory terms, highlight them explicitly
   - Use risk levels: Low, Medium, High, Critical
   - Provide actionable recommendations, not just observations
   - If uncertain, say so and suggest manual review
   - For trends, provide specific percentages when possible
   
   KNOWLEDGE SOURCES:
   - Contract PDFs attached to Opportunities (via Data Cloud RAG)
   - Knowledge Base articles on contract standards
   - Salesforce Opportunity fields for structured data
   ```

5. **Save Agent**

**Expected Result:** Agent created and visible in Agent Builder

---

### Step 3.2: Create Agent Topics

**Goal:** Create 5 topics that route user intents to appropriate actions

**Actions:**

For each topic below, click **New Topic** in Agent Builder:

---

**TOPIC 1: Contract Standards Inquiry**

- **Topic Name:** `Contract Standards Inquiry`
- **Description:** User wants to know what the standard terms are for a specific contract clause
- **Sample Utterances:**
  - "What are our standard payment terms?"
  - "What is the policy on uptime SLAs?"
  - "What rollover percentage do we typically allow?"
  - "What's our standard liability cap?"
  - "Show me our termination clause standard"
  - "What are acceptable termination notice periods?"

- **Actions:**
  - **Search Knowledge Base:** Topic: "Contract Standards"
  - **Display Results:** Show relevant standard articles
  - **Follow-up:** Ask if user wants to check a specific contract against this standard

---

**TOPIC 2: Contract Upload & Analysis**

- **Topic Name:** `Contract Upload & Analysis`
- **Description:** User wants to upload and analyze a draft contract
- **Sample Utterances:**
  - "Analyze this contract for me"
  - "Check this draft MSA for risks"
  - "Review this contract"
  - "What's wrong with this agreement?"
  - "Is this contract compliant?"
  - "Scan this document for issues"

- **Actions:**
  - **Prompt User:** Ask user to attach contract file to Opportunity
  - **Wait for File Upload:** (File upload detection via Data Cloud ingestion)
  - **Invoke RAG:** Query uploaded document for key terms:
    - Payment terms
    - Uptime SLA
    - Rollover provisions
    - Liability caps
    - Termination clauses
  - **Compare to Standards:** Check against knowledge base
  - **Calculate Risk Score:**
    - Low Risk (0-2 points)
    - Medium Risk (3-6 points)
    - High Risk (7-9 points)
    - Critical Risk (10+ points)
  - **Display Results:**
    ```
    CONTRACT ANALYSIS RESULTS
    ========================
    
    Document: {filename}
    Analyzed: {date}
    
    RISK LEVEL: {Low | Medium | High | Critical}
    RISK SCORE: {score}/10
    
    KEY FINDINGS:
    ✅ Payment Terms: {found_terms} (Compliant ✅ / Non-Compliant ❌)
    ✅ Uptime SLA: {found_sla} (Compliant ✅ / Non-Compliant ❌)
    ⚠️  Rollover: {found_rollover} (Non-Standard - Review Required)
    
    RISKS IDENTIFIED:
    - {risk 1}
    - {risk 2}
    
    RECOMMENDATIONS:
    1. {recommendation 1}
    2. {recommendation 2}
    
    Would you like me to update the Opportunity fields with this analysis?
    ```
  - **Optional:** Update Opportunity fields with analysis results

---

**TOPIC 3: Trend Analysis**

- **Topic Name:** `Contract Trend Analysis`
- **Description:** User wants insights on trends across all contracts
- **Sample Utterances:**
  - "What percentage of contracts have Net 30 payment terms?"
  - "Show me rollover compliance trends"
  - "How many contracts have uptime SLAs above 99.9%?"
  - "What are the most common payment terms?"
  - "Which accounts have non-standard terms?"
  - "Show me contract risk distribution"

- **Actions:**
  - **Determine Trend Type:** Identify what user wants to analyze (payment terms, SLA, rollover, etc.)
  - **Query Opportunity Fields:** Use SOQL to query structured data if available
  - **Query RAG:** Search across all contract documents for pattern
  - **Aggregate Results:** Calculate percentages and counts
  - **Display Trend Report:**
    ```
    TREND ANALYSIS: PAYMENT TERMS
    =============================
    Total Contracts Analyzed: 47
    
    DISTRIBUTION:
    • Net 30:   28 contracts (60%)  ✅ Compliant
    • Net 45:   12 contracts (26%)  ⚠️  Acceptable
    • Net 60:    5 contracts (11%)  ❌ Non-Compliant
    • Other:     2 contracts (4%)   ❌ Review Required
    
    INSIGHTS:
    - 60% compliance with Net 30 standard
    - 11% require negotiation (Net 60+)
    - Highest risk accounts: TechCorp, CloudVision
    
    RECOMMENDATION:
    - Negotiate Net 60 contracts back to Net 30
    - Target: 90% Net 30 compliance by Q2
    
    Would you like to see contracts with Net 60 terms?
    ```

---

**TOPIC 4: Document Verification**

- **Topic Name:** `Document Verification`
- **Description:** User wants to verify if multiple documents are consistent
- **Sample Utterances:**
  - "Check if the MSA and Order Form have consistent terms"
  - "Verify payment terms match across all documents"
  - "Are there any conflicts between the MSA and amendment?"
  - "Do the NDA and MSA have the same termination clause?"
  - "Compare this contract with our standard template"

- **Actions:**
  - **Identify Documents:** Ask user which documents to compare (or auto-detect from Opportunity)
  - **Invoke RAG on Multiple Documents:** Extract key terms from each
  - **Compare Terms:** Identify matches and mismatches
  - **Highlight Conflicts:**
    ```
    DOCUMENT VERIFICATION RESULTS
    =============================
    
    Documents Analyzed:
    1. TechCorp_MSA_2025.pdf
    2. TechCorp_Order_Form_2025.pdf
    
    TERM COMPARISON:
    
    ✅ Payment Terms: 
       - MSA: Net 60 days
       - Order Form: Net 60 days
       - STATUS: Consistent
    
    ❌ Rollover Percentage:
       - MSA: 15% rollover allowed
       - Order Form: 10% rollover allowed
       - STATUS: CONFLICT DETECTED ⚠️
       - RISK: High - Which document governs?
       - RECOMMENDATION: Clarify precedence or amend to match
    
    ✅ Uptime SLA:
       - MSA: 99.9% uptime
       - Order Form: 99.9% uptime
       - STATUS: Consistent
    
    OVERALL ASSESSMENT:
    - 2 of 3 terms consistent
    - 1 critical conflict requires resolution
    - Recommend: Issue amendment to align rollover terms
    
    Would you like me to draft an amendment?
    ```

---

**TOPIC 5: Standard Language Guidance**

- **Topic Name:** `Standard Language Guidance`
- **Description:** User wants recommended standard language for a clause
- **Sample Utterances:**
  - "Give me standard language for payment terms"
  - "What should the termination clause say?"
  - "Provide template for overage pricing"
  - "Show me our standard NDA language"
  - "What's the recommended liability limitation clause?"

- **Actions:**
  - **Identify Clause Type:** Determine which standard clause user needs
  - **Search Knowledge Base:** Retrieve standard language article
  - **Display Template:**
    ```
    STANDARD LANGUAGE: PAYMENT TERMS
    =================================
    
    RECOMMENDED CLAUSE:
    "Customer shall pay all undisputed invoices within thirty (30) days of invoice date ("Net 30"). Invoices shall be sent electronically to the billing contact provided by Customer. Late payments shall accrue interest at the rate of 1.5% per month or the maximum rate permitted by law, whichever is lower."
    
    RATIONALE:
    - Net 30 aligns with company cash flow requirements
    - Clear billing process reduces disputes
    - Interest provision incentivizes timely payment
    - Complies with usury laws
    
    ACCEPTABLE VARIATIONS:
    - Net 45 for enterprise customers (requires VP approval)
    - Net 15 for high-risk accounts
    
    NON-ACCEPTABLE:
    - Net 60+ (delays cash collection)
    - Payment in advance (customer-unfriendly)
    - No late payment provision (no recourse)
    
    Would you like me to copy this clause to your clipboard?
    ```
  - **Offer Actions:**
    - Copy to clipboard
    - Email to user
    - Attach to Opportunity as note

---

**Save all 5 topics**

---

### Step 3.3: Configure Topic Routing

**Goal:** Configure natural language understanding to route utterances to correct topics

**Actions:**

1. **Go to Agent Builder → Natural Language Understanding (NLU)**

2. **Enable Intent Recognition:**
   - Turn on **Adaptive Intent Recognition**
   - Set **Confidence Threshold:** 0.70 (70%)

3. **Train NLU Model:**
   - Click **Train Model**
   - Wait for training to complete (5-15 minutes)

4. **Test Topic Routing:**
   - Click **Test Agent**
   - Enter test utterances:
     - "What are our payment terms?" → Should route to Topic 1
     - "Analyze this contract" → Should route to Topic 2
     - "Show me payment term trends" → Should route to Topic 3
     - "Check if MSA and Order Form match" → Should route to Topic 4
     - "Give me standard termination language" → Should route to Topic 5

5. **Refine Routing:**
   - If any utterances route incorrectly, add them as examples to correct topic
   - Retrain model
   - Test again

**Expected Result:** Agent correctly routes all test utterances to intended topics

---

### Step 3.4: Connect Data Sources to Agent

**Goal:** Connect RAG, Knowledge Base, and Salesforce data to agent topics

**Actions:**

1. **Connect RAG to Topics 2, 3, 4:**
   - Edit Topic 2 (Contract Upload & Analysis)
   - Add Action: **RAG Query**
   - Configuration:
     - RAG Config: `Contract_Analysis_RAG` (from Step 2.3)
     - Query: User's question or "analyze this contract"
     - Context: LinkedEntityId = Current Opportunity ID
     - Store Response: `varRAGResponse`

   - Repeat for Topics 3 and 4

2. **Connect Knowledge Base to Topics 1 and 5:**
   - Edit Topic 1 (Contract Standards Inquiry)
   - Add Action: **Knowledge Search**
   - Configuration:
     - Knowledge Base: "Deal Desk Standards"
     - Query: User's question
     - Max Results: 3
     - Store Response: `varKnowledgeResults`

   - Repeat for Topic 5

3. **Connect Salesforce Data to Topic 3:**
   - Edit Topic 3 (Trend Analysis)
   - Add Action: **Get Records**
   - Configuration:
     - Object: Opportunity
     - Fields: Payment_Terms__c, Uptime_SLA__c, Rollover_Percentage__c, Contract_Risk_Level__c
     - Filter: CloseDate = LAST_N_DAYS:365 (trends for last year)
     - Store Response: `varOpportunities`

   - Add Action: **Apex Action** (if you have custom aggregation logic)
   - Or use **Formula** to calculate percentages

4. **Add File Retrieval Actions:**
   - For Topics 2, 3, 4: Before RAG query, get files from Opportunity
   - Add Action: **Get Opportunity Files** (OpportunityFileRetriever)
   - Configuration:
     - Opportunity ID: {!$Context.OpportunityId}
     - File Types: pdf,docx
     - Store Response: `varFiles`

**Expected Result:** Agent can access contract documents, knowledge articles, and Salesforce data

---

### Step 3.5: Add Response Formatting

**Goal:** Format agent responses to be professional and actionable

**Actions:**

1. **Create Prompt Template for Response Formatting:**
   - Setup → Prompt Builder → New Prompt Template
   - Name: `Format_Contract_Analysis_Response`
   - Type: Flex
   - Resources:
     - `ragResponse` (Text, Long)
     - `riskLevel` (Text)
     - `documentName` (Text)
     - `analysisType` (Text)

   - Prompt:
     ```
     You are formatting a contract analysis response for a Deal Desk team member.
     
     RAG Response:
     {!$Input:ragResponse}
     
     Document Analyzed:
     {!$Input:documentName}
     
     Analysis Type:
     {!$Input:analysisType}
     
     Risk Level:
     {!$Input:riskLevel}
     
     Your task:
     1. Format the response professionally
     2. Use clear sections with headers
     3. Highlight key findings with ✅ ❌ ⚠️ emojis
     4. Include risk level prominently
     5. Always cite document sources
     6. End with 2-3 actionable recommendations
     7. Use tables for comparisons when appropriate
     
     OUTPUT FORMAT:
     
     📄 ANALYSIS: {Analysis Type}
     Document: {Document Name}
     Risk Level: {Risk Level}
     
     KEY FINDINGS:
     {Formatted findings}
     
     RECOMMENDATIONS:
     1. {Recommendation 1}
     2. {Recommendation 2}
     3. {Recommendation 3}
     
     ---
     Source: [Document: {name}]
     ```

   - Save and Activate

2. **Add Prompt Template to Topics:**
   - Edit Topics 2, 3, 4
   - After RAG query, add Action: **Prompt Template**
   - Select: `Format_Contract_Analysis_Response`
   - Map inputs:
     - ragResponse: {!varRAGResponse}
     - riskLevel: {!varRiskLevel}
     - documentName: {!varFileName}
     - analysisType: (hardcode based on topic)

3. **Display Formatted Response:**
   - Add **Message** element
   - Content: {!PromptResponse}

**Expected Result:** Agent responses are well-formatted and professional

---

### Step 3.6: Test the Agent End-to-End

**Goal:** Verify all topics work correctly with real data

**Test Plan:**

**Test 1: Contract Standards Inquiry**
- Input: "What are our standard payment terms?"
- Expected: Knowledge article displayed with Net 30 standard
- Verify: Article content is accurate and relevant

**Test 2: Contract Upload & Analysis**
- Setup: Upload TechCorp_MSA_2025.pdf to an Opportunity
- Input: "Analyze the TechCorp contract"
- Expected:
  - Agent finds payment terms, SLA, rollover from PDF
  - Risk level calculated (e.g., High due to Net 60)
  - Recommendations provided
- Verify: Quoted terms match actual PDF content

**Test 3: Trend Analysis**
- Input: "What percentage of our contracts have Net 30 payment terms?"
- Expected:
  - Agent queries across all opportunities
  - Calculates percentage (e.g., "60% of 47 contracts")
  - Shows distribution
- Verify: Percentage is accurate based on test data

**Test 4: Document Verification**
- Setup: Opportunity with TechCorp MSA (15% rollover) and Order Form (10% rollover)
- Input: "Check if the MSA and Order Form are consistent"
- Expected:
  - Agent identifies rollover percentage conflict
  - Flags as high risk
  - Recommends resolution
- Verify: Conflict correctly identified

**Test 5: Standard Language Guidance**
- Input: "Show me standard payment terms language"
- Expected:
  - Knowledge article with recommended clause text
  - Rationale and variations
- Verify: Clause text is correct

**Debugging Tips:**
- Enable Debug Mode in Agent Builder
- Check RAG query responses in Data Cloud → Vector Search logs
- Review Knowledge article matches
- Verify Opportunity fields have test data

---

## PHASE 4: TESTING & REFINEMENT

### Step 4.1: Accuracy Testing

**Goal:** Verify agent provides accurate answers

**Test Cases:**

1. **Exact Quote Test:**
   - Upload contract with clause: "Payment shall be Net 60 days"
   - Ask: "What are the payment terms in this contract?"
   - Expected: Agent quotes "Net 60 days" and cites document
   - Fail if: Agent hallucinates different terms

2. **Multi-Document Test:**
   - Upload 3 contracts with different payment terms
   - Ask: "What are the payment terms across all TechCorp contracts?"
   - Expected: Agent lists all three correctly
   - Fail if: Agent misses any contract

3. **Negative Test:**
   - Upload contract with no uptime SLA clause
   - Ask: "What is the uptime SLA?"
   - Expected: Agent says "No uptime SLA found in this contract"
   - Fail if: Agent invents an SLA

4. **Conflicting Terms Test:**
   - Upload MSA and Order Form with different rollover percentages
   - Ask: "What is the rollover percentage?"
   - Expected: Agent identifies conflict and lists both
   - Fail if: Agent only mentions one

**Accuracy Target:** 95%+ accuracy on factual queries

---

### Step 4.2: Performance Testing

**Goal:** Ensure agent responds quickly

**Benchmarks:**

| Query Type | Target Response Time |
|------------|---------------------|
| Simple question (single contract) | < 5 seconds |
| Complex analysis (multiple contracts) | < 15 seconds |
| Trend analysis (all opportunities) | < 20 seconds |
| Document comparison | < 10 seconds |

**Load Testing:**
- Test with 50+ contracts in org
- Test with 10-page PDFs
- Test with 50+ opportunities

**Optimization if slow:**
- Reduce chunk size in Data Cloud
- Reduce Top K results in RAG config
- Add caching for frequently accessed documents
- Optimize SOQL queries

---

### Step 4.3: User Experience Testing

**Goal:** Ensure agent is easy and intuitive to use

**UX Checklist:**

- [ ] Agent greeting is clear and welcoming
- [ ] Topic routing works with natural language (no rigid commands)
- [ ] Responses are formatted clearly (not wall of text)
- [ ] Agent confirms understanding before taking action
- [ ] Agent provides follow-up suggestions
- [ ] Agent handles errors gracefully
- [ ] Agent provides "I don't know" when appropriate (not hallucinating)
- [ ] Agent includes citations for all factual claims

**User Testing:**
- Have 2-3 non-technical users test agent
- Ask them to complete 5 common tasks
- Collect feedback on what was confusing
- Refine agent instructions and topic utterances

---

### Step 4.4: Risk Assessment Testing

**Goal:** Verify agent correctly identifies contract risks

**Risk Test Cases:**

**Test 1: Critical Risk - Unrealistic SLA**
- Contract: Uptime SLA 99.999% (five nines)
- Expected Risk: **Critical** (nearly impossible to achieve)
- Agent should: Flag as critical, explain why, recommend negotiation

**Test 2: High Risk - Extended Payment Terms**
- Contract: Net 90 payment terms
- Expected Risk: **High** (cash flow impact)
- Agent should: Flag as high risk, calculate impact, recommend Net 30 or 45

**Test 3: Medium Risk - High Rollover Percentage**
- Contract: 15% rollover
- Expected Risk: **Medium** (above 10% standard)
- Agent should: Flag as medium, note deviation from standard

**Test 4: Low Risk - Standard Terms**
- Contract: Net 30, 99.9% SLA, 8% rollover
- Expected Risk: **Low** (all within standards)
- Agent should: Confirm compliance, no major issues

**Verification:**
- Risk levels match expected
- Agent provides clear rationale for risk assessment
- Recommendations are actionable

---

## PHASE 5: PRODUCTION DEPLOYMENT

### Step 5.1: Pre-Deployment Checklist

**Verify All Components:**

- [ ] OpportunityFileRetriever deployed and tested
- [ ] AccountOpportunityFilesRetriever deployed and tested
- [ ] Custom Opportunity fields created
- [ ] Data Cloud 360 configured and ingesting files
- [ ] Vector embeddings generated for all contracts
- [ ] RAG configuration tested and accurate
- [ ] Knowledge articles created and published
- [ ] Agent created with 5 topics
- [ ] All topics tested end-to-end
- [ ] Accuracy testing passed (95%+)
- [ ] Performance testing passed (< 20 sec)
- [ ] UX testing passed with real users

**Verify Permissions:**

- [ ] Users have "Use Agentforce Agents" permission
- [ ] Users have read access to Opportunity
- [ ] Users have read access to ContentDocument
- [ ] Users have read access to Knowledge articles
- [ ] Users can access Data Cloud (if needed for direct queries)

---

### Step 5.2: Deploy to Production

**Option A: Deploy from Sandbox (Recommended)**

1. **Create Change Set in Sandbox:**
   - Setup → Outbound Change Sets
   - New Change Set: "Deal Desk Agent"
   - Add Components:
     - Apex Classes: OpportunityFileRetriever, OpportunityFileRetriever_Test, AccountOpportunityFilesRetriever, AccountOpportunityFilesRetriever_Test
     - Custom Fields: All 7 Opportunity fields
     - Knowledge Articles: All contract standards
     - Agent: Deal_Desk_Contract_Agent (if supported)
     - Prompt Templates: Format_Contract_Analysis_Response

2. **Upload Change Set**

3. **Deploy in Production:**
   - Setup → Inbound Change Sets
   - Select "Deal Desk Agent"
   - Validate (run tests)
   - Deploy

4. **Manually Configure in Production:**
   - Data Cloud data streams (can't be deployed via change set)
   - RAG configuration
   - Agent topics (if not included in change set)

**Option B: Direct Deployment to Production**

1. **Deploy Apex Classes:**
   ```bash
   sf config set target-org your-production-org
   
   sf project deploy start \
     --source-dir force-app/main/default/classes/OpportunityFileRetriever.cls \
     --source-dir force-app/main/default/classes/OpportunityFileRetriever.cls-meta.xml \
     --source-dir force-app/main/default/classes/OpportunityFileRetriever_Test.cls \
     --source-dir force-app/main/default/classes/OpportunityFileRetriever_Test.cls-meta.xml \
     --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever.cls \
     --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever.cls-meta.xml \
     --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever_Test.cls \
     --source-dir force-app/main/default/classes/AccountOpportunityFilesRetriever_Test.cls-meta.xml \
     --test-level RunLocalTests \
     --wait 15
   ```

2. **Create Custom Fields manually** (see Step 1.3)

3. **Configure Data Cloud** (see Phase 2)

4. **Create Agent** (see Phase 3)

5. **Create Knowledge Articles** (see Step 2.4)

---

### Step 5.3: User Training

**Goal:** Train Deal Desk team on how to use the agent

**Training Agenda (1-hour session):**

**Part 1: Introduction (10 min)**
- What is Agentforce?
- What can the Deal Desk Agent do?
- When should you use it vs. manual review?

**Part 2: Live Demo (20 min)**
- **Scenario 1:** Ask about standard payment terms
- **Scenario 2:** Upload and analyze a draft contract
- **Scenario 3:** Check trend: "What % of contracts have Net 30?"
- **Scenario 4:** Verify two documents are consistent
- **Scenario 5:** Get standard termination clause language

**Part 3: Hands-On Practice (20 min)**
- Each user accesses agent
- Complete guided exercises:
  - Exercise 1: Ask about uptime SLA standard
  - Exercise 2: Analyze a sample contract (provided)
  - Exercise 3: Request trend analysis
  - Exercise 4: Get standard language for liability cap

**Part 4: Q&A and Best Practices (10 min)**
- Common questions
- Tips for getting best results
- How to report issues or inaccuracies
- Where to find documentation

**Training Materials to Create:**
- Quick Start Guide (1-page PDF)
- Demo video (10 min screencast)
- FAQ document
- Example prompts cheat sheet

---

### Step 5.4: Monitoring Setup

**Goal:** Monitor agent usage and accuracy

**Setup Dashboards:**

1. **Agent Usage Dashboard:**
   - Setup → Reports → New Report
   - Report Type: Bot Conversations (or equivalent)
   - Metrics:
     - Total conversations
     - Unique users
     - Average conversation length
     - Topic distribution (which topics used most)
     - Time of day usage
   - Chart Type: Line chart for trend over time

2. **Agent Accuracy Dashboard:**
   - Metrics:
     - Successful resolutions (user didn't escalate)
     - Thumbs up/down ratings
     - Average response time
     - Fallback rate (when agent couldn't answer)
   - Chart Type: Gauge for % accurate

3. **Contract Analysis Dashboard:**
   - Metrics:
     - Contracts analyzed this month
     - Average risk level distribution
     - Most common non-compliant terms
     - Time saved (vs. manual review)
   - Chart Type: Pie chart for risk distribution

**Setup Alerts:**

1. **Accuracy Alert:**
   - If thumbs down rate > 20%: Alert admin to review
   
2. **Performance Alert:**
   - If average response time > 30 seconds: Alert to optimize

3. **Error Alert:**
   - If RAG failures > 5%: Alert to check Data Cloud

**Setup Feedback Collection:**

- Add "Was this helpful? 👍 👎" after each agent response
- Create Feedback__c custom object to store detailed feedback
- Weekly review of feedback with product owner

---

### Step 5.5: Post-Deployment Validation

**First Week Checklist:**

**Day 1:**
- [ ] All users can access agent
- [ ] No deployment errors or bugs
- [ ] Monitor usage dashboard

**Day 3:**
- [ ] Review first 10-20 conversations
- [ ] Identify any common issues
- [ ] Make quick fixes to agent instructions

**Day 7:**
- [ ] Review accuracy metrics
- [ ] Collect user feedback (survey)
- [ ] Identify training gaps
- [ ] Plan iteration 2 improvements

**First Month Goals:**

- [ ] 80%+ of Deal Desk team using agent weekly
- [ ] 90%+ accuracy on factual queries
- [ ] < 15 sec average response time
- [ ] 75%+ user satisfaction (thumbs up)
- [ ] At least 10 hours saved in contract review time

---

## 📊 Success Metrics

### Key Performance Indicators (KPIs)

**Efficiency Metrics:**
- **Contract Review Time:** 2 hours → 15 minutes (87.5% reduction)
- **Time to Answer Question:** 15 minutes → 30 seconds (96.7% reduction)
- **Contracts Processed per Week:** 10 → 50 (5x increase)

**Quality Metrics:**
- **Contract Accuracy:** 95%+ (agent correctly identifies terms)
- **Compliance Rate:** 65% → 85% (more contracts meeting standards)
- **Risk Detection:** 100% of critical risks flagged
- **User Satisfaction:** 80%+ thumbs up rating

**Business Metrics:**
- **Annual Time Savings:** 1,200 hours (0.6 FTE)
- **Annual Cost Savings:** $75,000 - $100,000
- **Contracts at Risk:** Reduced from 35% to 15%
- **Average Deal Cycle:** Reduced by 15-20%

**Adoption Metrics:**
- **Active Users:** 80%+ of Deal Desk team using weekly
- **Queries per Month:** Target 200+ queries
- **Repeat Usage:** 70%+ users return within 7 days

---

## 🛠️ Troubleshooting

### Common Issues

**Issue 1: Agent Not Finding Contract Terms**

**Symptoms:**
- Agent says "No information found" even though term exists in PDF
- Agent provides generic answers without document citations

**Causes & Solutions:**
- **Cause:** Data Cloud hasn't indexed the document yet
  - **Solution:** Wait 15-30 min after upload, or force re-sync
- **Cause:** Document is scanned image PDF (not searchable text)
  - **Solution:** Run OCR on PDF before upload, or enable Data Cloud OCR
- **Cause:** RAG similarity threshold too high (0.75)
  - **Solution:** Lower threshold to 0.65-0.70 in RAG config
- **Cause:** Chunk size too small (missing context)
  - **Solution:** Increase chunk size from 1000 to 1500 characters

**Diagnostic Steps:**
1. Test RAG directly: Data Cloud → Vector Search → Enter query
2. Check if document appears in results
3. Review chunk content - does it contain the term?
4. Adjust RAG settings and retest

---

**Issue 2: Agent Gives Incorrect Risk Assessments**

**Symptoms:**
- Contract flagged as low risk when it has Net 90 terms (should be high)
- Critical risk (99.999% SLA) not flagged

**Causes & Solutions:**
- **Cause:** Agent instructions don't include risk scoring logic
  - **Solution:** Update agent instructions with explicit risk criteria (see Step 3.1)
- **Cause:** Agent not accessing knowledge articles for standards
  - **Solution:** Verify knowledge base connection in topic actions
- **Cause:** Agent hallucinating instead of using retrieved data
  - **Solution:** Lower LLM temperature (0.2 → 0.1), emphasize "only use retrieved documents" in instructions

---

**Issue 3: Agent Response Time > 30 Seconds**

**Symptoms:**
- Slow responses
- Users complain about waiting

**Causes & Solutions:**
- **Cause:** Too many Top K results in RAG (retrieving 20 chunks)
  - **Solution:** Reduce Top K to 5
- **Cause:** Large PDFs (100+ pages)
  - **Solution:** Enable chunking optimization, consider summarization
- **Cause:** Complex SOQL queries for trends
  - **Solution:** Add indexed fields, use aggregate queries, cache results
- **Cause:** LLM token limit reached (processing too much context)
  - **Solution:** Reduce context window from 5000 to 3000 tokens

---

**Issue 4: Agent Can't Access Uploaded Files**

**Symptoms:**
- User uploads PDF, agent says "No files found"
- Permission errors

**Causes & Solutions:**
- **Cause:** Data Cloud sync delay
  - **Solution:** Wait 5-10 minutes after upload
- **Cause:** User doesn't have ContentDocument read access
  - **Solution:** Grant "View All Files" permission or adjust sharing
- **Cause:** File not linked to Opportunity correctly
  - **Solution:** Verify ContentDocumentLink exists: Query for LinkedEntityId
- **Cause:** File type not supported (e.g., .txt, .rtf)
  - **Solution:** Convert to PDF or add file type to Data Cloud filter

---

**Issue 5: Trend Analysis Shows Incorrect Percentages**

**Symptoms:**
- Agent says "60% of contracts have Net 30" but manual count shows 40%

**Causes & Solutions:**
- **Cause:** Opportunity custom fields not populated
  - **Solution:** Bulk update Opportunity fields with extracted terms
- **Cause:** SOQL query filter too broad (includes closed-lost opps)
  - **Solution:** Add filter: `StageName != 'Closed Lost'`
- **Cause:** Agent counting documents instead of opportunities
  - **Solution:** Clarify in prompt: "Count unique opportunities, not files"
- **Cause:** Stale data (not refreshed)
  - **Solution:** Clear cache, refresh dashboard

---

## 📚 Additional Resources

### Documentation

**In This Project:**
- `ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md` - Related contract analysis guide
- `MSA_AGENT_ARCHITECTURE.md` - Technical architecture details
- `STARBURST_README.md` - Similar use case for Starburst
- `AGENT_FRAMEWORK_DEVELOPMENT_GUIDE.md` - General agent development guide
- `OPPORTUNITY_FILES_RETRIEVER_GUIDE.md` - File retrieval action guide

**Salesforce Documentation:**
- [Agentforce Setup Guide](https://help.salesforce.com/s/articleView?id=sf.einstein_bots_agentforce.htm)
- [Data Cloud 360 Documentation](https://help.salesforce.com/s/articleView?id=sf.c360_a_intro.htm)
- [RAG Implementation Guide](https://developer.salesforce.com/docs/einstein/genai/guide/rag-overview.html)
- [Prompt Builder Guide](https://help.salesforce.com/s/articleView?id=sf.prompt_builder_overview.htm)

---

## 🎯 Next Steps After Deployment

### Immediate (Week 1)
- [ ] Monitor daily usage and errors
- [ ] Collect user feedback
- [ ] Fix any critical issues
- [ ] Document lessons learned

### Short-term (Month 1)
- [ ] Iterate on agent instructions based on feedback
- [ ] Add more knowledge articles (expand standards library)
- [ ] Integrate with additional contract types (SOWs, amendments, NDAs)
- [ ] Create advanced prompt templates for complex analysis

### Mid-term (Quarter 1)
- [ ] Expand to other teams (Legal, Procurement)
- [ ] Add automated field updates (update Opportunity fields from analysis)
- [ ] Implement proactive alerts (notify when critical risk detected)
- [ ] Develop API integrations (e.g., export analysis to contract management system)

### Long-term (6+ Months)
- [ ] Fine-tune LLM model on your organization's contracts
- [ ] Build predictive models (predict deal closure based on terms)
- [ ] Expand to other documents (invoices, purchase orders, legal opinions)
- [ ] Implement multi-agent system (contract agent, pricing agent, approval agent)

---

## 📞 Support

### Getting Help

**For Technical Issues:**
1. Check Troubleshooting section above
2. Review Salesforce documentation
3. Contact your Salesforce AE or Solution Engineer
4. Post in Salesforce Trailblazer Community

**For Agent Accuracy Issues:**
1. Enable debug mode in Agent Builder
2. Review agent conversation logs
3. Test RAG directly in Data Cloud Vector Search
4. Adjust agent instructions or RAG settings

**For Data Cloud Issues:**
1. Check Data Stream status (Active / Syncing / Error)
2. Review Data Cloud logs
3. Contact Salesforce Data Cloud support

---

## ✅ Final Checklist

Before marking this project complete:

- [ ] All Apex classes deployed and tested (100% test coverage)
- [ ] Custom Opportunity fields created and added to page layouts
- [ ] Data Cloud 360 configured and indexing contract documents
- [ ] Vector embeddings generated for all contracts
- [ ] RAG configuration tested and accurate (95%+ accuracy)
- [ ] Knowledge base created with 5+ standard articles
- [ ] Agentforce agent created with professional greeting and instructions
- [ ] All 5 agent topics created and tested
- [ ] NLU model trained and topic routing works correctly
- [ ] Data sources connected (RAG, Knowledge, Salesforce)
- [ ] Response formatting configured with prompt templates
- [ ] End-to-end testing passed (all 5 scenarios work)
- [ ] Accuracy testing passed (95%+ on factual queries)
- [ ] Performance testing passed (< 20 sec response time)
- [ ] User experience testing passed (intuitive, easy to use)
- [ ] Production deployment completed successfully
- [ ] User training conducted (1-hour session)
- [ ] Monitoring dashboards created and reviewed
- [ ] Post-deployment validation completed (first week checklist)
- [ ] Success metrics baselined and tracked
- [ ] Documentation updated and shared with team

---

## 🎉 Congratulations!

You've successfully deployed an **AI-powered Deal Desk Agent** that will:

✅ Save your team **100+ hours per month**  
✅ Improve contract compliance by **20%+**  
✅ Catch critical risks **before** contracts are signed  
✅ Enable data-driven insights across your contract portfolio  
✅ Empower your Deal Desk team to work smarter, not harder  

**This agent is now:**
- Answering questions about contract standards ✅
- Analyzing contracts for risks and compliance ✅
- Providing trend insights across all opportunities ✅
- Verifying documents for consistency ✅
- Guiding users to standard language ✅

---

**Ready to Build?** Start with **Step 1.1: Environment Verification** above!

**Questions?** Review the documentation or reach out to your Salesforce team.

**Need Help?** Check the Troubleshooting section or Salesforce support.

---

*"The best way to predict the future is to build it."* - Now go build an amazing Deal Desk Agent! 🚀

---

**Document Version:** 1.0  
**Last Updated:** November 24, 2025  
**Author:** AI Assistant + Sam Argo  
**Status:** Ready for Deployment

