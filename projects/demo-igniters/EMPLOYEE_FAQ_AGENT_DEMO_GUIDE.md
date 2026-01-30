# 🤖 Employee FAQ Agent - Complete Demo Guide for SEs

## 📋 Overview

This guide provides a complete plan for Solutions Engineers to effectively demonstrate a custom Agentforce Agent designed to answer frequently asked questions for internal employees.

**Demo Duration**: 15-20 minutes  
**Audience**: IT Leaders, HR Directors, Operations Managers  
**Value Proposition**: Reduce support ticket volume by 40-60% while improving employee experience

---

## 🎯 Demo Objectives

By the end of your demo, prospects should understand:
1. ✅ How Agentforce can deflect common employee inquiries
2. ✅ The ease of training agents with company-specific knowledge
3. ✅ Integration with existing Salesforce data and processes
4. ✅ Analytics and continuous improvement capabilities
5. ✅ Security and access control features

---

## 📅 Pre-Demo Checklist (1 Week Before)

### ✅ Environment Setup

- [ ] **Provision demo org** with Agentforce licenses
  ```bash
  sf org login web --alias agentforce-demo
  sf org open --target-org agentforce-demo
  ```

- [ ] **Deploy agent components**
  ```bash
  npm run demo:setup
  ```

- [ ] **Create knowledge articles** (15-20 articles covering common FAQs)
  - HR policies (PTO, benefits, onboarding)
  - IT support (password resets, VPN access)
  - Facilities (parking, office locations)
  - Expense management

- [ ] **Configure agent topics** based on `specs/employeeFaqAgentSpec.yaml`

- [ ] **Set up test users** with different access levels

### ✅ Data Preparation

- [ ] **Create sample cases** showing typical employee questions
- [ ] **Build knowledge base** with searchable articles
- [ ] **Configure escalation rules** to appropriate departments
- [ ] **Set up analytics dashboard** to track agent performance

### ✅ Demo Script & Story

- [ ] Develop 3-5 demo scenarios (see below)
- [ ] Prepare customer-specific examples if possible
- [ ] Test all demo flows end-to-end
- [ ] Have backup scenarios ready

---

## 🎬 Demo Flow (20 Minutes)

### **Act 1: The Problem (2 min)**

**Storytelling approach:**
> "Imagine you're an employee at a large company. It's Monday morning, and you need to:
> - Submit an expense report from last week's trip
> - Request time off for next month
> - Reset your VPN password
> 
> Traditionally, you'd:
> - Email HR (response in 24-48 hours)
> - Submit an IT ticket (wait in queue)
> - Search the intranet (outdated information)
> - Ask your manager (who doesn't know everything)
> 
> Result: Frustration, lost productivity, overwhelmed support teams."

**Key Statistics to Share:**
- Average company receives 50-100 support tickets per 100 employees monthly
- 60-70% are repetitive, easily answerable questions
- Average response time: 24-48 hours
- Cost per ticket: $15-25

---

### **Act 2: The Solution - Agent Overview (3 min)**

**Show the Agent Setup**

1. **Navigate to Agent Builder**
   ```
   Setup → Agentforce → Agents → Employee FAQ Assistant
   ```

2. **Highlight key features:**
   - **Natural Language Understanding** - Understands questions in everyday language
   - **Topic-Based Organization** - Clear routing to specialized knowledge
   - **Multi-Source Knowledge** - Pulls from Knowledge, Cases, Custom Objects
   - **Continuous Learning** - Improves based on employee interactions

3. **Show the Topics Structure**
   ```
   📚 Employee FAQ Agent
   ├── 💼 HR & Benefits
   │   ├── Time Off Requests
   │   ├── Benefits Enrollment
   │   └── Onboarding
   ├── 💻 IT Support
   │   ├── Password & Access
   │   ├── Software Requests
   │   └── Equipment Setup
   ├── 💰 Expense Management
   │   └── Reimbursement Process
   └── 🏢 Facilities
       └── Office Information
   ```

---

### **Act 3: Live Demo - Employee Scenarios (10 min)**

#### **Scenario 1: HR Question - PTO Request** (2-3 min)

**Employee asks:**
> "How do I request time off for my vacation next month?"

**Agent Response Should Include:**
- Step-by-step instructions
- Link to PTO request form
- Manager approval process
- Blackout dates (if applicable)
- Remaining PTO balance (if integrated)

**👉 Demo Tips:**
- Show how quickly agent responds (< 2 seconds)
- Highlight natural language understanding
- Point out helpful links and resources
- Show escalation option if needed

**Value Statement:**
> "Notice how the agent provided immediate, accurate information with actionable next steps. No waiting for HR, no searching through policy documents."

---

#### **Scenario 2: IT Support - Password Reset** (2-3 min)

**Employee asks:**
> "I can't log into VPN from home. How do I reset my password?"

**Agent Response Should Include:**
- Self-service password reset link
- Step-by-step troubleshooting
- VPN client download link
- IT support escalation if unresolved
- Related articles (2FA setup, etc.)

**Show Agent Actions:**
1. Agent recognizes IT topic
2. Provides immediate self-service solution
3. Offers related help articles
4. Creates ticket automatically if needed

**Value Statement:**
> "70% of password issues are resolved through self-service, reducing IT ticket volume dramatically."

---

#### **Scenario 3: Expense Management** (2-3 min)

**Employee asks:**
> "I need to submit an expense report from my business trip. What's the process?"

**Agent Response Should Include:**
- Link to expense submission form
- Required documentation list
- Receipt upload instructions
- Approval workflow timeline
- Reimbursement processing time

**Advanced Feature to Highlight:**
- **Intelligent Form Pre-fill** - Agent can pre-populate expense form
- **Real-time Status Updates** - Track approval progress
- **Policy Validation** - Check if expense complies with policy

**Value Statement:**
> "The agent not only answers the question but guides employees through the entire process, reducing errors and back-and-forth."

---

#### **Scenario 4: Complex Query - Escalation** (2-3 min)

**Employee asks:**
> "I'm relocating to a different state. How does that affect my benefits and tax withholding?"

**Agent Response Should:**
1. Acknowledge complexity
2. Provide general guidance
3. **Escalate to HR specialist**
4. Create case automatically
5. Set proper priority
6. Notify employee of next steps

**Show Escalation Workflow:**
```
Employee Question 
    ↓
Agent Attempts Answer
    ↓
Recognizes Need for Human Expert
    ↓
Creates Case with Context
    ↓
Routes to HR Benefits Team
    ↓
Notifies Employee (Timeline: 1 business day)
```

**Value Statement:**
> "The agent knows its limits. Complex or sensitive issues are automatically escalated with full context, ensuring employees get expert help when needed."

---

### **Act 4: Analytics & Continuous Improvement (3 min)**

**Show the Admin Dashboard**

Navigate to: **Agentforce Analytics → Employee FAQ Agent**

**Key Metrics to Highlight:**

1. **Deflection Rate**: 65% (tickets avoided)
2. **Response Time**: < 2 seconds average
3. **Resolution Rate**: 78% (no escalation needed)
4. **Employee Satisfaction**: 4.6/5 stars
5. **Top Topics**: Show bar chart of most common questions

**Continuous Improvement Features:**

- **Unanswered Questions Report** - Identify knowledge gaps
- **Low Confidence Responses** - Review and improve
- **Trending Topics** - Proactive knowledge creation
- **Feedback Loop** - Employee ratings improve agent

**Demo Action:**
```sql
-- Show SOQL query for agent analytics
SELECT Subject, Status, Resolution__c, Agent_Confidence__c, 
       Employee_Rating__c, Created_Date
FROM Agent_Interaction__c 
WHERE Agent_Name__c = 'Employee FAQ Agent'
AND CreatedDate = LAST_N_DAYS:30
ORDER BY CreatedDate DESC
```

---

### **Act 5: Administration & Security (2 min)**

**Show Key Admin Features:**

1. **Access Control**
   - Topic-level permissions
   - Role-based access
   - Data security settings

2. **Knowledge Management**
   - Easy article creation
   - Version control
   - Approval workflow

3. **Agent Training**
   - No-code configuration
   - Quick topic updates
   - Test before deployment

**Security Talking Points:**
- ✅ Respects Salesforce security model
- ✅ Field-level security honored
- ✅ Audit trail for all interactions
- ✅ PII protection built-in
- ✅ Compliance-ready (GDPR, HIPAA)

---

## 🎯 Demo Scenarios by Use Case

### **For HR Leaders**

**Focus Areas:**
- Onboarding new employees
- Benefits enrollment
- Policy questions
- Performance review processes

**ROI Message:**
> "Reduce HR ticket volume by 50% while improving employee satisfaction scores."

### **For IT Directors**

**Focus Areas:**
- Password/access management
- Software requests
- Troubleshooting guides
- Equipment provisioning

**ROI Message:**
> "Cut Level 1 support tickets in half, allowing IT team to focus on strategic initiatives."

### **For Operations/Facilities**

**Focus Areas:**
- Office information
- Building access
- Conference room booking
- Supply requests

**ROI Message:**
> "Provide 24/7 facility support without increasing headcount."

---

## 💡 Best Practices for Demo Success

### **Before the Demo**

1. ✅ **Know your audience** - Customize scenarios to their pain points
2. ✅ **Test everything** - Run through entire demo twice
3. ✅ **Prepare backup plan** - Have offline slides ready
4. ✅ **Load sample data** - Ensure realistic, relevant examples
5. ✅ **Check performance** - Agent should respond in < 2 seconds

### **During the Demo**

1. ✅ **Tell stories** - Use real employee personas
2. ✅ **Show, don't tell** - Live interactions beat PowerPoint
3. ✅ **Highlight value** - Call out time/cost savings explicitly
4. ✅ **Invite interaction** - Let them ask questions to the agent
5. ✅ **Address concerns** - Proactively discuss data security

### **After the Demo**

1. ✅ **Provide follow-up materials** - Leave-behind doc with ROI
2. ✅ **Share recording** - If permitted, record the demo
3. ✅ **Offer POC** - Propose pilot program
4. ✅ **Schedule next steps** - Book technical deep-dive

---

## 📊 ROI Calculator for Prospects

### **Sample Calculation**

**Company Profile:**
- 1,000 employees
- Current: 500 support tickets/month
- Average handling time: 30 minutes
- Cost per ticket: $20

**With Agentforce Employee FAQ Agent:**
- Deflection rate: 60% (300 tickets avoided)
- Savings: 300 tickets × $20 = **$6,000/month**
- Annual savings: **$72,000**
- Implementation cost: ~$25,000
- **ROI: 188% in first year**

**Additional Benefits:**
- ⚡ Instant responses (vs. 24-48 hour wait)
- 😊 Improved employee satisfaction
- 🚀 Reduced support team burnout
- 📈 Scalable without hiring

---

## 🔧 Technical Setup Commands

### **Deploy Agent Components**

```bash
# Set your demo org
export SF_TARGET_ORG=agentforce-demo

# Deploy agent framework
npm run demo:deploy

# Seed sample knowledge articles
node scripts/seed-agent-knowledge.js

# Assign agent permissions
npm run demo:permissions

# Open org to configure agent
sf org open --target-org ${SF_TARGET_ORG} --path /lightning/setup/AgentStudio/home
```

### **Create Sample Interactions**

```bash
# Generate sample agent conversation data
node scripts/generate-agent-conversations.js

# Import sample cases
sf data import bulk --file data/agent-sample-cases.csv --sobject Case --wait 10
```

---

## 🎤 Speaking Points & Objection Handling

### **Common Questions & Responses**

**Q: "How accurate is the agent?"**
> "Out of the box, agents achieve 80-85% accuracy. With your specific knowledge base, we typically see 90%+ accuracy within 30 days. The agent continuously learns from interactions."

**Q: "What happens when the agent doesn't know the answer?"**
> "Great question! The agent is designed with smart escalation. It recognizes when it needs human help and automatically creates a case with full context. Your employees never get stuck."

**Q: "Will this replace our support team?"**
> "Not at all. This augments your team by handling repetitive questions, allowing your specialists to focus on complex, high-value issues. Most customers redeploy support staff to strategic projects."

**Q: "How long does implementation take?"**
> "For a basic employee FAQ agent, 4-6 weeks including knowledge base setup and training. Pilot programs can start in as little as 2 weeks."

**Q: "What about data security?"**
> "Agentforce respects all Salesforce security settings - sharing rules, field-level security, and object permissions. It's built on the Salesforce Platform, inheriting its security model and compliance certifications."

**Q: "Can it integrate with our existing systems?"**
> "Yes! Agentforce can integrate with knowledge bases, HR systems, IT service management tools, and more through standard Salesforce integration methods - APIs, MuleSoft, etc."

---

## 📝 Follow-Up Materials Checklist

After demo, send prospect:

- [ ] **ROI Calculator** (customized to their company size)
- [ ] **Architecture Diagram** showing integration points
- [ ] **Sample Knowledge Article Templates**
- [ ] **Implementation Timeline** (with milestones)
- [ ] **Success Story/Case Study** from similar company
- [ ] **Security & Compliance Whitepaper**
- [ ] **Proof of Concept Proposal**

---

## 🚀 Next Steps After Successful Demo

### **Immediate (Week 1)**
1. Schedule follow-up technical deep-dive
2. Gather their current FAQ list
3. Identify pilot department (recommend HR or IT)
4. Assign Salesforce Solution Engineer

### **Short-Term (Weeks 2-4)**
1. Build custom proof-of-concept
2. Load their knowledge articles
3. Train with their data
4. Conduct user acceptance testing

### **Medium-Term (Weeks 5-8)**
1. Expand to additional departments
2. Integrate with existing systems
3. Train support team on analytics
4. Launch to broader employee base

---

## 🎯 Success Metrics to Track

**Share these KPIs with prospects:**

| Metric | Target | Measurement |
|--------|--------|-------------|
| Deflection Rate | 50-70% | Tickets avoided vs. created |
| Avg Response Time | < 3 seconds | Time to first response |
| Resolution Rate | 75%+ | Resolved without escalation |
| Employee Satisfaction | 4.5/5 | Post-interaction rating |
| Cost per Interaction | < $0.50 | vs. $15-25 per ticket |
| Knowledge Coverage | 90%+ | % of questions answered |

---

## 🎬 Demo Script Summary

### **Opening (30 seconds)**
"Today I'll show you how companies are using Agentforce to transform employee support - reducing ticket volume by 60% while dramatically improving employee experience."

### **Problem Statement (1 min)**
"Let's look at the typical employee experience when they need help..."

### **Solution Overview (2 min)**
"Agentforce provides an AI agent that understands natural language and provides instant, accurate answers..."

### **Live Demo (10 min)**
"Let me show you four common scenarios: HR question, IT support, expense management, and a complex case requiring escalation..."

### **Analytics (2 min)**
"Here's how you measure success and continuously improve..."

### **Security & Admin (2 min)**
"And it's all enterprise-grade secure and easy to administer..."

### **Closing (2 min)**
"Based on your company size, you could save $X annually while improving employee satisfaction. What questions do you have?"

---

## 🏁 Final Checklist

**Day Before Demo:**
- [ ] Test internet connection
- [ ] Clear browser cache
- [ ] Verify org is accessible
- [ ] Load demo script on second screen
- [ ] Have backup plan ready
- [ ] Confirm meeting time/timezone
- [ ] Send calendar invite with agenda

**1 Hour Before Demo:**
- [ ] Log into demo org
- [ ] Open all necessary tabs
- [ ] Test agent responses
- [ ] Close unnecessary applications
- [ ] Silence phone/notifications
- [ ] Have water nearby

**During Demo:**
- [ ] Record session (with permission)
- [ ] Take notes on questions
- [ ] Observe prospect engagement
- [ ] Capture specific requirements

**After Demo:**
- [ ] Send thank-you email within 2 hours
- [ ] Share promised follow-up materials
- [ ] Schedule next meeting
- [ ] Log activity in CRM
- [ ] Debrief with team

---

## 🎉 You're Ready!

With this guide, you have everything you need to deliver an compelling Agentforce Employee FAQ Agent demo. Remember:

- ✅ **Focus on business value**, not just features
- ✅ **Tell stories** that resonate with your audience
- ✅ **Show real scenarios** they'll recognize
- ✅ **Demonstrate quick wins** and long-term value
- ✅ **Listen more than you talk** - understand their needs

**Good luck with your demo!** 🚀

---

*Questions or need help? Check the main [README.md](README.md) or [AGENT_FRAMEWORK_DEVELOPMENT_GUIDE.md](AGENT_FRAMEWORK_DEVELOPMENT_GUIDE.md)*







