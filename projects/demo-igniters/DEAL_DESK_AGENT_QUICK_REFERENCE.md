# Deal Desk Agent - Quick Reference Card

> **Print this 1-page guide for your desk!**

---

## 🎯 5 Core Capabilities

| # | Capability | Example Query | Response Time |
|---|-----------|---------------|---------------|
| 1️⃣ | **Standards Inquiry** | "What are our standard payment terms?" | < 5 sec |
| 2️⃣ | **Contract Analysis** | "Analyze this contract for risks" | < 15 sec |
| 3️⃣ | **Trend Analysis** | "What % have Net 30 terms?" | < 20 sec |
| 4️⃣ | **Document Verification** | "Check MSA vs Order Form" | < 10 sec |
| 5️⃣ | **Standard Language** | "Give me termination clause" | < 5 sec |

---

## 📊 Risk Levels

| Level | Score | Indicators | Action |
|-------|-------|-----------|--------|
| 🟢 **LOW** | 0-2 | All terms within standards | Standard approval |
| 🟡 **MEDIUM** | 3-6 | Minor deviations | Manager review |
| 🟠 **HIGH** | 7-9 | Multiple issues or one critical | VP approval + negotiation |
| 🔴 **CRITICAL** | 10+ | Dangerous terms (99.999% SLA, unlimited liability) | Legal review, do not sign |

---

## ⚠️ Contract Terms to Watch

| Term | Standard | Acceptable | Non-Compliant | Risk |
|------|----------|------------|---------------|------|
| **Payment Terms** | Net 30 | Net 30-45 | Net 60+ | 🔴 High |
| **Uptime SLA** | ≤99.9% | 99.5-99.9% | >99.9% | 🔴 Critical |
| **Rollover %** | ≤10% | 5-10% | >15% | 🟠 High |
| **Liability Cap** | 6-12 months fees | 6-12 months | Unlimited | 🔴 Critical |
| **Termination Notice** | 60-90 days | 60-90 days | >90 days or none | 🟡 Medium |

---

## 🚀 Quick Commands

### To Analyze a Contract:
```
1. Upload PDF to Opportunity Files
2. Type: "Analyze the [Company Name] contract"
3. Wait 15 seconds
4. Review risk assessment and recommendations
```

### To Check Trends:
```
Type: "What percentage of contracts have [term]?"
Examples:
  - "What % have Net 30 payment terms?"
  - "Show me rollover compliance"
  - "How many have >99.9% uptime SLAs?"
```

### To Verify Documents:
```
Type: "Check if [Doc 1] and [Doc 2] are consistent"
Example:
  - "Compare TechCorp MSA and Order Form"
  - "Verify payment terms match across all docs"
```

### To Get Standard Language:
```
Type: "Show me standard language for [clause]"
Examples:
  - "Give me payment terms clause"
  - "What's our termination language?"
  - "Show me liability cap wording"
```

---

## 🎬 3-Minute Demo Script

**SETUP:** Opportunity with TechCorp_MSA.pdf attached (Net 60, 99.95% SLA, 15% rollover)

**ACT 1: The Problem** (30 sec)
> "Our team reviews 50 contracts/month, spending 2 hours each searching PDFs for terms like payment terms, SLAs, and rollover percentages. That's 100 hours per month of manual work."

**ACT 2: The Solution** (30 sec)
> "This AI agent uses Data Cloud to read contract PDFs and answer questions instantly. Watch."

**ACT 3: Live Demo** (90 sec)
1. **Ask:** "What are the payment terms for TechCorp?" → Agent: "Net 60 [quotes clause]"
2. **Analyze:** "Analyze this contract" → Agent: "HIGH RISK: Net 60, 99.95% SLA, 15% rollover"
3. **Trend:** "What % have Net 30?" → Agent: "60% of 47 contracts"

**ACT 4: The Value** (30 sec)
> "Result: 2 hours → 15 minutes per contract. $78K annual savings. 20% better compliance. Questions?"

---

## 🐛 Quick Troubleshooting

| Problem | Quick Fix |
|---------|-----------|
| ❌ Can't find terms in PDF | Wait 15 min for sync, check PDF is searchable |
| ❌ Slow (>30 sec) | Reduce Top K to 3, optimize SOQL |
| ❌ Wrong risk level | Update agent instructions with risk criteria |
| ❌ Can't access files | Check ContentDocument read permission |
| ❌ Wrong percentages | Verify Opportunity fields populated |

---

## 📐 Success Metrics

| Metric | Target | Formula |
|--------|--------|---------|
| **Accuracy** | 95%+ | Correct answers / Total queries |
| **Speed** | < 20 sec | Average response time |
| **Adoption** | 80%+ | Active users / Total users |
| **Satisfaction** | 75%+ | Thumbs up / Total ratings |
| **Time Saved** | 10+ hrs/week | (2 hrs - 0.25 hrs) × contracts/week |

---

## 📞 Emergency Contacts

| Issue Type | Contact |
|-----------|---------|
| Agent not responding | Salesforce Admin |
| Data Cloud sync error | Data Cloud support |
| Wrong answers | Review agent instructions |
| Performance issues | Optimize RAG config |
| User training | See 1-hour training guide |

---

## 🎓 Best Practices

### ✅ DO
- Always cite document sources
- Upload contracts immediately after receiving
- Review AI recommendations before signing
- Provide thumbs up/down feedback
- Report inaccuracies to admin

### ❌ DON'T
- Don't trust 100% without verification
- Don't skip manual review for critical terms
- Don't ignore HIGH/CRITICAL risk flags
- Don't upload non-searchable scanned PDFs
- Don't share confidential contracts outside Salesforce

---

## 🗂️ Documentation

| Document | Purpose | Length |
|----------|---------|--------|
| **README** | Overview & navigation | 15 min read |
| **Checklist** | Day-by-day action plan | 5 min read |
| **Deployment Plan** | Complete technical guide | 2-3 hour read |
| **This Card** | Quick reference | 3 min read |

**All docs:** `/demo-igniters/DEAL_DESK_AGENT_*`

---

## 💡 Pro Tips

1. **Be Specific:** "What are payment terms in TechCorp MSA?" > "payment terms?"
2. **Verify Critical Terms:** Always manually check HIGH/CRITICAL risks
3. **Use for Speed:** Let agent find clause, you review context
4. **Train It:** Thumbs down helps improve accuracy
5. **Update Knowledge:** Add new standards as company policy evolves

---

## 🔄 Weekly Workflow

**Monday:** Analyze new contracts from last week, identify trends  
**Tuesday-Thursday:** Use agent for daily contract questions  
**Friday:** Review accuracy metrics, report issues, update standards  

---

## 🎯 ROI Calculator

```
CURRENT STATE:
  Contracts/month: _____ × 2 hours = _____ hours
  Hours × $75/hour = $______/month

FUTURE STATE:
  Contracts/month: _____ × 0.25 hours = _____ hours  
  Hours × $75/hour = $______/month

MONTHLY SAVINGS: $_________
ANNUAL SAVINGS:  $_________ (×12)
```

Example: 50 contracts → $90K/year → $11K/year = **$79K saved**

---

## 📅 3-Week Deployment Timeline

| Week | Focus | Deliverable |
|------|-------|-------------|
| **1** | Foundation | Apex deployed, Data Cloud configured, test data uploaded |
| **2** | Agent Build | 5 topics created, RAG connected, end-to-end tested |
| **3** | Deploy & Train | Production live, users trained, monitoring active |

---

## 🎉 You're Ready!

**Access Agent:** Salesforce → Opportunities → Click chat icon  
**First Query:** "What are our standard payment terms?"  
**Get Help:** See full docs in `/demo-igniters/DEAL_DESK_AGENT_*.md`

---

**Questions?** Contact your Salesforce admin or see [DEAL_DESK_AGENT_README.md](./DEAL_DESK_AGENT_README.md)

---

*Print this card and keep it at your desk for quick reference!*

**Last Updated:** November 24, 2025 | **Version:** 1.0

