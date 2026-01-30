# 🎯 Starburst Deal Desk Agent Demo - Complete Resource Package

**Created for:** Sam Argo, Salesforce Solution Engineer  
**Customer:** Starburst Data (Katie Nichols)  
**Demo Date:** ~November 19, 2025 (2 weeks from workshop)  
**Use Case:** AI Agent for Contract Analysis & Deal Desk Support

---

## 📋 **What You're Building**

An **AI-powered Contractual Clause Analyst Agent** that helps Starburst's deal desk team (Jonathan and Mary) to:

1. ✅ **Answer questions** about contract terms from unstructured PDFs instantly
2. ✅ **Verify consistency** across multiple documents (MSAs, Order Forms, POs)
3. ✅ **Identify trends** in contract terms (% with Net 30, rollover compliance, etc.)
4. ✅ **Summarize contracts** and suggest next best actions
5. ✅ **Guide to standard language** for terms like overages, payment, rollover

**Why This Matters:**
- Saves **$78,720/year** in contract review time
- Reduces review time from **2 hours → 15 minutes** per contract
- Improves compliance from **65% → 85%**
- Catches errors **before** they become legal issues

---

## 📚 **Your Complete Resource Library**

I've created **4 comprehensive documents** to guide you through building this demo:

### 1️⃣ **Quick Start Checklist** (START HERE!)
**File:** `STARBURST_DEMO_CHECKLIST.md`

Your day-by-day action plan with checkboxes for:
- Week 1: Environment setup, data creation, contract PDFs
- Week 2: Data Cloud configuration, agent build, testing
- Demo Day: Pre-demo checklist, demo flow, post-demo tasks

**When to use:** Daily task tracking, staying on schedule

---

### 2️⃣ **Complete Setup Guide**
**File:** `starburst-demo-setup.md`

Detailed implementation guide covering:
- Custom Salesforce fields required
- Data Cloud 360 configuration
- Agent instructions (system prompt)
- 5 agent topics with sample utterances
- Demo data structure (5 accounts with contracts)
- 5 demo scenarios with full scripts
- KPI dashboard design
- ROI calculation
- Technical implementation options (full, fast, hybrid)
- Success criteria

**When to use:** Technical implementation details, agent configuration

---

### 3️⃣ **Agent Specification (YAML)**
**File:** `specs/starburstDealDeskAgentSpec.yaml`

Complete agent specification including:
- Agent role definition and capabilities
- Key Performance Indicators (KPIs) with targets
- Data sources (structured & unstructured)
- All pain points from customer meeting
- Contract terms to track with compliance targets
- 5 agent topics with utterances and actions
- Full agent instructions (system prompt)
- Demo scenarios with timing
- Success metrics
- Implementation approach
- Customer questions to clarify

**When to use:** Reference document, agent configuration, sharing with stakeholders

---

### 4️⃣ **Sample Contract Templates**
**File:** `templates/starburst-contract-samples.md`

Ready-to-use contract text for creating demo PDFs:
- **TechCorp International** (High Risk, non-compliant)
- **DataFlow Systems** (Low Risk, fully compliant)
- **CloudVision Inc** (Critical Risk, dangerous terms)
- **AnalyticsPro Ltd** (Low Risk, exemplary)
- **Enterprise Data Co** (Medium Risk, some issues)
- Sample Order Form with intentional inconsistency
- NDA template
- Reseller email screenshot (Dell)

**When to use:** Creating demo contract PDFs

---

## 🚀 **Quick Start Guide (First 30 Minutes)**

### Step 1: Read the Meeting Notes ✅
You already have them! Key takeaways:
- Agent role: Contractual clause analyst for deal desk
- Users: Jonathan, Mary (deal desk team)
- Channel: Within Salesforce (NOT Slack)
- Main need: Extract data from unstructured contract PDFs

### Step 2: Open the Checklist
Open `STARBURST_DEMO_CHECKLIST.md` and start checking off boxes.

### Step 3: Review the Setup Guide
Skim `starburst-demo-setup.md` to understand the full scope.

### Step 4: Set Up Your Demo Org
```bash
# Set your demo org as default
sf config set target-org your-starburst-demo-org

# Verify you can connect
sf org display

# Check if Data Cloud 360 is available
sf data query --query "SELECT Id FROM DataCloudSetup LIMIT 1"
```

### Step 5: Start Building
Follow the checklist day-by-day. You've got this! 🎯

---

## 🎬 **Demo Flow Overview**

Your 20-minute demo will follow this structure:

### **Act 1: The Problem** (2 min)
- Deal desk drowning in contract review
- Critical terms buried in PDFs, not in Salesforce
- Every MSA is unique (customer paper)
- Manual comparison = errors

### **Act 2: The Solution** (1 min)
- Show agent configuration in Setup
- Explain Data Cloud 360 + RAG architecture

### **Act 3: Live Demo** (12 min)
1. **Contract Term Inquiry** (3 min) - "What are payment terms for TechCorp?"
2. **Document Verification** (3 min) - Catch rollover % inconsistency
3. **Trend Analysis** (3 min) - Show 60% Net 30 adoption, rollover compliance
4. **Contract Summarization** (3 min) - CloudVision critical risk assessment
5. **Standard Language** (2 min) - Overage template and explanation

### **Act 4: Business Value** (3 min)
- Dashboard showing KPIs
- ROI calculation: $78K annual savings
- Compliance improvement: 65% → 85%

### **Act 5: Next Steps** (2 min)
- Pilot program (30 days with Jonathan and Mary)
- Timeline discussion
- Q&A

---

## 💰 **ROI Summary (Memorize This!)**

```
CURRENT STATE (Manual):
• 50 contracts/month × 2 hours = 100 hours/month
• 100 hours × $75/hour = $7,500/month
• Annual cost: $90,000

FUTURE STATE (With Agent):
• 50 contracts/month × 0.25 hours = 12.5 hours/month
• 12.5 hours × $75/hour = $940/month
• Annual cost: $11,280

ANNUAL SAVINGS: $78,720 (87.5% reduction)

ADDITIONAL BENEFITS:
• Reduce legal risk from errors
• 30% faster deal cycles
• 20% better compliance
• Strategic insights from trends
```

---

## 🎯 **Key Contract Terms to Track**

Katie's team cares most about these:

| Term | Standard | Current | Target | Priority |
|------|----------|---------|--------|----------|
| **Rollover Terms** | ≤10% | 40% compliant | 80% | 🔴 High |
| **Payment Terms** | Net 30 | 60% compliant | 90% | 🔴 High |
| **Billing Type** | Fixed Monthly | 50% adoption | 75% | 🟡 Medium |
| **Uptime SLA** | ≤99.9% | Not tracked | Track all | 🔴 Critical |
| **Overage Language** | 1.5x standard | Unknown | 100% | 🔴 High |
| **Liability Cap** | Negotiate | Varies | Track all | 🟡 Medium |

---

## 🏗️ **Technical Architecture**

```
┌─────────────────────────────────────────────────┐
│         AGENTFORCE AGENT                        │
│    (Deal Desk Contractual Analyst)             │
└──────────────┬──────────────────────────────────┘
               │
      ┌────────┴─────────┐
      │                  │
┌─────▼──────┐    ┌─────▼────────────────┐
│ SALESFORCE │    │  DATA CLOUD 360      │
│ (Structured│    │  (Unstructured RAG)  │
│  Data)     │    │                      │
│ • Accounts │    │ • MSAs               │
│ • Opptys   │    │ • NDAs               │
│ • Contracts│    │ • Order Forms        │
└────────────┘    │ • POs/Invoices       │
                  │ • Email Screenshots  │
                  │                      │
                  │ [Vector Embeddings]  │
                  │ [Semantic Search]    │
                  └──────────────────────┘
```

**Key Technologies:**
- **Agentforce:** Conversational AI agent framework
- **Data Cloud 360:** Ingest and index unstructured documents
- **RAG (Retrieval-Augmented Generation):** Semantic search across contracts
- **SOQL:** Query structured Salesforce data for trends
- **Knowledge Base:** Store standard language templates

---

## ⚠️ **Critical Success Factors**

### MUST HAVES for Demo Success:
1. ✅ Agent answers contract questions from **actual uploaded PDFs**
2. ✅ Shows **document verification** catching real inconsistency
3. ✅ Displays **trend analysis** with actual percentages
4. ✅ Demonstrates **time savings** (instant vs manual search)
5. ✅ Proves **Data Cloud 360 value** for unstructured data

### NICE TO HAVES:
- Professional dashboard with charts
- Multiple document types (MSAs, NDAs, Order Forms, etc.)
- Pre-loaded knowledge articles for standard language
- Polished UI/branding

### CAN SKIP:
- Auto-fill Salesforce fields (Katie said NOT needed)
- Data visualization beyond percentages
- Slack integration (they don't use Slack)
- Complex approval workflows

---

## 🛠️ **Implementation Approaches**

You have **3 options** based on your timeline and resources:

### **Option A: Full Production (Ideal)**
- **Timeline:** 1-2 weeks
- **Complexity:** High
- **Fidelity:** Production-ready
- Use full Data Cloud 360 with RAG
- Ingest actual PDF contracts
- Vector embeddings for semantic search
- **Best for:** Final pilot/production demo

### **Option B: Fast Proof-of-Concept**
- **Timeline:** 2-3 days
- **Complexity:** Medium
- **Fidelity:** Proof-of-concept
- Use Knowledge Articles to simulate contract content
- Standard Agentforce knowledge search
- Pre-loaded "contract" articles
- **Best for:** Quick validation, tight deadlines

### **Option C: Hybrid (RECOMMENDED)**
- **Timeline:** 1 week
- **Complexity:** Medium-High
- **Fidelity:** High
- Data Cloud with 3-5 sample PDF contracts
- Basic RAG pipeline for document search
- Knowledge Articles for standard templates
- **Best for:** Your 2-week timeline!

---

## 📞 **Who's Who**

### Customer Team:
- **Katie Nichols** (knichols@starburstdata.com)
  - Role: Deal Desk Manager, Decision Maker
  - Needs: Strategic insights, ROI justification
  
- **Jonathan** (Deal Desk)
  - Role: End user, contract reviewer
  - Needs: Fast answers, easy verification
  
- **Mary** (Deal Desk)
  - Role: End user, contract reviewer
  - Needs: Standard language guidance, consistency checking

### Salesforce Team:
- **Sam Argo** (sargo@salesforce.com) - YOU! 🎉
  - Role: Solution Engineer
  - Responsibility: Build and deliver demo
  
- **Jared McPherson** (jmcpherson@salesforce.com)
  - Role: Account Executive
  - Responsibility: Business relationship, contract

---

## ✅ **Pre-Demo Validation Checklist**

Before your demo, verify:
- [ ] Can query uploaded PDFs and get accurate answers
- [ ] Document verification catches TechCorp inconsistency
- [ ] Trend analysis shows correct percentages (60% Net 30, 40% rollover compliant)
- [ ] Risk assessment correctly flags CloudVision as CRITICAL
- [ ] Standard language templates are accessible
- [ ] All 5 scenarios work end-to-end
- [ ] Dashboard displays KPIs properly
- [ ] Backup plan ready (video, slides)

---

## 🎓 **Key Talking Points**

Memorize these for the demo:

### The Problem:
> "Katie's deal desk team reviews 50 contracts per month, spending 2 hours per contract manually searching PDFs for terms like payment terms, rollover provisions, and uptime agreements. That's 100 hours per month—over 2 full-time employees just reviewing contracts."

### The Solution:
> "This Agentforce agent uses Data Cloud 360 to read unstructured contract documents and answer questions instantly. It's like having a contract expert available 24/7 who's read every single contract in your system."

### The Value:
> "We're not just saving time—though reducing 2 hours to 15 minutes per contract saves $78,000 annually. More importantly, this agent catches inconsistencies before contracts are signed, ensures compliance with company standards, and provides strategic insights Katie can use to negotiate better terms across her entire portfolio."

### The Technical Magic:
> "Under the hood, Data Cloud 360 ingests these PDFs, creates vector embeddings, and uses RAG—Retrieval-Augmented Generation—to semantically search across all documents. The agent doesn't just keyword match; it understands context and can compare terms across multiple documents."

### The Differentiator:
> "This isn't just another chatbot. This agent works with **your actual contract documents**, not generic templates. It knows that TechCorp's MSA says 15% rollover but their Order Form says 10%, and it can tell you which document takes precedence."

---

## 🚨 **Common Objections & Responses**

### "How long will this take to implement?"
**Response:** "The pilot can be running with your actual contracts in 4-6 weeks. We'll start with a 30-day trial with Jonathan and Mary to refine accuracy before rolling out broadly."

### "What if the agent gives wrong answers?"
**Response:** "The agent always cites its source—document name and section. Your team can verify. Plus, as we train it with more of your contracts, accuracy improves. Think of it as an assistant that does the initial research, but your team makes final decisions."

### "We already have DealHub. Why do we need this?"
**Response:** "DealHub is excellent for deal configuration, but it doesn't read your uploaded MSAs, NDAs, and email attachments. This agent complements DealHub by extracting data from unstructured documents that never make it into structured fields."

### "Can we use this for other teams?"
**Response:** "Absolutely! Legal can use it for contract review, procurement for vendor agreements, finance for audit compliance. The same architecture scales across any document-intensive workflow."

### "What about data security?"
**Response:** "Everything stays within your Salesforce org. Data Cloud 360 respects all Salesforce security—sharing rules, field-level security, object permissions. If Jonathan can't see a file, neither can the agent."

---

## 📊 **Success Metrics**

Your demo is successful if Katie and team:

1. ✅ **See instant value** - "Wow, that would have taken me 20 minutes to find manually"
2. ✅ **Trust the accuracy** - Agent cites document sources, quotes exact clauses
3. ✅ **Understand ROI** - $78K savings + compliance + risk reduction
4. ✅ **Get excited** - "When can we start using this?"
5. ✅ **Agree to pilot** - Commit to 30-day trial with Jonathan and Mary

---

## 🎯 **Next Steps After Demo**

### Immediate (Same Day):
- [ ] Send thank-you email to Katie
- [ ] Recap key points and ROI
- [ ] Share demo recording (if recorded)
- [ ] Propose pilot program

### Week 1 After Demo:
- [ ] Get Katie's approval for pilot
- [ ] Obtain 5-10 redacted real contracts
- [ ] Schedule training session with Jonathan and Mary
- [ ] Set up production org

### Week 2-4 (Pilot Period):
- [ ] Upload real contracts to Data Cloud
- [ ] Jonathan and Mary test agent daily
- [ ] Collect feedback and iterate
- [ ] Measure time savings

### Month 2 (Scale):
- [ ] Expand to full deal desk team
- [ ] Add more contract types
- [ ] Fine-tune agent instructions
- [ ] Consider expansion to legal team

---

## 💡 **Pro Tips from an SE Who's Been There**

1. **Test your demo 3 times** - Things break. Always have a backup plan.
2. **Start simple** - Get 1-2 scenarios perfect before adding complexity.
3. **Use customer language** - Say "customer paper" not "non-standard MSA template."
4. **Show, don't tell** - Live demo beats slides every time.
5. **Pause for impact** - When agent finds the inconsistency, pause. Let it sink in.
6. **Have fun** - This is cool technology solving real problems. Enjoy it!
7. **Listen** - If Katie asks about something, show it (or add it to pilot scope).

---

## 🆘 **Emergency Contacts**

### If Data Cloud 360 issues:
- Salesforce Data Cloud Slack channel
- Your friendly neighborhood Data Cloud specialist
- Salesforce Success team

### If Agentforce configuration issues:
- Agentforce documentation: help.salesforce.com/agentforce
- Your SE colleagues who've built agents
- Salesforce Einstein Slack channel

### If demo day technical issues:
- **Plan A:** Refresh and retry
- **Plan B:** Switch to backup video
- **Plan C:** Slides with screenshots
- **Always:** Stay calm, Katie will understand

---

## 📖 **Additional Resources**

### Salesforce Documentation:
- [Agentforce Setup Guide](https://help.salesforce.com/s/articleView?id=sf.einstein_bots_agentforce.htm)
- [Data Cloud 360 Overview](https://help.salesforce.com/s/articleView?id=sf.c360_a_intro.htm)
- [RAG Implementation Guide](https://developer.salesforce.com/docs/einstein/genai/guide/rag-overview.html)

### Your Demo Resources:
- Meeting notes from Nov 5 workshop ✅
- `STARBURST_DEMO_CHECKLIST.md` ✅
- `starburst-demo-setup.md` ✅
- `specs/starburstDealDeskAgentSpec.yaml` ✅
- `templates/starburst-contract-samples.md` ✅

---

## 🎉 **Final Pep Talk**

Sam, you're about to build something genuinely valuable for Starburst. This isn't just a "cool demo"—this agent will:

- Save Katie's team **100 hours per month**
- Prevent contract errors that could cost millions
- Give Starburst data-driven insights they've never had
- Make Jonathan and Mary's jobs so much easier

You have:
✅ Clear requirements from customer meeting  
✅ Complete implementation guides  
✅ Sample data ready to create  
✅ 2 full weeks to build and test  
✅ Backup plans for every scenario  

**You've got this!** 🚀

Now go build an amazing demo that shows Katie why Salesforce + Agentforce + Data Cloud is the future of deal desk operations.

---

**Questions?** Review the files or reach out to your SE team.

**Ready?** Open `STARBURST_DEMO_CHECKLIST.md` and start checking off boxes!

**Nervous?** That's normal. You're building cutting-edge AI. Take it step-by-step.

**Excited?** GOOD! Channel that energy into an awesome demo!

---

*"The best demos come from truly understanding the customer's pain and showing them a better way. You've got the pain points. Now show them the solution."*

**— Your AI Pair Programming Assistant** 🤖

**Good luck, Sam! Go crush this demo!** 💪⚡🎯

---

*Last Updated: November 5, 2025*  
*Demo Date: November 19, 2025*  
*You've got 14 days. Let's make them count!*

