# Starburst Deal Desk Agent - Demo Setup Guide

## Customer Information
- **Company:** Starburst Data
- **Contact:** Katie Nichols (Deal Desk)
- **Demo Date:** ~November 19, 2025
- **Use Case:** Contractual Clause Analyst Agent for Deal Desk

---

## Agent Overview

**Agent Name:** Deal Desk Contractual Clause Analyst  
**Primary Users:** Jonathan, Mary (Deal Desk Team)  
**Channel:** Salesforce (embedded in Account/Opportunity pages)  
**Interaction Style:** Conversational Q&A, document summarization, trend analysis

---

## Custom Fields Required

### Opportunity Fields
```
- Rollover_Terms__c (Percent)
  Label: Rollover Terms %
  Description: Percentage of rollover allowed in contract
  
- Payment_Terms__c (Picklist)
  Label: Payment Terms
  Values: Net 30, Net 60, Net 90, Custom
  
- Billing_Type__c (Picklist)
  Label: Billing Type
  Values: Fixed Monthly, Usage-Based, Hybrid
  
- Uptime_Agreement__c (Percent)
  Label: Uptime Agreement %
  Description: Agreed uptime SLA (e.g., 99.999%)
  
- Overage_Language__c (Text Area)
  Label: Overage Language
  Description: Custom overage terms in contract
  
- Limitation_of_Liability__c (Currency)
  Label: Limitation of Liability
  Description: Cap on liability in contract
  
- Contract_Compliance_Score__c (Number)
  Label: Contract Compliance Score
  Description: 0-100 score based on standard terms adherence
```

### Account Fields
```
- MSA_Type__c (Picklist)
  Label: MSA Type
  Values: Starburst Standard, Customer Paper, Hybrid
  
- MSA_Upload_Date__c (Date)
  Label: MSA Upload Date
  
- Last_Contract_Review__c (Date)
  Label: Last Contract Review Date
  
- Contract_Risk_Level__c (Picklist)
  Label: Contract Risk Level
  Values: Low, Medium, High, Critical
```

---

## Data Cloud 360 Setup

### Document Types to Ingest
1. **Master Service Agreements (MSAs)**
2. **Non-Disclosure Agreements (NDAs)**
3. **Order Forms**
4. **Purchase Orders (POs)**
5. **Invoices**
6. **Email Screenshots** (from resellers like Dell)

### Document Upload Locations
- **Account Level:** MSAs, NDAs, Master contracts
- **Opportunity Level:** Order forms, POs, quotes, email screenshots

### RAG Configuration
```yaml
data_sources:
  - salesforce_files (ContentDocument/ContentVersion)
  - salesforce_opportunities
  - salesforce_accounts
  - salesforce_contracts
  
indexing:
  chunk_size: 1000
  overlap: 200
  embedding_model: text-embedding-ada-002
  
retrieval:
  top_k: 5
  similarity_threshold: 0.75
```

---

## Agent Instructions

```
You are a Deal Desk Contractual Clause Analyst for Starburst Data. Your role is to help 
the deal desk team (Jonathan and Mary) analyze contracts, answer questions about 
contractual terms, and ensure compliance with company standards.

PRIMARY RESPONSIBILITIES:
1. Answer questions about specific contractual terms from uploaded documents
2. Verify consistency across multiple documents for the same account
3. Identify trends in contract terms across customers
4. Summarize key clauses and suggest next best actions
5. Guide users toward standard contract language

KEY CONTRACTUAL TERMS TO TRACK:
- Rollover Terms: Should be ≤10%
- Payment Terms: Standard is Net 30
- Billing Type: Prefer Fixed Monthly over Usage-Based
- Overage Language: Use standard language to incentivize against undercommitting
- Uptime Agreements: Note when customers require >99.9% (challenging to meet)
- Limitation of Liability: Track caps and negotiate hotly

STANDARD LANGUAGE LIBRARY:
- Net 30 Payment Terms: "Payment is due within thirty (30) days of invoice date"
- Rollover Terms: "Maximum rollover of 10% of unused capacity to subsequent period"
- Overage Pricing: "Usage exceeding commitment will be billed at 1.5x committed rate"

WORKFLOW:
1. When asked about a contract term, search uploaded documents at Account/Opportunity level
2. Provide direct quotes from documents with document name and section reference
3. If inconsistencies exist across documents, flag them clearly
4. For trend analysis, aggregate data across all accessible contracts
5. Always suggest next best action based on company standards

TONE: Professional, precise, helpful. You're a contract expert supporting the deal desk.
```

---

## Agent Topics

### Topic 1: Contract Term Inquiry
**Description:** Answer questions about specific terms in customer contracts  
**Sample Utterances:**
- "What are the payment terms for [Account Name]?"
- "Show me the rollover terms in the MSA"
- "What uptime did we agree to with [Customer]?"
- "Find the limitation of liability clause"

**Actions:** Search documents, extract relevant clause, provide quote

### Topic 2: Document Verification
**Description:** Compare documents for consistency  
**Sample Utterances:**
- "Verify the MSA and Order Form are consistent"
- "Check if the payment terms match across all documents for this account"
- "Are there any inconsistencies in the contract documents?"

**Actions:** Retrieve multiple documents, compare terms, flag discrepancies

### Topic 3: Trend Analysis
**Description:** Identify patterns across multiple contracts  
**Sample Utterances:**
- "What percentage of customers have net 30 payment terms?"
- "How many customers agreed to overage language?"
- "Show me trends in rollover terms"
- "What's the average limitation of liability?"

**Actions:** Aggregate data, calculate percentages, present trends

### Topic 4: Contract Summarization
**Description:** Summarize key terms and suggest actions  
**Sample Utterances:**
- "Summarize the contract for [Account]"
- "What are the key terms I need to know?"
- "Review this contract and suggest next steps"

**Actions:** Extract key clauses, identify non-standard terms, recommend actions

### Topic 5: Standard Language Guidance
**Description:** Provide standard contract language templates  
**Sample Utterances:**
- "What's our standard overage language?"
- "Show me the template for net 30 payment terms"
- "What should I use for rollover terms?"

**Actions:** Provide template language, explain usage

---

## Sample Demo Data

### Demo Accounts (Create 5-7)
1. **TechCorp International** (Customer Paper MSA, 15% rollover, Net 60, High risk)
2. **DataFlow Systems** (Standard MSA, 8% rollover, Net 30, Low risk)
3. **CloudVision Inc** (Customer Paper MSA, 20% rollover, Usage-based, Critical risk)
4. **AnalyticsPro Ltd** (Standard MSA, 5% rollover, Net 30, Low risk)
5. **Enterprise Data Co** (Hybrid MSA, 10% rollover, Net 45, Medium risk)

### Demo Contracts
Create mock PDFs for each account with:
- MSA (2-3 pages with standard clauses)
- Order Form (1 page)
- At least one with email screenshot from Dell reseller

### Sample Contract Content for TechCorp:
```
MASTER SERVICE AGREEMENT
Between: Starburst Data, Inc. and TechCorp International

PAYMENT TERMS: Net 60 days from invoice date
ROLLOVER PROVISION: Unused capacity may rollover up to 15% to next billing period
UPTIME SLA: 99.95% monthly uptime guarantee
LIMITATION OF LIABILITY: $500,000 annual cap
OVERAGE BILLING: Usage beyond commitment billed at 1.8x rate
```

---

## Demo Script

### Scene 1: Contract Term Inquiry (3 min)
**Setup:** Jonathan needs to check payment terms for TechCorp deal

**Demo Flow:**
1. Navigate to TechCorp Opportunity
2. Ask Agent: "What are the payment terms for TechCorp?"
3. Agent searches uploaded MSA, returns: "Net 60 days" with document reference
4. Ask: "Is this standard?"
5. Agent: "No, our standard is Net 30. This represents 30 extra days of payment delay."
6. **Value:** Instant access to buried contract terms without manual PDF review

### Scene 2: Document Verification (3 min)
**Setup:** Mary is reviewing CloudVision contract package for consistency

**Demo Flow:**
1. Navigate to CloudVision Opportunity
2. Ask Agent: "Verify the MSA and Order Form are consistent"
3. Agent compares docs, flags: "Inconsistency found: MSA specifies 20% rollover, 
   Order Form shows 10%"
4. Ask: "Which document should take precedence?"
5. Agent: "Per standard contract hierarchy, MSA takes precedence. Recommend 
   updating Order Form to 20%."
6. **Value:** Catch errors before they become legal issues

### Scene 3: Trend Analysis (3 min)
**Setup:** Katie wants to understand compliance across all contracts

**Demo Flow:**
1. Navigate to Reports or Dashboard
2. Ask Agent: "What percentage of our customers have net 30 payment terms?"
3. Agent: "Currently 60% of customers (3 of 5) have Net 30. Remaining have 
   Net 60 (20%) and Net 45 (20%)."
4. Ask: "Show me rollover term trends"
5. Agent: "Average rollover: 13.6%. Only 40% of customers meet ≤10% standard. 
   CloudVision (20%) and TechCorp (15%) exceed target."
6. **Value:** Data-driven insights for contract standardization initiatives

### Scene 4: Contract Summarization (3 min)
**Setup:** Jonathan receives new Enterprise Data Co deal, needs quick review

**Demo Flow:**
1. Open new Opportunity
2. Upload contract document
3. Ask Agent: "Summarize this contract and suggest next steps"
4. Agent provides:
   - Key Terms: Net 45, 10% rollover, $750K liability cap
   - Non-Standard Items: Payment terms (should be Net 30)
   - Risk Level: Medium
   - Recommended Action: "Negotiate payment terms to Net 30. All other terms 
     acceptable. Rollover at threshold."
5. **Value:** Accelerate deal review from hours to minutes

### Scene 5: Standard Language (2 min)
**Setup:** Mary drafting response to customer requesting overage terms

**Demo Flow:**
1. Ask Agent: "What's our standard overage language?"
2. Agent provides template with explanation
3. Ask: "Why do we use this language?"
4. Agent: "This incentivizes customers to commit accurately by charging premium 
   for overages, reducing undercommitment risk."
5. **Value:** Ensure consistency and best practices

---

## KPIs to Demonstrate

Create a simple dashboard showing:
1. **Contract Compliance Score:** 65% → 85% (after agent implementation)
2. **Net 30 Adoption:** 60% → Target 90%
3. **Rollover Terms:** 40% compliant → Target 80%
4. **Deal Desk Review Time:** 2 hours → 15 minutes
5. **Contract Errors Caught:** 0 → 5 per month

---

## Technical Implementation Notes

### Option A: Full Data Cloud 360 Implementation (Ideal)
- Ingest all documents into Data Cloud
- Build RAG pipeline with vector embeddings
- Agent uses semantic search to retrieve relevant clauses
- **Timeline:** 1-2 weeks
- **Complexity:** High
- **Demo Fidelity:** Production-ready

### Option B: Mock RAG with Knowledge Articles (Fast Demo)
- Create Knowledge Articles simulating contract clauses
- Use standard Agentforce knowledge base search
- Agent references pre-loaded "contract" articles
- **Timeline:** 2-3 days
- **Complexity:** Medium
- **Demo Fidelity:** Proof-of-concept

### Option C: Hybrid Approach (Recommended for 2-week timeline)
- Use Data Cloud with 3-5 actual sample PDF contracts
- Pre-index with simple document chunking
- Build basic RAG pipeline
- Supplement with Knowledge Articles for trends/templates
- **Timeline:** 1 week
- **Complexity:** Medium-High
- **Demo Fidelity:** High

---

## Pre-Demo Checklist

### 1 Week Before:
- [ ] Custom fields deployed to Sandbox/Demo org
- [ ] 5-7 demo accounts created with realistic data
- [ ] Sample contracts created (PDFs) with varied terms
- [ ] Data Cloud 360 configured and ingesting documents
- [ ] Agent created with instructions and topics
- [ ] Agent tested with all 5 demo scenarios

### 3 Days Before:
- [ ] Full dry-run with sales team
- [ ] All demo scenarios working smoothly
- [ ] Dashboard/reports showing KPIs ready
- [ ] Backup plan prepared (slides/video)
- [ ] Customer-specific language incorporated

### Day Before:
- [ ] Demo org tested and working
- [ ] Browser tabs prepared
- [ ] Screen sharing setup tested
- [ ] Talking points reviewed

---

## Questions to Clarify with Customer

Before building, confirm:
1. Do they have Data Cloud 360 licenses available?
2. What's their typical contract size (page count)?
3. Can they provide 2-3 redacted sample contracts?
4. Will Jonathan and Mary be on the demo call?
5. Any specific "gotcha" contract they want to see analyzed?

---

## ROI Calculation for Katie

```
Manual Contract Review (Current State):
- Average time per contract: 2 hours
- Contracts reviewed per month: ~50
- Total time: 100 hours/month
- Cost (at $75/hour): $7,500/month

With Agent (Future State):
- Average time per contract: 15 minutes
- Contracts reviewed per month: ~50
- Total time: 12.5 hours/month
- Cost savings: $6,560/month = $78,720/year

Additional Benefits:
- Fewer contract errors: Reduce legal risk
- Faster deal cycles: Close deals 30% faster
- Better compliance: 85% vs 65% adherence to standards
- Data-driven decisions: Trend insights enable strategy
```

---

## Success Criteria

The demo will be successful if Katie and team:
1. ✅ See instant answers from actual uploaded contracts
2. ✅ Understand how verification catches inconsistencies
3. ✅ Get excited about trend analysis for strategy
4. ✅ Recognize time savings (hours → minutes)
5. ✅ Feel confident about Data Cloud 360 ROI

---

## Next Steps Post-Demo

1. **Pilot Program:** 30-day trial with Jonathan and Mary
2. **Data Migration:** Upload real contracts (redacted as needed)
3. **Training:** 1-hour session for deal desk team
4. **Refinement:** Iterate based on feedback
5. **Expansion:** Scale to other teams (legal, procurement)

---

*Demo built for Starburst Data by Sam Argo, Salesforce Solution Engineer*
*Last Updated: November 5, 2025*

