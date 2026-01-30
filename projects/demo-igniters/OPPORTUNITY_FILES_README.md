# Opportunity Files Retriever

> **Retrieve files attached to Opportunities for use in Flows, Prompt Templates, and Agentforce**

---

## 📋 What It Does

The **OpportunityFileRetriever** is an invocable Apex action that retrieves files (ContentDocuments) attached to an Opportunity and returns structured metadata that can be used in:

- ✨ **Screen Flows** - Display file lists to users
- 🤖 **Prompt Templates** - Provide file context to AI
- 🚀 **Agentforce Agents** - Enable document-aware actions
- 📧 **Autolaunched Flows** - Process files programmatically
- 🔔 **Notification Flows** - Include file information in alerts

---

## 🎯 Key Features

| Feature | Description |
|---------|-------------|
| **File Metadata** | Returns title, type, size, creator, dates, and URLs |
| **Filtering** | Filter by file types (PDF, DOCX, XLSX, etc.) |
| **Limiting** | Limit number of files returned |
| **AI-Ready Output** | Formatted summaries for Prompt Builder |
| **Error Handling** | Comprehensive success/error reporting |
| **Performance** | Efficient queries respecting governor limits |
| **Security** | Respects sharing rules and file permissions |

---

## 🚀 Quick Start

### 1. Deploy

```bash
cd demo-igniters
sf project deploy start \
  --source-dir force-app/main/default/classes/OpportunityFileRetriever.cls \
  --target-org [your-org-alias]
```

See [OPPORTUNITY_FILES_DEPLOYMENT.md](./OPPORTUNITY_FILES_DEPLOYMENT.md) for detailed deployment instructions.

### 2. Use in Flow

1. Open Flow Builder
2. Add **Action** element
3. Search for **Get Opportunity Files**
4. Set **Opportunity ID** to `{!recordId}`
5. Use outputs in screen or other elements

### 3. Use in Prompt Template

```
Context:
{!GetOpportunityFiles.File_Summary}

Analyze these documents and provide recommendations...
```

---

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| **[OPPORTUNITY_FILES_DEPLOYMENT.md](./OPPORTUNITY_FILES_DEPLOYMENT.md)** | Complete deployment guide with multiple options |
| **[OPPORTUNITY_FILES_RETRIEVER_GUIDE.md](./OPPORTUNITY_FILES_RETRIEVER_GUIDE.md)** | Comprehensive usage guide with examples |
| **[OPPORTUNITY_FILES_QUICK_REFERENCE.md](./OPPORTUNITY_FILES_QUICK_REFERENCE.md)** | Quick reference card for common patterns |

---

## 💡 Example Use Cases

### 1. Document Compliance Checker
Check if required files exist before closing opportunity
```
✓ Proposal Document (1 PDF)
✓ Signed Contract (1 PDF)
✗ Statement of Work (Missing)
```

### 2. AI Contract Analysis
Pass files to Agentforce for automated review
```
Analyze contract terms for:
- Payment terms
- Liability clauses  
- Risk factors
```

### 3. File Summary Email
Send weekly report of opportunity documents
```
Subject: Opportunity Files Summary
Body: {!FileSummary} with download links
```

### 4. File Gallery Component
Display files in custom Lightning component
```
Loop through FileDetails
Show thumbnail, name, size, download button
```

---

## 🔧 Input Parameters

| Parameter | Required | Type | Example |
|-----------|----------|------|---------|
| **Opportunity ID** | ✓ | ID | `{!recordId}` or `0061234567890ABC` |
| **File Types Filter** | ✗ | Text | `pdf,docx,xlsx` |
| **Max Files** | ✗ | Number | `10` |

---

## 📤 Output Parameters

### Essential Outputs

| Output | Type | Description |
|--------|------|-------------|
| **Success** | Boolean | Operation success status |
| **File Count** | Number | Number of files found |
| **File List** | Text | Formatted list for display |
| **File Summary** | Text | AI-friendly detailed summary |

### File Details Collection

Loop through **File Details** to access individual file properties:

| Property | Type | Example |
|----------|------|---------|
| **Title** | Text | `"Sales Proposal Q1"` |
| **File Extension** | Text | `"pdf"` |
| **Formatted Size** | Text | `"2.5 MB"` |
| **Download URL** | Text | `/sfc/servlet.shepherd/document/download/...` |
| **View URL** | Text | `/lightning/r/ContentDocument/.../view` |

See full list in [OPPORTUNITY_FILES_RETRIEVER_GUIDE.md](./OPPORTUNITY_FILES_RETRIEVER_GUIDE.md#output-parameters)

---

## 🎨 Sample Flow

A complete example flow is included: **Display_Opportunity_Files.flow**

**What it does:**
1. Retrieves files for an Opportunity
2. Checks if operation succeeded
3. Displays files with count and size
4. Shows friendly message if no files exist
5. Handles errors gracefully

**Deploy it:**
```bash
sf project deploy start \
  --source-dir force-app/main/default/flows/Display_Opportunity_Files.flow-meta.xml \
  --target-org [your-org-alias]
```

**Use it:**
- Add to Opportunity Lightning page
- Set `recordId` input to page context
- Flow displays files in screen

---

## ✅ Testing

Comprehensive test class included: **OpportunityFileRetriever_Test.cls**

**Test Coverage:** ~95%

**Tests include:**
- ✓ Retrieve files successfully
- ✓ Filter by file type
- ✓ Limit max files
- ✓ Handle no files scenario
- ✓ Handle invalid Opportunity ID
- ✓ Verify file size formatting
- ✓ Verify all file detail properties
- ✓ Multiple file types filter

**Run tests:**
```bash
sf apex run test \
  --class-names OpportunityFileRetriever_Test \
  --result-format human \
  --target-org [your-org-alias]
```

---

## 🔐 Security & Permissions

### Required Permissions

Users must have:
- Read access on **Opportunity**
- Read access on **ContentDocument**
- Read access on **ContentDocumentLink**
- **API Enabled** system permission

### Security Model

- Uses `with sharing` - respects org sharing rules
- Users can only see files they have access to
- No privilege escalation
- Download/view URLs respect Salesforce security

---

## 📊 Technical Details

### Architecture

```
OpportunityFileRetriever (Apex Class)
  ↓
  @InvocableMethod
  ↓
  Query ContentDocumentLink
  ↓
  Join to ContentDocument
  ↓
  Return FileRetrievalResult
    ├── File Count
    ├── File List (formatted)
    ├── File Summary (AI-ready)
    └── File Details (collection)
```

### Objects Used

| Object | Purpose |
|--------|---------|
| **ContentDocument** | Stores file metadata |
| **ContentVersion** | Stores file versions |
| **ContentDocumentLink** | Links files to records |

### Governor Limits

| Limit | Impact |
|-------|--------|
| SOQL Queries | 1 query to validate Opportunity + 1 query for files |
| Records Retrieved | Limited by Max Files parameter |
| Heap Size | Minimal - only metadata, not file content |
| CPU Time | Negligible for normal use |

---

## 🛠️ Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Action not visible in Flow | Clear cache, verify deployment |
| No files returned | Check user permissions, verify files exist |
| Permission denied | Grant ContentDocument read access |
| URLs not working | Ensure Lightning Experience, check file access |

See [OPPORTUNITY_FILES_DEPLOYMENT.md](./OPPORTUNITY_FILES_DEPLOYMENT.md#troubleshooting) for detailed troubleshooting.

---

## 📈 Roadmap / Future Enhancements

Potential future additions:
- Support for other objects (Account, Case, Custom Objects)
- File upload capability
- File deletion/management
- Tag-based filtering
- Date range filtering
- File type categorization (documents, images, etc.)
- Integration with Data Cloud for RAG

---

## 🤝 Contributing

This is part of the **demo-igniters** Salesforce demo toolkit.

To contribute:
1. Test thoroughly in scratch org
2. Maintain >75% code coverage
3. Update documentation
4. Follow existing code patterns

---

## 📝 Files Included

### Apex Classes
- `OpportunityFileRetriever.cls` - Main action class
- `OpportunityFileRetriever.cls-meta.xml` - Class metadata
- `OpportunityFileRetriever_Test.cls` - Test class
- `OpportunityFileRetriever_Test.cls-meta.xml` - Test metadata

### Sample Flow
- `Display_Opportunity_Files.flow-meta.xml` - Example screen flow

### Documentation
- `OPPORTUNITY_FILES_README.md` - This file (overview)
- `OPPORTUNITY_FILES_DEPLOYMENT.md` - Deployment guide
- `OPPORTUNITY_FILES_RETRIEVER_GUIDE.md` - Complete usage guide
- `OPPORTUNITY_FILES_QUICK_REFERENCE.md` - Quick reference

---

## 📞 Support

For issues or questions:
1. Review documentation in this directory
2. Check test class for usage examples
3. Verify permissions and access
4. Contact your Salesforce administrator

---

## 📄 License

Part of the demo-igniters toolkit for Salesforce demonstrations.

---

## 🎉 Get Started

Ready to use? Follow these steps:

1. **Deploy** → See [OPPORTUNITY_FILES_DEPLOYMENT.md](./OPPORTUNITY_FILES_DEPLOYMENT.md)
2. **Learn** → Read [OPPORTUNITY_FILES_RETRIEVER_GUIDE.md](./OPPORTUNITY_FILES_RETRIEVER_GUIDE.md)
3. **Reference** → Bookmark [OPPORTUNITY_FILES_QUICK_REFERENCE.md](./OPPORTUNITY_FILES_QUICK_REFERENCE.md)
4. **Build** → Create your first flow using the action!

---

**Happy Building! 🚀**

