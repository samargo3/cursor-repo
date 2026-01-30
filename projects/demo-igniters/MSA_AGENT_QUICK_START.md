# 🚀 MSA Analysis Agent - Quick Start

**Goal:** Build an Agentforce Agent that reads MSAs from Opportunities and answers questions about contract terms.

**Time to Demo:** 1 week with Hybrid approach

---

## 📖 What's Included

Your complete resource package:

### 📚 Documentation
- **MSA_ANALYSIS_AGENT_GUIDE.md** ⭐ (START HERE) - Complete implementation guide
- **specs/starburstDealDeskAgentSpec.yaml** - Full agent specification
- **templates/starburst-contract-samples.md** - 5 ready-to-use contract templates

### 💻 Code
- **ContractAnalysisAgent.cls** - Invocable Apex for risk assessment
- **ContractAnalysisAgentTest.cls** - Test coverage
- **setup-msa-agent.sh** - Automated setup script

### ✅ Checklists
- **STARBURST_DEMO_CHECKLIST.md** - Day-by-day action plan
- **STARBURST_README.md** - Complete demo resource package

---

## ⚡ 5-Minute Quick Start

### Step 1: Read the Guide
Open and read: **MSA_ANALYSIS_AGENT_GUIDE.md**

This comprehensive guide covers:
- ✅ 3 implementation approaches (choose Hybrid for demos)
- ✅ Step-by-step setup (12-day plan)
- ✅ Agent configuration with sample topics
- ✅ Data Cloud 360 + RAG setup
- ✅ Testing scenarios
- ✅ Troubleshooting tips

### Step 2: Choose Your Approach

**Option A: Full Production** (1-2 weeks)
- Complete Data Cloud 360 with RAG
- Reads actual uploaded PDF contracts
- Best for: Production deployments

**Option B: Fast POC** (2-3 days)
- Knowledge Articles simulate contracts
- No additional licenses needed
- Best for: Quick validation

**Option C: Hybrid** ⭐ RECOMMENDED (1 week)
- Data Cloud with 5-10 sample contracts
- Knowledge Articles for templates
- Best for: Realistic demos

### Step 3: Run Setup Script

```bash
# Authenticate to your demo org
sf org login web --alias msa-demo

# Run automated setup
cd /Users/sargo/Documents/demo-igniters/demo-igniters
./scripts/setup-msa-agent.sh msa-demo
```

This script:
- ✅ Deploys ContractAnalysisAgent Apex class
- ✅ Runs tests
- ✅ Creates 5 sample Accounts
- ✅ Creates 3 sample Opportunities
- ✅ Provides next steps

### Step 4: Create Contract PDFs

Use the provided templates in `templates/starburst-contract-samples.md`:

1. **TechCorp** - High Risk (Net 60, 15% rollover, 1.8x overage)
2. **DataFlow** - Low Risk (All standard terms)
3. **CloudVision** - Critical Risk (99.999% uptime, 20% rollover)
4. **AnalyticsPro** - Low Risk (Exemplary contract)
5. **Enterprise Data** - Medium Risk (Net 45, 1.6x overage)

**Quick PDF Creation:**
```bash
# Method 1: Google Docs/Word
# Copy template text → Format → Export as PDF

# Method 2: Markdown to PDF
brew install pandoc
pandoc templates/starburst-contract-samples.md -o contracts/TechCorp-MSA.pdf
```

### Step 5: Upload PDFs to Salesforce

1. Open Opportunity in Salesforce
2. Go to **Files** tab
3. Click **Upload Files**
4. Select the MSA PDF
5. Repeat for each Opportunity

### Step 6: Configure Agent

Navigate to: **Setup → Agentforce → Agents → New**

Copy configuration from **MSA_ANALYSIS_AGENT_GUIDE.md**, Section "Phase 4: Agent Configuration"

**5 Topics to Create:**
1. Contract Term Inquiry
2. Contract Summarization
3. Document Verification
4. Trend Analysis
5. Standard Language Guidance

### Step 7: Test

Open an Opportunity with a contract and ask:
- "What are the payment terms for this contract?"
- "Summarize this MSA and assess risk"
- "Compare the MSA and Order Form"

---

## 🎯 Architecture Overview

```
USER QUESTION
    ↓
AGENTFORCE AGENT
    ↓
    ├──→ SALESFORCE DATA (Accounts, Opportunities)
    └──→ DATA CLOUD 360 RAG
         ↓
         ├──→ MSA PDFs
         ├──→ Order Forms
         └──→ NDAs
         
         [Vector Embeddings + Semantic Search]
         
    ↓
ANSWER + CITATION
```

---

## 📋 Implementation Checklist

### Week 1: Data & Setup
- [ ] Day 1: Run setup script
- [ ] Day 2: Create 5 contract PDFs
- [ ] Day 3: Upload PDFs to Opportunities
- [ ] Day 4: Configure Data Cloud 360
- [ ] Day 5: Test RAG document retrieval

### Week 2: Agent & Testing
- [ ] Day 6: Create Agentforce Agent
- [ ] Day 7: Configure 5 topics
- [ ] Day 8: Create Knowledge Articles
- [ ] Day 9: Test all scenarios
- [ ] Day 10: Build demo dashboard
- [ ] Day 11: Dry run
- [ ] Day 12: Demo day prep

---

## 🎬 Demo Scenarios

### Scenario 1: Term Inquiry (2 min)
**Setup:** TechCorp Opportunity with MSA attached  
**User:** "What are the payment terms for TechCorp?"  
**Expected:** "Net 60 days per MSA Section 2. [Quote]. NOTE: Non-standard."

### Scenario 2: Risk Assessment (3 min)
**Setup:** CloudVision Opportunity  
**User:** "Summarize this contract and assess risk"  
**Expected:** "CRITICAL RISK - 99.999% uptime, 20% rollover..."

### Scenario 3: Document Verification (3 min)
**Setup:** TechCorp with MSA + Order Form  
**User:** "Compare the MSA and Order Form"  
**Expected:** "INCONSISTENCY: MSA shows 15% rollover, Order Form shows 10%"

### Scenario 4: Trend Analysis (2 min)
**User:** "What % of contracts have Net 30 terms?"  
**Expected:** "60% (3 of 5) have Net 30: DataFlow, AnalyticsPro..."

### Scenario 5: Standard Language (2 min)
**User:** "What's our standard payment terms language?"  
**Expected:** [Returns Knowledge Article with template]

---

## 💰 ROI Summary

**Time Savings:**
- Current: 30-60 min per contract × 50 contracts/month = 25-50 hours
- With Agent: 5-10 min per contract × 50 contracts/month = 4-8 hours
- **Savings: 21-42 hours/month = $2,100-4,200/month**

**Annual ROI: $25K-50K**

**Additional Benefits:**
- Catch contract errors before signing
- Improve compliance by 20-30%
- Enable faster deal cycles
- Provide strategic insights

---

## 🆘 Troubleshooting

### Agent can't find documents
**Fix:** Verify files are uploaded and Data Cloud RAG is indexing PDFs
```bash
# Check files exist
sf data query --query "SELECT Id, Title FROM ContentDocument WHERE Title LIKE '%MSA%'"

# Check Data Cloud indexing
Setup → Data Cloud → Data Streams → Refresh
```

### Agent responses are inaccurate
**Fix:** Refine agent instructions, add more context to system prompt

### RAG not retrieving relevant chunks
**Fix:** Adjust chunk size and overlap in Data Cloud RAG config

---

## 📚 Full Documentation

For complete details, see:

**Primary Guide:**
- **MSA_ANALYSIS_AGENT_GUIDE.md** - 50+ pages covering every aspect

**Reference Materials:**
- **specs/starburstDealDeskAgentSpec.yaml** - Agent specification
- **templates/starburst-contract-samples.md** - Contract templates
- **STARBURST_README.md** - Demo package overview
- **STARBURST_DEMO_CHECKLIST.md** - Daily checklist

**Code:**
- **ContractAnalysisAgent.cls** - Apex invocable action
- **ContractAnalysisAgentTest.cls** - Test class

---

## 🎯 Success Criteria

Your demo is successful when:
- ✅ Agent answers questions from actual uploaded PDFs
- ✅ Document citations are accurate (file name + section)
- ✅ Risk assessment identifies issues correctly
- ✅ Document verification catches inconsistencies
- ✅ Trend analysis shows correct percentages
- ✅ Users understand the value ($25K-50K annual savings)

---

## 🚀 Next Steps

1. **Read:** Open MSA_ANALYSIS_AGENT_GUIDE.md
2. **Setup:** Run ./scripts/setup-msa-agent.sh
3. **Build:** Create contract PDFs and upload
4. **Configure:** Set up Data Cloud + Agent
5. **Test:** Validate all 5 demo scenarios
6. **Demo:** Deliver compelling presentation

---

## ❓ Common Questions

**Q: Do I need Data Cloud 360?**  
A: For production, yes. For demo, you can use Knowledge Articles (Option B).

**Q: How long to set up?**  
A: Hybrid approach: 1 week. Fast POC: 2-3 days. Full production: 1-2 weeks.

**Q: Can I use this for other document types?**  
A: Yes! Works for NDAs, Order Forms, amendments, any contract document.

**Q: What about non-PDF files?**  
A: Data Cloud supports PDF and DOCX. Other formats require conversion.

**Q: How accurate is document extraction?**  
A: 80-85% out of box, 90%+ with tuning. Always cite sources for verification.

---

## 💡 Pro Tips

1. **Start simple** - Get 2-3 scenarios perfect before expanding
2. **Use real contract language** - Makes demo more believable
3. **Show the inconsistency catch** - This is the "wow" moment
4. **Emphasize time savings** - 30 min → 5 min per contract
5. **Have backup plan** - Demo video if live demo fails

---

## 📞 Support

**For technical issues:**
- Review troubleshooting section in MSA_ANALYSIS_AGENT_GUIDE.md
- Check Salesforce Agentforce documentation
- Reach out to your SE team

**For demo questions:**
- Reference STARBURST_README.md for full context
- Use STARBURST_DEMO_CHECKLIST.md for task tracking

---

## ✅ You're Ready When...

- [ ] You've read MSA_ANALYSIS_AGENT_GUIDE.md
- [ ] Setup script has run successfully
- [ ] 5 contract PDFs are created and uploaded
- [ ] Data Cloud is indexing documents
- [ ] Agent has 5 topics configured
- [ ] All 5 demo scenarios work
- [ ] You can explain the ROI ($25K-50K/year)
- [ ] Backup materials are ready

---

**Now go build an amazing MSA Analysis Agent!** 🚀

---

*Questions? Start with MSA_ANALYSIS_AGENT_GUIDE.md for complete details.*

