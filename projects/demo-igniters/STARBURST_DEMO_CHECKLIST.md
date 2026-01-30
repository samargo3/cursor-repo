# 🚀 Starburst Deal Desk Agent Demo - Quick Checklist

**Customer:** Starburst Data (Katie Nichols)  
**Demo Date:** ~November 19, 2025  
**Your Timeline:** 2 weeks to build  
**Status:** 🔴 Not Started → 🟡 In Progress → 🟢 Complete

---

## 📅 **WEEK 1: Foundation (Nov 5-12)**

### Day 1-2: Environment Setup
- [ ] 🟢 Review meeting notes (DONE - you have them!)
- [ ] 🟢 Read `starburst-demo-setup.md` (DONE - created for you!)
- [ ] 🟢 Review `starburstDealDeskAgentSpec.yaml` (DONE - created!)
- [ ] ⚪ Provision demo org or sandbox with Agentforce
- [ ] ⚪ Verify Data Cloud 360 is available in org
- [ ] ⚪ Set default org: `sf config set target-org your-starburst-demo-org`

### Day 3-4: Salesforce Configuration
- [ ] ⚪ Create custom fields on Opportunity:
  - [ ] Rollover_Terms__c (Percent)
  - [ ] Payment_Terms__c (Picklist)
  - [ ] Billing_Type__c (Picklist)
  - [ ] Uptime_Agreement__c (Percent)
  - [ ] Overage_Language__c (Text Area)
  - [ ] Limitation_of_Liability__c (Currency)
  - [ ] Contract_Compliance_Score__c (Number)
  
- [ ] ⚪ Create custom fields on Account:
  - [ ] MSA_Type__c (Picklist)
  - [ ] MSA_Upload_Date__c (Date)
  - [ ] Last_Contract_Review__c (Date)
  - [ ] Contract_Risk_Level__c (Picklist)

- [ ] ⚪ Add fields to page layouts (Account, Opportunity)

### Day 5-6: Demo Data Creation
- [ ] ⚪ Create 5 demo accounts:
  - [ ] TechCorp International (Customer Paper, HIGH risk)
  - [ ] DataFlow Systems (Standard MSA, LOW risk)
  - [ ] CloudVision Inc (Customer Paper, CRITICAL risk)
  - [ ] AnalyticsPro Ltd (Standard MSA, LOW risk)
  - [ ] Enterprise Data Co (Hybrid MSA, MEDIUM risk)

- [ ] ⚪ Create opportunities for each account
- [ ] ⚪ Populate custom fields with demo data
- [ ] ⚪ Create primary contacts (Jonathan, Mary)

### Day 7: Contract Documents
- [ ] ⚪ Create 5 MSA PDFs from `starburst-contract-samples.md`:
  - [ ] TechCorp MSA (Net 60, 15% rollover, 1.8x overage)
  - [ ] DataFlow MSA (Net 30, 8% rollover, 1.5x overage) ✅ Compliant
  - [ ] CloudVision MSA (Net 45, 20% rollover, 99.999% uptime) ⚠️ Critical
  - [ ] AnalyticsPro MSA (Net 30, 5% rollover, 1.5x overage) ✅ Compliant
  - [ ] Enterprise Data MSA (Net 45, 10% rollover, 1.6x overage)

- [ ] ⚪ Create 1 Order Form PDF (TechCorp with inconsistency)
- [ ] ⚪ Create 1 NDA PDF (DataFlow)
- [ ] ⚪ Upload PDFs to Salesforce:
  - [ ] MSAs → Account level
  - [ ] Order Forms → Opportunity level
  - [ ] Verify files are searchable

---

## 📅 **WEEK 2: Agent Build & Testing (Nov 12-19)**

### Day 8-9: Data Cloud 360 Setup
- [ ] ⚪ Navigate to Data Cloud setup in Salesforce
- [ ] ⚪ Create data stream for ContentDocument (Files)
- [ ] ⚪ Configure data source connections:
  - [ ] Salesforce Accounts
  - [ ] Salesforce Opportunities
  - [ ] Salesforce Files (ContentDocument/ContentVersion)

- [ ] ⚪ Set up RAG (Retrieval-Augmented Generation):
  - [ ] Enable semantic search
  - [ ] Index uploaded contract PDFs
  - [ ] Test document retrieval
  
- [ ] ⚪ Alternative: Create Knowledge Articles for quick demo:
  - [ ] Article: "Standard Payment Terms (Net 30)"
  - [ ] Article: "Rollover Terms Policy (≤10%)"
  - [ ] Article: "Overage Pricing (1.5x)"
  - [ ] Article: "Uptime SLA Standards (99.9%)"
  - [ ] Article: "Limitation of Liability Template"

### Day 10-11: Agent Creation
- [ ] ⚪ Navigate to Setup → Agentforce → Agents → New
- [ ] ⚪ Configure agent basics:
  - [ ] Name: "Deal Desk Contractual Clause Analyst"
  - [ ] Description: Copy from `starburstDealDeskAgentSpec.yaml`
  
- [ ] ⚪ Add Agent Instructions (system prompt):
  - [ ] Copy from spec file
  - [ ] Include standard language templates
  - [ ] Define workflow and priorities
  
- [ ] ⚪ Create 5 Topics:
  - [ ] **Topic 1:** Contract Term Inquiry
    - [ ] Add sample utterances
    - [ ] Configure search action (Data Cloud/Knowledge)
  
  - [ ] **Topic 2:** Document Verification
    - [ ] Add sample utterances
    - [ ] Configure comparison logic
  
  - [ ] **Topic 3:** Trend Analysis
    - [ ] Add sample utterances
    - [ ] Configure SOQL aggregate queries
  
  - [ ] **Topic 4:** Contract Summarization
    - [ ] Add sample utterances
    - [ ] Configure summary action
  
  - [ ] **Topic 5:** Standard Language Guidance
    - [ ] Add sample utterances
    - [ ] Link to Knowledge Articles

- [ ] ⚪ Configure agent channels:
  - [ ] Enable in Salesforce (embedded)
  - [ ] Add to Account page layout
  - [ ] Add to Opportunity page layout

### Day 12-13: Testing & Refinement
- [ ] ⚪ Test Scenario 1: Contract Term Inquiry
  - [ ] Navigate to TechCorp Opportunity
  - [ ] Ask: "What are the payment terms for TechCorp?"
  - [ ] Verify agent returns "Net 60" with document reference
  - [ ] Ask: "Is this standard?"
  - [ ] Verify agent flags as non-standard

- [ ] ⚪ Test Scenario 2: Document Verification
  - [ ] Navigate to TechCorp Opportunity
  - [ ] Ask: "Verify MSA and Order Form are consistent"
  - [ ] Verify agent flags rollover discrepancy (15% vs 10%)

- [ ] ⚪ Test Scenario 3: Trend Analysis
  - [ ] Ask: "What percentage of customers have net 30 payment terms?"
  - [ ] Verify agent returns 60% (3 of 5)
  - [ ] Ask: "Show me rollover term trends"
  - [ ] Verify agent returns average 13.6%, 40% compliant

- [ ] ⚪ Test Scenario 4: Contract Summarization
  - [ ] Navigate to CloudVision Opportunity
  - [ ] Ask: "Summarize this contract and flag risks"
  - [ ] Verify agent identifies: 99.999% uptime, 20% rollover, usage-based billing
  - [ ] Verify risk level: CRITICAL

- [ ] ⚪ Test Scenario 5: Standard Language
  - [ ] Ask: "What's our standard overage language?"
  - [ ] Verify agent provides template and explanation

- [ ] ⚪ Refine based on test results:
  - [ ] Adjust agent instructions if responses off-target
  - [ ] Add more sample utterances for better intent matching
  - [ ] Fine-tune RAG retrieval if document search inaccurate

### Day 14: Dashboard & Reporting
- [ ] ⚪ Create Demo Dashboard with KPIs:
  - [ ] Net 30 Adoption: 60% (Gauge chart)
  - [ ] Rollover Compliance: 40% (Gauge chart)
  - [ ] Average Contract Compliance Score: 65 → 85 (trend)
  - [ ] Contract Risk Distribution (Donut: 2 Low, 1 Medium, 1 High, 1 Critical)
  - [ ] Review Time Savings: 2 hours → 15 min (Bar chart)

- [ ] ⚪ Create simple report:
  - [ ] "Contracts by Payment Terms"
  - [ ] "Rollover Terms Analysis"
  - [ ] "High-Risk Contracts"

### Day 15-16: Demo Prep & Dry Run
- [ ] ⚪ Create demo presentation outline:
  - [ ] Slide 1: Problem statement (Deal desk challenges)
  - [ ] Slide 2: Agent capabilities overview
  - [ ] Slide 3: Live demo (5 scenarios)
  - [ ] Slide 4: ROI ($78K annual savings)
  - [ ] Slide 5: Next steps (Pilot program)

- [ ] ⚪ Prepare browser tabs:
  - [ ] Tab 1: Agent Builder (show configuration)
  - [ ] Tab 2: TechCorp Account (Scenario 1 & 2)
  - [ ] Tab 3: CloudVision Opportunity (Scenario 4)
  - [ ] Tab 4: Dashboard with KPIs (Scenario 3)
  - [ ] Tab 5: Knowledge Articles (Scenario 5)

- [ ] ⚪ Record backup video:
  - [ ] Screen recording of all 5 scenarios
  - [ ] Narrate each scenario
  - [ ] Save as fallback if live demo fails

- [ ] ⚪ **DRY RUN** with Jared McPherson or colleague:
  - [ ] Run through all 5 scenarios
  - [ ] Time each scenario (should be 2-3 min each)
  - [ ] Get feedback on pacing and clarity
  - [ ] Adjust based on feedback

- [ ] ⚪ Prepare Q&A responses:
  - [ ] "How long to implement?" → 4-6 weeks full, 2 weeks pilot
  - [ ] "Do we have Data Cloud 360?" → Check with Katie/Jared
  - [ ] "What about other use cases?" → Can expand to legal, procurement
  - [ ] "Integration with DealHub?" → Yes, syncs to Salesforce
  - [ ] "What if agent is wrong?" → Human always reviews, agent assists

---

## 🎯 **DEMO DAY: November 19, 2025**

### Pre-Demo (1 Hour Before)
- [ ] ⚪ Log into demo org and verify all working
- [ ] ⚪ Test agent responses on all 5 scenarios (quick check)
- [ ] ⚪ Open all browser tabs in correct order
- [ ] ⚪ Clear browser history/cache
- [ ] ⚪ Silence notifications (phone, computer)
- [ ] ⚪ Test screen sharing
- [ ] ⚪ Have backup video ready
- [ ] ⚪ Have water nearby 💧
- [ ] ⚪ Review key talking points:
  - $78K annual savings
  - 2 hours → 15 minutes per contract
  - 85% compliance target
  - Data Cloud 360 + RAG = game changer

### Demo Flow (20 Minutes)
- [ ] ⚪ **Intro (2 min):** Problem statement, Katie's pain points
- [ ] ⚪ **Scenario 1 (3 min):** Contract Term Inquiry (TechCorp payment terms)
- [ ] ⚪ **Scenario 2 (3 min):** Document Verification (TechCorp inconsistency)
- [ ] ⚪ **Scenario 3 (3 min):** Trend Analysis (Net 30 adoption, rollover compliance)
- [ ] ⚪ **Scenario 4 (3 min):** Contract Summarization (CloudVision risks)
- [ ] ⚪ **Scenario 5 (2 min):** Standard Language (Overage template)
- [ ] ⚪ **ROI (2 min):** Dashboard showing KPIs and savings
- [ ] ⚪ **Next Steps (2 min):** Pilot program discussion

### Post-Demo
- [ ] ⚪ Q&A session
- [ ] ⚪ Gather feedback from Katie, Jonathan, Mary
- [ ] ⚪ Discuss pilot timeline and requirements
- [ ] ⚪ Schedule follow-up meeting
- [ ] ⚪ Send meeting recap email with:
  - [ ] Demo recording (if recorded)
  - [ ] ROI calculation summary
  - [ ] Pilot program proposal
  - [ ] Next steps and timeline

---

## 📊 **SUCCESS CRITERIA**

Your demo is successful if:
- ✅ Katie sees agent answer contract questions instantly from PDFs
- ✅ Team understands document verification catches errors
- ✅ Excitement about trend analysis for strategic decisions
- ✅ Recognition of massive time savings (87.5% reduction)
- ✅ Confidence that Data Cloud 360 investment is worth it
- ✅ Agreement to move forward with pilot program

---

## 🆘 **TROUBLESHOOTING**

### If Data Cloud 360 setup is too complex:
**Plan B:** Use Knowledge Articles to simulate contract content
- Create 5-10 articles with contract clause excerpts
- Agent searches Knowledge Base instead of PDFs
- Less impressive but proves concept

### If agent responses are inaccurate:
**Quick Fix:**
1. Review agent instructions for clarity
2. Add more specific sample utterances to topics
3. Simplify queries in demo script
4. Have "cheat sheet" of exact queries that work

### If live demo fails:
**Backup Plan:**
- Switch to pre-recorded video
- Walk through slides with screenshots
- Focus on business value and ROI
- Schedule technical deep-dive for later

---

## 📞 **KEY CONTACTS**

- **Katie Nichols** (knichols@starburstdata.com) - Decision maker
- **Jonathan & Mary** - End users (get their emails!)
- **Jared McPherson** (jmcpherson@salesforce.com) - Your AE
- **Salesforce SE Team** - For Data Cloud 360 help

---

## 💡 **PRO TIPS**

1. **Start Simple:** Get 1-2 scenarios working perfectly before adding more
2. **Test Frequently:** Don't wait until Day 14 to test everything
3. **Use Real Language:** Sample queries should sound like Katie's team
4. **Show, Don't Tell:** Live demo > slides every time
5. **Practice Transitions:** Smooth navigation between scenarios
6. **Know Your Fallback:** Always have Plan B ready
7. **Listen to Katie:** If she asks about something, pivot to show it
8. **Follow Up Fast:** Send recap within 24 hours

---

## 🎉 **YOU'VE GOT THIS!**

This is an advanced use case, but you have:
- ✅ Detailed meeting notes with clear requirements
- ✅ Complete setup guide with step-by-step instructions
- ✅ Agent spec with everything pre-defined
- ✅ Sample contracts ready to create
- ✅ 2 full weeks to build and test
- ✅ Clear success criteria
- ✅ Backup plans for every scenario

**Remember:**
- This agent will save Starburst $78K/year
- It solves real pain for Katie's team
- You're demonstrating cutting-edge AI + data integration
- Even if not perfect, showing the vision is powerful

**Now go build an amazing demo!** 🚀

---

**Questions? Review these files:**
1. `starburst-demo-setup.md` - Full implementation guide
2. `specs/starburstDealDeskAgentSpec.yaml` - Complete agent spec
3. `templates/starburst-contract-samples.md` - Contract templates
4. Original meeting notes - Katie's exact requirements

**Good luck, Sam! You're going to crush this demo! 💪**

