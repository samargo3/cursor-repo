# 📄 Building an Agentforce Agent for MSA Analysis

## Overview

This guide explains how to build an Agentforce Agent that can read Master Service Agreements (MSAs) attached to Opportunities, summarize contract terms, and answer questions about contractual clauses.

**What You'll Build:**
- 🔍 Agent that reads PDF contracts attached to Salesforce records
- 💬 Natural language Q&A about contract terms
- 📊 Contract summarization with risk assessment
- ✅ Document verification across multiple files
- 📈 Trend analysis across your contract portfolio

**Technologies Used:**
- **Agentforce**: Conversational AI agent framework
- **Data Cloud 360**: Document ingestion and indexing
- **RAG (Retrieval-Augmented Generation)**: Semantic search across documents
- **Salesforce Files**: ContentDocument/ContentVersion storage

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│         AGENTFORCE AGENT                        │
│    (Contract Analysis Agent)                    │
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
└────────────┘    │ • Amendments         │
                  │                      │
                  │ [Vector Embeddings]  │
                  │ [Semantic Search]    │
                  └──────────────────────┘
```

---

## Implementation Approaches

### Option 1: Full Production (Data Cloud 360 + RAG)
**Best for:** Production deployments, large document volumes

**Pros:**
- ✅ Reads actual PDF/Word documents
- ✅ Semantic search across all content
- ✅ Scales to thousands of documents
- ✅ Most accurate and flexible

**Cons:**
- ⚠️ Requires Data Cloud 360 license
- ⚠️ More complex setup (1-2 weeks)
- ⚠️ Higher technical complexity

**Timeline:** 1-2 weeks

---

### Option 2: Knowledge Articles Approach
**Best for:** Quick demos, proof-of-concepts

**Pros:**
- ✅ Fast setup (2-3 days)
- ✅ No additional licenses required
- ✅ Simple configuration
- ✅ Easy to test and iterate

**Cons:**
- ⚠️ Must manually convert contracts to articles
- ⚠️ Not truly reading uploaded PDFs
- ⚠️ Less scalable

**Timeline:** 2-3 days

---

### Option 3: Hybrid Approach (Recommended)
**Best for:** Demos with realistic functionality

**Pros:**
- ✅ Data Cloud with limited document set (5-10 contracts)
- ✅ Shows real PDF reading capability
- ✅ Knowledge Articles for templates/guidance
- ✅ Achievable in 1 week

**Timeline:** 1 week

---

## Step-by-Step Implementation

### Phase 1: Environment Setup (Day 1)

#### 1.1 Verify Licenses
```bash
# Check Data Cloud 360 availability
sf data query --query "SELECT Id FROM DataCloudSetup LIMIT 1" --target-org your-demo-org

# Verify Agentforce is enabled
# Navigate to Setup → Agentforce → Agents
```

#### 1.2 Enable Required Features
In Setup, enable:
- ✅ Agentforce
- ✅ Data Cloud 360 (if using Option 1 or 3)
- ✅ Knowledge (if using Option 2 or 3)
- ✅ Files and Content Management

#### 1.3 Create Custom Fields (Optional but Recommended)
To track contract terms in structured fields for reporting:

```apex
// On Opportunity object:
- Payment_Terms__c (Text, 50)
- Rollover_Terms__c (Number, 2 decimal places)
- Uptime_SLA__c (Percent)
- Contract_Risk_Level__c (Picklist: Low, Medium, High, Critical)
- Liability_Cap__c (Currency)
- Contract_Compliance_Score__c (Percent)
```

---

### Phase 2: Sample Data Creation (Day 2-3)

#### 2.1 Create Demo Accounts and Opportunities
```bash
# Use provided scripts or create manually
sf data create record --sobject Account --values "Name='TechCorp International'"
sf data create record --sobject Opportunity --values "Name='TechCorp MSA' AccountId=<account_id> StageName='Negotiation/Review'"
```

#### 2.2 Create Contract PDFs
Use the sample contracts from `templates/starburst-contract-samples.md`:
- **TechCorp** - High Risk (Non-compliant terms)
- **DataFlow** - Low Risk (Fully compliant)
- **CloudVision** - Critical Risk (Dangerous terms)
- **AnalyticsPro** - Low Risk (Exemplary)
- **Enterprise Data** - Medium Risk (Some issues)

Convert to PDF using:
- Google Docs → Export as PDF
- Microsoft Word → Save as PDF
- `pandoc contract.md -o contract.pdf`

#### 2.3 Upload Files to Salesforce
1. Navigate to Opportunity record
2. Go to **Files** tab
3. Click **Upload Files**
4. Upload MSA PDF
5. Repeat for multiple opportunities

**File Naming Convention:**
- `{CustomerName}_MSA_{Date}.pdf`
- `{CustomerName}_OrderForm_{Date}.pdf`
- `{CustomerName}_NDA_{Date}.pdf`

---

### Phase 3: Data Cloud 360 Setup (Day 4-5)

#### 3.1 Create Data Source Connection
```
Setup → Data Cloud → Data Sources → New
1. Select "Salesforce Files"
2. Connect to ContentDocument and ContentVersion objects
3. Enable indexing for PDF files
```

#### 3.2 Configure RAG Pipeline
```yaml
RAG Configuration:
  indexing:
    chunkSize: 1000           # Characters per chunk
    overlap: 200              # Character overlap between chunks
    embeddingModel: text-embedding-ada-002
    
  retrieval:
    topK: 5                   # Return top 5 most relevant chunks
    similarityThreshold: 0.75 # Minimum relevance score
    
  filtering:
    fileTypes: [pdf, docx]
    locations: [Account, Opportunity]
    maxFileSize: 10MB
```

#### 3.3 Create Data Streams
```
Data Cloud → Data Streams → New
1. Source: Salesforce Files
2. Objects: ContentDocument, ContentVersion, ContentDocumentLink
3. Filter: FileType IN ('PDF', 'DOCX')
4. Schedule: Real-time or Daily
```

#### 3.4 Test Document Retrieval
```apex
// Anonymous Apex to test RAG
DataCloud.SearchRequest request = new DataCloud.SearchRequest();
request.query = 'payment terms net 30';
request.topK = 5;
request.dataSourceId = '<your_data_source_id>';

DataCloud.SearchResult result = DataCloud.search(request);
System.debug('Results: ' + result.chunks);
```

---

### Phase 4: Agent Configuration (Day 6-7)

#### 4.1 Create Agent
Navigate to: **Setup → Agentforce → Agents → New**

**Agent Details:**
- **Name:** Contract Analysis Agent
- **Description:** AI agent that analyzes MSAs and answers questions about contract terms
- **Channel:** Salesforce (embedded in Opportunity page)
- **Role:** Contract Analyst

#### 4.2 Define Agent Instructions (System Prompt)
```
You are a Contract Analysis Agent that helps sales and legal teams understand 
contract terms from uploaded documents. Your primary role is to answer questions 
about MSAs, NDAs, and other contract documents attached to Opportunities.

PRIMARY CAPABILITIES:
1. Answer specific questions about contract terms (payment, liability, SLA, etc.)
2. Summarize entire contracts with key terms and risk assessment
3. Compare multiple documents for consistency
4. Provide standard language recommendations
5. Flag non-standard or high-risk terms

KEY CONTRACT TERMS TO ANALYZE:
- Payment Terms (Standard: Net 30)
- Rollover Provisions
- Service Level Agreements (SLA/Uptime)
- Limitation of Liability
- Termination Clauses
- Renewal Terms
- Indemnification
- Data Rights and Ownership

WORKFLOW:
1. When asked about a contract term, search uploaded documents linked to the 
   current Opportunity or Account
2. Use RAG to find relevant contract sections
3. Provide direct quotes with document name and section reference
4. Flag if terms deviate from company standards
5. Calculate risk level: Low, Medium, High, or Critical

RESPONSE FORMAT:
- Quote exact language from document
- Cite source: "[Document Name], Section X"
- Explain significance/risk level
- Suggest next actions if non-standard

RISK ASSESSMENT CRITERIA:
- Low Risk: All terms meet company standards
- Medium Risk: 1-2 minor deviations, manageable impact
- High Risk: Multiple non-standard terms or significant deviations
- Critical Risk: Deal-breaking terms (e.g., unlimited liability, impossible SLAs)

TONE: Professional, precise, helpful. Always cite sources for credibility.
```

#### 4.3 Create Agent Topics

##### Topic 1: Contract Term Inquiry
**Description:** Answer questions about specific terms in contracts

**Sample Utterances:**
- "What are the payment terms?"
- "Show me the SLA uptime requirement"
- "What is the limitation of liability?"
- "Find the termination clause"
- "What are the renewal terms?"

**Actions:**
- Search RAG for relevant document sections
- Extract specific clause
- Provide quote with citation
- Flag if non-standard

---

##### Topic 2: Contract Summarization
**Description:** Summarize key terms and provide risk assessment

**Sample Utterances:**
- "Summarize this contract"
- "What are the key terms I need to know?"
- "Give me a contract overview"
- "Review this MSA and highlight risks"

**Actions:**
- Extract all major contract terms
- Calculate risk score
- Identify non-standard clauses
- Recommend next steps

---

##### Topic 3: Document Verification
**Description:** Compare multiple documents for consistency

**Sample Utterances:**
- "Compare the MSA and Order Form"
- "Are there inconsistencies in the contract documents?"
- "Verify the MSA matches the Order Form"
- "Check if all documents have the same payment terms"

**Actions:**
- Retrieve multiple documents
- Compare specified terms
- Flag discrepancies
- Recommend which document controls

---

##### Topic 4: Trend Analysis
**Description:** Analyze patterns across multiple contracts

**Sample Utterances:**
- "What percentage of contracts have Net 30 terms?"
- "Show me trends in SLA requirements"
- "How many contracts have unlimited liability?"
- "What's the average payment term?"

**Actions:**
- Aggregate data across all contracts
- Calculate percentages and averages
- Identify outliers
- Present trends with visualizations

---

##### Topic 5: Standard Language Guidance
**Description:** Provide template language for contract terms

**Sample Utterances:**
- "What's our standard payment terms language?"
- "Show me the template for limitation of liability"
- "What should I use for SLA clauses?"

**Actions:**
- Retrieve standard templates from Knowledge Base
- Explain why this language is used
- Provide usage examples

---

### Phase 5: Knowledge Base Setup (Day 8)

#### 5.1 Create Standard Language Articles
Create Knowledge Articles for common contract terms:

**Article 1: Payment Terms - Net 30**
```
Title: Standard Payment Terms (Net 30)
Type: Contract Template
Content:

RECOMMENDED LANGUAGE:
"Payment is due within thirty (30) days of invoice date. Late payments 
shall accrue interest at the rate of 1.5% per month (18% annually)."

WHY WE USE THIS:
- Industry standard
- Improves cash flow
- Provides late payment deterrent

WHEN TO DEVIATE:
- Strategic enterprise customers (negotiate to Net 45 maximum)
- Government contracts (may require Net 60)
- Never accept Net 90 or longer

RISK LEVEL: Low risk to deviate to Net 45; Medium risk for Net 60+
```

**Article 2: Limitation of Liability**
```
Title: Standard Limitation of Liability Clause
Type: Contract Template
Content:

RECOMMENDED LANGUAGE:
"In no event shall either party's aggregate liability under this Agreement 
exceed the total fees paid or payable in the twelve (12) months preceding 
the claim, except for breaches of confidentiality, willful misconduct, or 
gross negligence."

WHY WE USE THIS:
- Protects company from unlimited exposure
- 12-month cap is industry standard
- Carve-outs for critical breaches

WHEN TO DEVIATE:
- High-value strategic accounts (negotiate higher cap)
- Never accept unlimited liability
- Never accept caps below 6 months of fees

RISK LEVEL: Critical risk for unlimited liability; High risk for inadequate cap
```

Repeat for:
- SLA/Uptime Requirements
- Rollover Provisions
- Termination Clauses
- Renewal Terms
- Data Rights

---

### Phase 6: Testing & Validation (Day 9-10)

#### 6.1 Test Core Scenarios

**Test 1: Simple Term Inquiry**
```
User: "What are the payment terms for TechCorp?"
Expected: "Net 60 days per the MSA Section 2. [Quote exact language]. 
          NOTE: This deviates from our standard Net 30 terms."
```

**Test 2: Contract Summarization**
```
User: "Summarize the CloudVision contract and assess risk"
Expected: 
"CRITICAL RISK - Multiple concerning terms:
- Payment: Net 45 (non-standard)
- Rollover: 20% (excessive, standard is ≤10%)
- Uptime: 99.999% (nearly impossible to meet)
- Liability: $2M cap (very high)

RECOMMENDATION: Renegotiate uptime to 99.9%, reduce rollover to 10%, 
liability to 12-month fee cap."
```

**Test 3: Document Verification**
```
User: "Compare the TechCorp MSA and Order Form"
Expected: "INCONSISTENCY DETECTED:
- MSA Section 3: 15% rollover provision
- Order Form: 10% rollover provision
The MSA takes precedence per standard contract hierarchy. 
Update Order Form to reflect 15% or renegotiate MSA to 10%."
```

**Test 4: Trend Analysis**
```
User: "What percentage of our contracts have Net 30 payment terms?"
Expected: "60% (3 out of 5) have Net 30 terms:
✅ DataFlow Systems - Net 30
✅ AnalyticsPro - Net 30  
❌ TechCorp - Net 60
❌ CloudVision - Net 45
❌ Enterprise Data Co - Net 45"
```

**Test 5: Standard Language**
```
User: "What's our standard limitation of liability language?"
Expected: [Returns knowledge article with template and explanation]
```

#### 6.2 Validate Document Reading
```bash
# Verify files are indexed in Data Cloud
# Check RAG retrieval accuracy
# Test with various question phrasings
# Ensure proper citations (document name + section)
```

---

### Phase 7: Deployment (Day 11-12)

#### 7.1 Embed Agent in Salesforce
```
Setup → App Manager → Edit Opportunity Page
1. Add "Agent Chat" component to page layout
2. Select your Contract Analysis Agent
3. Position in right sidebar or bottom panel
4. Save and Activate
```

#### 7.2 Create Dashboard
Build a dashboard showing:
- Number of contracts analyzed
- Average risk score
- Compliance metrics (% with Net 30, standard SLA, etc.)
- Most common non-standard terms
- Time saved vs. manual review

#### 7.3 User Training
Create documentation:
- Quick start guide for end users
- Sample questions to ask
- Understanding risk levels
- When to escalate to legal

---

## Sample Apex Invocable Action (Optional Advanced)

If you want to invoke custom Apex logic from your agent:

```apex
public class ContractAnalysisAction {
    
    @InvocableMethod(label='Analyze Contract Risk' 
                     description='Calculates risk score for a contract')
    public static List<ContractRiskResult> analyzeContractRisk(
        List<ContractRiskRequest> requests) {
        
        List<ContractRiskResult> results = new List<ContractRiskResult>();
        
        for (ContractRiskRequest request : requests) {
            ContractRiskResult result = new ContractRiskResult();
            
            // Fetch contract documents
            List<ContentDocumentLink> docs = [
                SELECT ContentDocument.LatestPublishedVersion.VersionData,
                       ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :request.opportunityId
                AND ContentDocument.FileExtension = 'pdf'
            ];
            
            // Analyze key terms
            Integer riskScore = 0;
            List<String> riskFactors = new List<String>();
            
            // Check payment terms
            String paymentTerms = extractPaymentTerms(docs);
            if (paymentTerms != 'Net 30') {
                riskScore += 2;
                riskFactors.add('Non-standard payment terms: ' + paymentTerms);
            }
            
            // Check SLA
            Decimal sla = extractSLA(docs);
            if (sla > 99.9) {
                riskScore += 5;
                riskFactors.add('High SLA requirement: ' + sla + '%');
            }
            
            // Determine risk level
            if (riskScore >= 8) {
                result.riskLevel = 'Critical';
            } else if (riskScore >= 5) {
                result.riskLevel = 'High';
            } else if (riskScore >= 2) {
                result.riskLevel = 'Medium';
            } else {
                result.riskLevel = 'Low';
            }
            
            result.riskFactors = riskFactors;
            result.riskScore = riskScore;
            results.add(result);
        }
        
        return results;
    }
    
    private static String extractPaymentTerms(List<ContentDocumentLink> docs) {
        // Use Data Cloud RAG or simple text extraction
        // Return payment terms found
        return 'Net 30'; // Placeholder
    }
    
    private static Decimal extractSLA(List<ContentDocumentLink> docs) {
        // Extract SLA percentage
        return 99.9; // Placeholder
    }
    
    public class ContractRiskRequest {
        @InvocableVariable(required=true)
        public Id opportunityId;
    }
    
    public class ContractRiskResult {
        @InvocableVariable
        public String riskLevel;
        
        @InvocableVariable
        public Integer riskScore;
        
        @InvocableVariable
        public List<String> riskFactors;
    }
}
```

---

## Best Practices

### 1. Document Organization
- ✅ **Consistent naming:** Use `{Customer}_{DocType}_{Date}.pdf`
- ✅ **Proper linking:** Attach MSAs to Account, Order Forms to Opportunity
- ✅ **Version control:** Include date in filename
- ✅ **File size:** Keep PDFs under 10MB for optimal processing

### 2. Agent Instruction Design
- ✅ **Be specific:** Define exact terms to track
- ✅ **Provide context:** Explain why certain terms matter
- ✅ **Set standards:** Clearly state what's "normal" vs. "non-standard"
- ✅ **Include examples:** Show sample responses

### 3. Testing
- ✅ **Test edge cases:** What if document is missing? Unreadable?
- ✅ **Verify citations:** Always check document name and section are correct
- ✅ **Check accuracy:** Do spot checks on agent responses
- ✅ **User acceptance:** Have actual users test before rollout

### 4. Continuous Improvement
- ✅ **Monitor queries:** Track what users ask most often
- ✅ **Update instructions:** Refine based on actual usage
- ✅ **Expand knowledge:** Add new articles for common questions
- ✅ **Collect feedback:** Regular surveys from users

---

## Troubleshooting

### Issue: Agent can't find document terms
**Cause:** RAG indexing incomplete or file not uploaded properly  
**Solution:**
```bash
# Re-index documents
Setup → Data Cloud → Data Streams → [Your Stream] → Refresh

# Verify file upload
SELECT Id, Title, FileType, ContentSize 
FROM ContentDocument 
WHERE Title LIKE '%MSA%'

# Check ContentDocumentLink
SELECT LinkedEntityId, ContentDocument.Title 
FROM ContentDocumentLink 
WHERE LinkedEntityId = '<opportunity_id>'
```

### Issue: Agent responses are inaccurate
**Cause:** Poor instruction design or insufficient context  
**Solution:**
- Refine agent instructions with more specific guidance
- Lower similarity threshold in RAG config
- Add more example responses to instructions
- Create Knowledge Articles for standard responses

### Issue: Files not indexed in Data Cloud
**Cause:** Data stream not running or file type not supported  
**Solution:**
- Verify Data Cloud is properly configured
- Check file type (PDF, DOCX supported)
- Ensure file is linked to record (ContentDocumentLink exists)
- Manually trigger data stream refresh

### Issue: Agent citations are wrong
**Cause:** Multiple similar documents or chunking issues  
**Solution:**
- Adjust chunk size and overlap in RAG config
- Use more specific questions
- Ensure document names are descriptive
- Review document structure (clear sections/headings help)

---

## ROI Calculation

### Time Savings
```
CURRENT STATE (Manual Review):
• Average contract: 20 pages
• Review time: 30-60 minutes per contract
• 50 contracts/month = 25-50 hours/month
• At $100/hour (blended rate) = $2,500-5,000/month

WITH AGENT:
• Review time: 5-10 minutes per contract
• 50 contracts/month = 4-8 hours/month
• At $100/hour = $400-800/month

MONTHLY SAVINGS: $2,100-4,200
ANNUAL SAVINGS: $25,200-50,400
```

### Risk Mitigation
- Catch contract errors before signing: **Prevent $100K+ legal issues**
- Ensure compliance: **Avoid penalties and renegotiation costs**
- Standardization: **20-30% better terms over time**

### Scalability
- Manual review doesn't scale
- Agent handles 10x volume with same cost
- Enables sales team to move faster

---

## Next Steps

### For Demos (Now → 2 Weeks)
1. ✅ Choose implementation approach (Hybrid recommended)
2. ✅ Set up demo org with Data Cloud 360
3. ✅ Create 5-7 sample contracts with known variations
4. ✅ Configure agent with 3-5 core topics
5. ✅ Test all key scenarios
6. ✅ Create backup materials (slides, video)

### For Pilot (Weeks 2-6)
1. Get 10-20 real contracts (redacted if needed)
2. Configure agent with actual company standards
3. Test with 2-3 end users
4. Collect feedback and refine
5. Build dashboard for metrics

### For Production (Month 2-3)
1. Expand to full contract portfolio
2. Train entire sales/legal team
3. Integrate with workflow (approvals, alerts)
4. Set up monitoring and analytics
5. Document best practices

---

## Resources

### Salesforce Documentation
- [Agentforce Setup Guide](https://help.salesforce.com/agentforce)
- [Data Cloud 360](https://help.salesforce.com/data-cloud)
- [RAG Implementation](https://developer.salesforce.com/docs/einstein/genai/guide/rag-overview.html)

### Your Demo Resources
- `specs/starburstDealDeskAgentSpec.yaml` - Full agent specification
- `templates/starburst-contract-samples.md` - Sample contract text
- `STARBURST_README.md` - Complete demo package
- `STARBURST_DEMO_CHECKLIST.md` - Day-by-day setup tasks

---

## Summary

You now have a complete blueprint for building an Agentforce Agent that:
- ✅ Reads MSAs and contract documents from Salesforce Files
- ✅ Answers natural language questions about contract terms
- ✅ Summarizes contracts with risk assessment
- ✅ Compares documents for consistency
- ✅ Provides trend analysis across contract portfolio
- ✅ Delivers $25K-50K annual value through time savings

**Key Success Factors:**
1. Choose the right implementation approach for your timeline
2. Create realistic sample contracts with known variations
3. Write clear, specific agent instructions
4. Test thoroughly with actual user scenarios
5. Monitor and iterate based on feedback

**Ready to build?** Start with the Hybrid approach using 5-7 sample contracts and you'll have a compelling demo in 1 week!

---

*For questions or support, reference the existing Starburst demo resources or reach out to your Salesforce team.*

