# Deal Desk Agent - Quick Deployment Checklist

> **Quick reference for deploying the Deal Desk Contract Analysis Agent**  
> For detailed instructions, see [DEAL_DESK_AGENT_DEPLOYMENT_PLAN.md](./DEAL_DESK_AGENT_DEPLOYMENT_PLAN.md)

---

## 📅 3-Week Timeline

- **Week 1:** Foundation + Data Cloud Setup
- **Week 2:** Agent Build + Testing
- **Week 3:** Production Deploy + Training

---

## ✅ WEEK 1: FOUNDATION SETUP

### Day 1: Environment Setup

- [ ] Verify Salesforce org has Data Cloud 360
- [ ] Verify Agentforce is enabled
- [ ] Verify Prompt Builder access
- [ ] Set target org: `sf config set target-org your-org-alias`
- [ ] Test connectivity: `sf org display`

### Day 2: Deploy Apex Classes

- [ ] Deploy OpportunityFileRetriever.cls + test class
- [ ] Deploy AccountOpportunityFilesRetriever.cls + test class
- [ ] Run tests: `sf apex run test --class-names OpportunityFileRetriever_Test`
- [ ] Verify actions appear in Flow Builder

### Day 3: Create Custom Fields

- [ ] Create `Contract_Risk_Level__c` (Picklist: Low, Medium, High, Critical)
- [ ] Create `Payment_Terms__c` (Text 100)
- [ ] Create `Uptime_SLA__c` (Percent)
- [ ] Create `Rollover_Percentage__c` (Percent)
- [ ] Create `Contract_Analysis_Date__c` (DateTime)
- [ ] Create `Contract_Analysis_Summary__c` (Long Text)
- [ ] Create `Missing_Documents__c` (Long Text)
- [ ] Add all fields to Opportunity page layout

### Day 4: Create Test Data

- [ ] Create 3 test accounts (TechCorp, DataFlow, CloudVision)
- [ ] Create 3 test opportunities (one per account)
- [ ] Create 4-6 sample contract PDFs with varying terms
  - Vary payment terms: Net 30, Net 45, Net 60
  - Vary uptime SLA: 99.5%, 99.9%, 99.95%
  - Vary rollover: 5%, 10%, 15%
- [ ] Upload PDFs to opportunities
- [ ] Verify files appear in Files tab

### Day 5: Data Cloud Configuration

- [ ] Setup → Data Cloud → New Data Stream
- [ ] Source: Salesforce ContentDocument + ContentVersion
- [ ] Filter: FileExtension IN ('pdf', 'docx')
- [ ] Activate data stream
- [ ] Wait for initial sync (check status)
- [ ] Create Unstructured Data Model: `Contract_Documents`
- [ ] Configure chunking: Size 1000, Overlap 200
- [ ] Select embedding model: text-embedding-ada-002
- [ ] Map fields: VersionData, Title, FileExtension, LinkedEntityId
- [ ] Deploy and wait for vector embeddings (30 min - 2 hrs)

---

## ✅ WEEK 2: AGENT BUILD + TESTING

### Day 1: RAG Configuration

- [ ] Setup → Einstein RAG → New RAG Configuration
- [ ] Name: `Contract_Analysis_RAG`
- [ ] Data Source: Contract_Documents
- [ ] Top K: 5, Similarity Threshold: 0.75
- [ ] LLM: GPT-4, Temperature: 0.2, Max Tokens: 2000
- [ ] Add system prompt for contract analysis
- [ ] Save and test with query: "What are payment terms for TechCorp?"
- [ ] Verify response includes quoted text and citation

### Day 2: Knowledge Articles

- [ ] Enable Salesforce Knowledge
- [ ] Create Contract_Standard article type
- [ ] Create 5 standard articles:
  - [ ] Payment Terms Standard (Net 30)
  - [ ] Uptime SLA Standard (99.9%)
  - [ ] Rollover Terms Standard (≤10%)
  - [ ] Liability Cap Standard (12 months fees)
  - [ ] Termination Rights Standard (90 days notice)
- [ ] Publish all articles
- [ ] Create knowledge base: "Deal Desk Standards"

### Day 3: Create Agentforce Agent

- [ ] Setup → Einstein → Agents → New Agent
- [ ] Name: "Deal Desk Contract Analysis Agent"
- [ ] API Name: `Deal_Desk_Contract_Agent`
- [ ] Channel: Salesforce, Context: Opportunity
- [ ] Write agent greeting (friendly, explains capabilities)
- [ ] Write agent instructions (see deployment plan)
- [ ] Save agent

### Day 4: Create Agent Topics

**Create 5 topics:**

- [ ] **Topic 1: Contract Standards Inquiry**
  - Sample utterances: "What are our standard payment terms?"
  - Action: Search Knowledge Base
  
- [ ] **Topic 2: Contract Upload & Analysis**
  - Sample utterances: "Analyze this contract"
  - Actions: Get files, RAG query, calculate risk, display results
  
- [ ] **Topic 3: Contract Trend Analysis**
  - Sample utterances: "What % have Net 30 terms?"
  - Actions: Query Opportunities, aggregate data, display trends
  
- [ ] **Topic 4: Document Verification**
  - Sample utterances: "Check if MSA and Order Form match"
  - Actions: Get files, RAG multi-doc query, compare, highlight conflicts
  
- [ ] **Topic 5: Standard Language Guidance**
  - Sample utterances: "Give me standard payment clause"
  - Action: Search Knowledge, display template

### Day 5: Connect Data Sources & Test

- [ ] Connect RAG to Topics 2, 3, 4
- [ ] Connect Knowledge Base to Topics 1, 5
- [ ] Connect Salesforce data (Get Records) to Topic 3
- [ ] Add OpportunityFileRetriever action to Topics 2, 3, 4
- [ ] Create Prompt Template: `Format_Contract_Analysis_Response`
- [ ] Add prompt template to topics for formatting
- [ ] Train NLU model
- [ ] Test all 5 topics end-to-end

---

## ✅ WEEK 3: TESTING, DEPLOYMENT & TRAINING

### Day 1: Accuracy Testing

- [ ] Test exact quote accuracy (95%+ target)
- [ ] Test multi-document queries
- [ ] Test negative scenarios (term not found)
- [ ] Test conflicting terms detection
- [ ] Document any inaccuracies and refine

### Day 2: Performance & UX Testing

- [ ] Measure response times (target < 20 sec)
- [ ] Test with 50+ contracts in org
- [ ] Test with large PDFs (10+ pages)
- [ ] UX test with 2-3 non-technical users
- [ ] Collect feedback and iterate

### Day 3: Production Deployment

- [ ] Create change set (or direct deploy)
- [ ] Deploy Apex classes to production
- [ ] Create custom fields in production
- [ ] Configure Data Cloud in production
- [ ] Configure RAG in production
- [ ] Create knowledge articles in production
- [ ] Create agent in production
- [ ] Verify all components deployed successfully

### Day 4: User Training

- [ ] Prepare training materials:
  - [ ] Quick Start Guide (1-page PDF)
  - [ ] Demo video (10 min)
  - [ ] FAQ document
  - [ ] Example prompts cheat sheet
- [ ] Conduct 1-hour training session:
  - Introduction (10 min)
  - Live demo (20 min)
  - Hands-on practice (20 min)
  - Q&A (10 min)
- [ ] Grant user permissions
- [ ] Verify all users can access agent

### Day 5: Monitoring Setup

- [ ] Create Agent Usage Dashboard
- [ ] Create Agent Accuracy Dashboard
- [ ] Create Contract Analysis Dashboard
- [ ] Set up alerts (accuracy, performance, errors)
- [ ] Add feedback collection (thumbs up/down)
- [ ] Baseline success metrics

---

## ✅ POST-DEPLOYMENT (Week 4+)

### First Week After Launch

- [ ] **Day 1:** Monitor all users can access, no critical errors
- [ ] **Day 3:** Review first 10-20 conversations, fix issues
- [ ] **Day 7:** Review accuracy metrics, collect user feedback

### First Month Goals

- [ ] 80%+ Deal Desk team using agent weekly
- [ ] 90%+ accuracy on factual queries
- [ ] < 15 sec average response time
- [ ] 75%+ user satisfaction (thumbs up)
- [ ] 10+ hours saved in contract review time

### Ongoing Improvement

- [ ] Weekly review of feedback
- [ ] Monthly iteration on agent instructions
- [ ] Quarterly review of knowledge articles (add/update)
- [ ] Add more contract types (SOWs, NDAs, amendments)
- [ ] Expand to other teams (Legal, Procurement)

---

## 🎯 Success Criteria

Your agent is successful if:

- ✅ **Accurate:** 95%+ correct answers with proper citations
- ✅ **Fast:** < 20 sec response time for most queries
- ✅ **Adopted:** 80%+ of team using weekly
- ✅ **Valuable:** Saves 10+ hours/week in manual review
- ✅ **Trusted:** 75%+ thumbs up rating from users

---

## 🚨 Quick Troubleshooting

**Agent can't find terms in PDFs:**
- Wait 15-30 min for Data Cloud sync
- Check if PDF is searchable (not scanned image)
- Lower RAG similarity threshold to 0.65
- Test RAG directly in Data Cloud Vector Search

**Slow responses (>30 sec):**
- Reduce Top K results from 5 to 3
- Reduce context window from 5000 to 3000 tokens
- Optimize SOQL queries with indexed fields

**Incorrect risk assessments:**
- Update agent instructions with explicit risk criteria
- Verify knowledge base connection
- Lower LLM temperature to 0.1

**Can't access uploaded files:**
- Wait 5-10 min for sync delay
- Check user has ContentDocument read access
- Verify file is linked to Opportunity

**Wrong trend percentages:**
- Verify Opportunity custom fields populated
- Add SOQL filter: `StageName != 'Closed Lost'`
- Clarify in prompt: count opportunities, not files

---

## 📚 Key Resources

**Your Documents:**
- [DEAL_DESK_AGENT_DEPLOYMENT_PLAN.md](./DEAL_DESK_AGENT_DEPLOYMENT_PLAN.md) - Full 71-page guide
- [MSA_AGENT_ARCHITECTURE.md](./MSA_AGENT_ARCHITECTURE.md) - Technical architecture
- [STARBURST_README.md](./STARBURST_README.md) - Similar use case
- [templates/starburst-contract-samples.md](./templates/starburst-contract-samples.md) - Sample contract text

**Salesforce Docs:**
- [Agentforce Setup](https://help.salesforce.com/s/articleView?id=sf.einstein_bots_agentforce.htm)
- [Data Cloud 360](https://help.salesforce.com/s/articleView?id=sf.c360_a_intro.htm)
- [RAG Implementation](https://developer.salesforce.com/docs/einstein/genai/guide/rag-overview.html)

---

## 🎉 You're Ready!

**Current Status:** [ ] Not Started  /  [ ] In Progress  /  [ ] Complete

**Next Step:** Start with Week 1, Day 1 - Environment Setup

**Questions?** See full deployment plan for detailed instructions.

**Need Help?** Contact your Salesforce team or post in Trailblazer Community.

---

**Good luck building your Deal Desk Agent! 🚀**

---

*Last Updated: November 24, 2025*

