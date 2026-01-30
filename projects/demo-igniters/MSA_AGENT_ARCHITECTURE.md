# MSA Analysis Agent - Technical Architecture

## System Overview

The MSA Analysis Agent is built on Salesforce Agentforce and uses Data Cloud 360 with Retrieval-Augmented Generation (RAG) to read and analyze contract documents attached to Opportunities.

---

## Component Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                           │
│  (Salesforce Lightning: Opportunity Page with Embedded Agent)   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AGENTFORCE AGENT                           │
│                                                                 │
│  Agent Name: Contract Analysis Agent                           │
│  Role: Analyze MSAs, answer contract questions                 │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  AGENT TOPICS (5)                                        │ │
│  │  1. Contract Term Inquiry                                │ │
│  │  2. Contract Summarization                               │ │
│  │  3. Document Verification                                │ │
│  │  4. Trend Analysis                                       │ │
│  │  5. Standard Language Guidance                           │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  AGENT INSTRUCTIONS (System Prompt)                      │ │
│  │  - Define contract terms to analyze                      │ │
│  │  - Set risk assessment criteria                          │ │
│  │  - Provide response format guidelines                    │ │
│  │  - Specify standard vs. non-standard terms               │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────┬────────────────────────────┬─────────────────────┘
             │                            │
             │                            │
    ┌────────▼────────┐          ┌───────▼──────────────────────┐
    │   SALESFORCE    │          │    DATA CLOUD 360            │
    │   STRUCTURED    │          │    (Unstructured RAG)        │
    │   DATA          │          │                              │
    │                 │          │  ┌────────────────────────┐  │
    │ • Accounts      │          │  │  DOCUMENT INGESTION    │  │
    │ • Opportunities │          │  │                        │  │
    │ • Contracts     │          │  │  Sources:              │  │
    │ • Custom Fields │          │  │  - ContentDocument     │  │
    │                 │          │  │  - ContentVersion      │  │
    │ SOQL Queries    │          │  │  - ContentDocumentLink │  │
    │ for trends      │          │  │                        │  │
    └─────────────────┘          │  │  File Types:           │  │
                                 │  │  - PDF                 │  │
                                 │  │  - DOCX                │  │
                                 │  └────────────────────────┘  │
                                 │              ↓               │
                                 │  ┌────────────────────────┐  │
                                 │  │  TEXT EXTRACTION       │  │
                                 │  │  - OCR for PDFs        │  │
                                 │  │  - Parse DOCX          │  │
                                 │  │  - Clean & normalize   │  │
                                 │  └────────────────────────┘  │
                                 │              ↓               │
                                 │  ┌────────────────────────┐  │
                                 │  │  CHUNKING              │  │
                                 │  │  - Chunk size: 1000    │  │
                                 │  │  - Overlap: 200        │  │
                                 │  │  - Preserve context    │  │
                                 │  └────────────────────────┘  │
                                 │              ↓               │
                                 │  ┌────────────────────────┐  │
                                 │  │  VECTOR EMBEDDINGS     │  │
                                 │  │  Model: text-embedding │  │
                                 │  │         -ada-002       │  │
                                 │  │  Dimension: 1536       │  │
                                 │  └────────────────────────┘  │
                                 │              ↓               │
                                 │  ┌────────────────────────┐  │
                                 │  │  VECTOR DATABASE       │  │
                                 │  │  - Index embeddings    │  │
                                 │  │  - Semantic search     │  │
                                 │  │  - Similarity scoring  │  │
                                 │  └────────────────────────┘  │
                                 │              ↓               │
                                 │  ┌────────────────────────┐  │
                                 │  │  RETRIEVAL (RAG)       │  │
                                 │  │  - Top K: 5            │  │
                                 │  │  - Threshold: 0.75     │  │
                                 │  │  - Context ranking     │  │
                                 │  └────────────────────────┘  │
                                 └──────────────────────────────┘
                                              ↓
                       ┌──────────────────────────────────────────┐
                       │    RESPONSE GENERATION (LLM)             │
                       │                                          │
                       │  • Combine retrieved chunks              │
                       │  • Apply agent instructions              │
                       │  • Generate natural language response    │
                       │  • Include document citations            │
                       └──────────────────────────────────────────┘
                                              ↓
                       ┌──────────────────────────────────────────┐
                       │    OPTIONAL: APEX INVOCABLE ACTIONS      │
                       │                                          │
                       │  ContractAnalysisAgent.cls:              │
                       │  • Extract specific terms                │
                       │  • Calculate risk scores                 │
                       │  • Update Opportunity fields             │
                       │  • Generate structured output            │
                       └──────────────────────────────────────────┘
                                              ↓
                       ┌──────────────────────────────────────────┐
                       │    RESPONSE TO USER                      │
                       │                                          │
                       │  Format:                                 │
                       │  • Quoted text from document             │
                       │  • Citation [Document, Section]          │
                       │  • Risk assessment                       │
                       │  • Recommendations                       │
                       └──────────────────────────────────────────┘
```

---

## Data Flow

### Query Flow: "What are the payment terms for TechCorp?"

```
1. USER QUERY
   ↓
   Input: "What are the payment terms for TechCorp?"
   Context: Opportunity = TechCorp MSA Deal

2. AGENT ROUTER
   ↓
   Identifies Topic: "Contract Term Inquiry"
   Extracts Intent: Find payment terms
   Extracts Entity: TechCorp

3. CONTEXT RETRIEVAL
   ↓
   SOQL: Get Opportunity ID
   SOQL: Get linked ContentDocuments
   
4. RAG SEMANTIC SEARCH
   ↓
   Query: "payment terms invoice net days"
   Search: TechCorp_MSA.pdf embeddings
   Retrieve: Top 5 most relevant chunks
   
   Results:
   Chunk 1 (0.92): "Payment Terms. Net 60 Days. Customer shall..."
   Chunk 2 (0.85): "...invoice date. Late payments shall accrue..."
   Chunk 3 (0.78): "...payment obligation under Section 2..."

5. CONTEXT AUGMENTATION
   ↓
   Combines:
   - Agent instructions (know standard is Net 30)
   - Retrieved chunks from document
   - Salesforce context (Opportunity, Account)

6. LLM GENERATION
   ↓
   Prompt to LLM:
   """
   You are a Contract Analysis Agent. Based on these document chunks,
   answer the user's question about payment terms. Always cite the source.
   
   Standard payment terms: Net 30
   
   Document chunks:
   [Chunk 1], [Chunk 2], [Chunk 3]
   
   Question: What are the payment terms for TechCorp?
   """

7. RESPONSE GENERATION
   ↓
   LLM Output:
   """
   The payment terms for TechCorp are Net 60 days per the Master Service
   Agreement, Section 2:
   
   "Payment Terms. Net 60 Days. Customer shall pay all invoices within
   sixty (60) days of invoice date."
   
   ⚠️ NOTE: This deviates from our standard Net 30 payment terms, resulting
   in a 30-day delay in cash flow.
   
   RECOMMENDATION: Negotiate back to Net 30 or add early payment discount.
   """

8. OPTIONAL: APEX ACTION
   ↓
   If configured, invoke ContractAnalysisAgent.analyzeContract()
   - Updates Opportunity.Payment_Terms__c = "Net 60"
   - Updates Opportunity.Contract_Risk_Level__c = "Medium"

9. RESPONSE TO USER
   ↓
   Display in Agent chat interface
```

---

## Technology Stack

### Core Technologies

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI** | Salesforce Lightning | Agent chat interface |
| **Agent Framework** | Agentforce | Conversational AI orchestration |
| **Document Storage** | Salesforce Files | PDF/DOCX storage (ContentDocument) |
| **Document Processing** | Data Cloud 360 | Text extraction, chunking, embedding |
| **Vector Database** | Data Cloud Vector Store | Semantic search index |
| **Embedding Model** | text-embedding-ada-002 | Convert text to vectors (1536 dimensions) |
| **LLM** | GPT-4 (via Einstein) | Natural language understanding & generation |
| **Structured Data** | Salesforce Objects | Accounts, Opportunities, SOQL |
| **Custom Logic** | Apex (Invocable) | Risk calculation, field updates |
| **Knowledge Base** | Salesforce Knowledge | Standard language templates |

---

## Document Processing Pipeline

### Step 1: Upload
```
User uploads TechCorp_MSA.pdf to Opportunity
    ↓
ContentVersion created (binary blob)
    ↓
ContentDocument created (metadata)
    ↓
ContentDocumentLink created (links to Opportunity)
```

### Step 2: Data Cloud Ingestion
```
Data Stream: Salesforce Files
    ↓
Filter: FileType = 'pdf' OR FileType = 'docx'
    ↓
Extract: Pull ContentVersion.VersionData (binary)
```

### Step 3: Text Extraction
```
PDF Parser:
    ↓
Extract text: "MASTER SERVICE AGREEMENT..."
    ↓
Clean: Remove headers, footers, page numbers
    ↓
Normalize: Standardize spacing, line breaks
```

### Step 4: Chunking
```
Full Text (10,000 characters)
    ↓
Chunk 1: Characters 0-1000 (Section 1: Services)
Chunk 2: Characters 800-1800 (overlap 200, Section 2: Payment)
Chunk 3: Characters 1600-2600 (Section 2-3: Payment, Terms)
...
Chunk N: Characters 9200-10000 (Section 10: Signatures)
```

### Step 5: Embedding
```
For each chunk:
    ↓
Chunk Text: "Payment Terms. Net 60 Days. Customer shall..."
    ↓
Embedding Model (OpenAI text-embedding-ada-002)
    ↓
Vector: [0.023, -0.145, 0.892, ..., 0.412] (1536 dimensions)
```

### Step 6: Indexing
```
Vector Database:
    ↓
Store: {
    chunk_id: "techcorp_msa_chunk_2",
    document_id: "0691234567890",
    document_name: "TechCorp_MSA.pdf",
    section: "Section 2: Payment Terms",
    text: "Payment Terms. Net 60 Days...",
    vector: [0.023, -0.145, ...],
    metadata: {
        opportunity_id: "0061234567890",
        account_name: "TechCorp International",
        upload_date: "2025-11-11"
    }
}
```

### Step 7: Query Time (RAG Retrieval)
```
User Query: "What are the payment terms?"
    ↓
Query Embedding: [0.021, -0.143, 0.889, ..., 0.408]
    ↓
Similarity Search: Cosine similarity between query vector and all chunk vectors
    ↓
Rank Results:
    Chunk 2: 0.92 similarity (payment terms section)
    Chunk 15: 0.85 similarity (mentions payment in limitations)
    Chunk 3: 0.78 similarity (payment obligations)
    Chunk 22: 0.72 similarity (late payment interest)
    Chunk 7: 0.68 similarity (billing contact info)
    ↓
Filter: Keep only > 0.75 threshold
    ↓
Return Top K: 5 chunks (only 3 pass threshold)
```

---

## Risk Assessment Logic

### Risk Scoring Algorithm

```python
risk_score = 0
risk_factors = []

# Payment Terms Assessment
if payment_terms == "Net 60":
    risk_score += 3
    risk_factors.append("Non-standard payment terms: Net 60")
elif payment_terms == "Net 90":
    risk_score += 5
    risk_factors.append("CRITICAL: Net 90 payment terms unacceptable")

# Uptime SLA Assessment
if uptime > 99.9:
    risk_score += 5
    risk_factors.append("CRITICAL: Uptime requirement may be impossible to meet")

# Rollover Terms Assessment
if rollover > 10 and rollover <= 15:
    risk_score += 2
    risk_factors.append("Rollover terms exceed standard")
elif rollover > 15:
    risk_score += 3
    risk_factors.append("CRITICAL: Excessive rollover terms")

# Liability Cap Assessment
if liability_cap > 1000000:
    risk_score += 2
    risk_factors.append("High liability cap")

# Determine Risk Level
if risk_score >= 10:
    risk_level = "Critical"
elif risk_score >= 7:
    risk_level = "High"
elif risk_score >= 3:
    risk_level = "Medium"
else:
    risk_level = "Low"
```

### Risk Matrix

| Risk Level | Score Range | Action Required | Examples |
|-----------|-------------|-----------------|----------|
| **Low** | 0-2 | Standard approval | Net 30, 99.9% uptime, ≤10% rollover |
| **Medium** | 3-6 | Manager approval | Net 45, 8-10% rollover |
| **High** | 7-9 | Senior approval + negotiation | Net 60, 15% rollover, 99.95% uptime |
| **Critical** | 10+ | Legal review, do not sign | Net 90, 99.999% uptime, unlimited liability |

---

## Scalability & Performance

### Document Volume Capacity

| Metric | Capacity | Notes |
|--------|----------|-------|
| **Documents per Opportunity** | Unlimited | Practical limit ~10-20 for performance |
| **Total documents in org** | 100,000+ | Data Cloud scales horizontally |
| **Document size** | 10MB max recommended | Larger files = slower processing |
| **Pages per document** | Up to 500 pages | Beyond 500, consider splitting |
| **Query response time** | 2-5 seconds | Includes RAG retrieval + LLM generation |

### Optimization Strategies

1. **Chunk Size Tuning**
   - Smaller chunks (500): Better precision, more API calls
   - Larger chunks (2000): Better context, less precise
   - Recommended: 1000 with 200 overlap

2. **Caching**
   - Cache frequently accessed documents
   - Cache common queries
   - TTL: 24 hours

3. **Filtering**
   - Filter by Opportunity before RAG search
   - Filter by document type (MSA vs NDA vs Order Form)
   - Filter by date range

4. **Batch Processing**
   - Index documents asynchronously after upload
   - Run trend analysis on schedule (daily)
   - Pre-compute risk scores

---

## Security & Compliance

### Data Security

```
┌────────────────────────────────────────────┐
│  SALESFORCE SECURITY MODEL                 │
│                                            │
│  • Object-Level Security                   │
│    - Profile permissions                   │
│    - Permission sets                       │
│                                            │
│  • Record-Level Security                   │
│    - Sharing rules                         │
│    - Role hierarchy                        │
│    - Manual sharing                        │
│                                            │
│  • Field-Level Security                    │
│    - Field permissions                     │
│    - Page layouts                          │
│                                            │
│  IF USER CANNOT SEE OPPORTUNITY            │
│  THEN AGENT CANNOT ACCESS FILES            │
└────────────────────────────────────────────┘
```

### Compliance Features

- ✅ **Audit Trail**: All agent interactions logged
- ✅ **Data Residency**: Files stay in Salesforce org
- ✅ **Encryption**: At rest and in transit
- ✅ **Access Control**: Respects Salesforce permissions
- ✅ **PII Protection**: No data sent to external systems (when self-hosted)
- ✅ **GDPR Ready**: Right to deletion, data portability
- ✅ **SOC 2 Compliant**: Salesforce infrastructure

---

## Monitoring & Observability

### Key Metrics to Track

1. **Usage Metrics**
   - Queries per day
   - Unique users
   - Most common questions
   - Average response time

2. **Quality Metrics**
   - User feedback (thumbs up/down)
   - Citation accuracy
   - Response relevance
   - Escalation rate

3. **Business Metrics**
   - Time saved per contract
   - Errors caught
   - Compliance improvement
   - Contract review velocity

### Logging Strategy

```apex
// Log every agent interaction
Agent_Interaction__c interaction = new Agent_Interaction__c(
    Opportunity__c = oppId,
    User_Question__c = userQuery,
    Agent_Response__c = agentResponse,
    Documents_Referenced__c = documentNames,
    Risk_Level__c = riskLevel,
    Response_Time_Ms__c = responseTime,
    User_Feedback__c = feedback
);
insert interaction;
```

---

## Deployment Architecture

### Development → Staging → Production

```
┌──────────────────┐
│  DEVELOPER ORG   │  • Build agent config
│                  │  • Test with sample contracts
│                  │  • Iterate on instructions
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  STAGING ORG     │  • Load realistic sample data
│                  │  • User acceptance testing
│                  │  • Performance testing
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  PRODUCTION ORG  │  • Full contract portfolio
│                  │  • All users enabled
│                  │  • Monitoring active
└──────────────────┘
```

### Change Management

1. **Agent Instructions**: Version control in Git, deploy via metadata API
2. **Apex Classes**: Standard Salesforce deployment pipeline
3. **Knowledge Articles**: Bulk load via Data Loader
4. **Data Cloud Config**: Manual changes, document in runbook

---

## Future Enhancements

### Phase 2: Advanced Features

1. **Proactive Alerts**
   - Notify when non-standard terms detected
   - Alert when contract expiring soon
   - Flag when competitor mentioned

2. **Contract Comparison**
   - Compare customer's current vs. proposed contract
   - Benchmark against industry standards
   - Identify deviations from template

3. **Auto-Population**
   - Extract terms from PDF
   - Auto-fill Opportunity fields
   - Suggest quote adjustments

4. **Workflow Integration**
   - Trigger approval process based on risk
   - Route high-risk contracts to legal
   - Create tasks for negotiation

### Phase 3: AI Improvements

1. **Fine-Tuned Models**
   - Train custom model on your contracts
   - Improve extraction accuracy
   - Reduce hallucinations

2. **Multi-Modal**
   - Analyze contract images (signatures, stamps)
   - Extract data from tables
   - Parse complex formatting

3. **Predictive Analytics**
   - Predict deal closure based on terms
   - Identify optimal terms by industry
   - Forecast revenue impact of terms

---

## Summary

This architecture enables:
- ✅ Natural language Q&A on contract documents
- ✅ Semantic understanding (not keyword matching)
- ✅ Accurate citations with source references
- ✅ Risk assessment and recommendations
- ✅ Scalable to thousands of documents
- ✅ Enterprise-grade security and compliance

**Key Innovation:** Combining Salesforce structured data (Opportunities, Accounts) with unstructured document data (MSAs, contracts) via RAG enables insights previously impossible without manual review.

---

*For implementation details, see MSA_ANALYSIS_AGENT_GUIDE.md*

