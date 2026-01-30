# Opportunity Files Retriever Guide

## Overview

The **OpportunityFileRetriever** Apex action retrieves files attached to an Opportunity in Salesforce. This action is designed to be used in:
- **Screen Flows** - Display files to users
- **Prompt Templates** - Provide file context to AI/Agentforce
- **Autolaunched Flows** - Process files programmatically
- **Record-Triggered Flows** - React to file changes

## Features

✅ Retrieve all files attached to an Opportunity  
✅ Filter by file type (PDF, DOCX, XLSX, etc.)  
✅ Limit number of files returned  
✅ Get detailed file metadata (size, type, creator, URLs)  
✅ Get AI-friendly file summaries for Prompt Builder  
✅ Access download and view URLs for each file  

## How It Works

The action queries the `ContentDocumentLink` object to find all files linked to an Opportunity, retrieves metadata from `ContentDocument`, and returns structured information including:
- File titles, types, and sizes
- Upload dates and creators
- Direct download and view URLs
- Formatted summaries for AI consumption

---

## Usage in Screen Flow

### Step 1: Add Action Element

1. In Flow Builder, add an **Action** element
2. Search for and select **Get Opportunity Files**
3. Configure the input variables:

| Input Variable | Required | Description | Example |
|----------------|----------|-------------|---------|
| **Opportunity ID** | Yes | The ID of the Opportunity | `{!recordId}` or `{!$Record.Id}` |
| **File Types Filter** | No | Comma-separated file extensions | `pdf,docx,xlsx` |
| **Max Files** | No | Maximum number of files to return | `10` |

### Step 2: Use Output Variables

The action returns these output variables that you can use in your flow:

| Output Variable | Type | Description |
|-----------------|------|-------------|
| **Success** | Boolean | Whether the operation succeeded |
| **Error Message** | Text | Error message if operation failed |
| **Opportunity ID** | ID | The Opportunity ID that was queried |
| **Opportunity Name** | Text | Name of the Opportunity |
| **File Count** | Number | Total number of files found |
| **Total Size** | Number | Total size of all files in bytes |
| **Formatted Total Size** | Text | Human-readable total size (e.g., "2.5 MB") |
| **File List** | Text | Formatted list of files (one per line) |
| **File Summary** | Text | Detailed AI-friendly summary |
| **File Details** | Collection | List of FileDetail objects with full metadata |

### Step 3: Display Files in Screen

Add a **Display Text** component to show files:

```
Files attached to this Opportunity ({!GetOpportunityFiles.File_Count}):

{!GetOpportunityFiles.File_List}

Total Size: {!GetOpportunityFiles.Formatted_Total_Size}
```

### Example Flow: Display Files on Opportunity Page

**Flow Type:** Screen Flow  
**Object:** Opportunity  

**Flow Elements:**

1. **Screen: Display Files**
   - Input: `recordId` (from page context)
   - Action: Get Opportunity Files
     - Opportunity ID: `{!recordId}`
   - Display Text: Show file list

2. **Decision: Check if Files Exist**
   - If File Count > 0: Show files screen
   - If File Count = 0: Show "No files attached" message

---

## Usage in Prompt Template

### Step 1: Add Action to Flow

Before calling a prompt template, use the **Get Opportunity Files** action to retrieve file context:

1. Add **Action** element
2. Select **Get Opportunity Files**
3. Set Opportunity ID: `{!$Record.Id}`
4. Store output in a variable

### Step 2: Use in Prompt Template

The action provides AI-friendly outputs that can be directly used in prompts:

**Using File Summary:**
```
Analyze this opportunity and provide recommendations based on the attached files.

Opportunity: {!$Record.Name}
Amount: {!$Record.Amount}
Stage: {!$Record.StageName}

{!GetOpportunityFiles.File_Summary}

Based on these files, what are your recommendations?
```

**Using File List:**
```
You are reviewing an opportunity with the following files:

{!GetOpportunityFiles.File_List}

Summarize what documents are available and identify any missing standard documents.
```

### Example Prompt Template

```yaml
Prompt Template: Opportunity File Analysis

Input:
  - Opportunity ID
  - File Summary from OpportunityFileRetriever

Prompt:
  You are a sales operations assistant reviewing opportunity documentation.
  
  Opportunity Details:
  - Name: {!Opportunity.Name}
  - Amount: {!Opportunity.Amount}
  - Stage: {!Opportunity.StageName}
  - Close Date: {!Opportunity.CloseDate}
  
  Attached Files:
  {!FileSummary}
  
  Tasks:
  1. Verify all required documents are present (proposal, contract, SOW)
  2. Identify any missing documents
  3. Flag any documents that need review
  4. Provide recommendations for moving the deal forward
  
  Format your response as a structured analysis with sections for each task.
```

---

## Usage in Autolaunched Flow

### Use Case: Send Email with File Attachments

**Trigger:** When Opportunity Stage changes to "Proposal Sent"

**Flow Elements:**

1. **Get Records: Get Opportunity**
2. **Action: Get Opportunity Files**
   - Opportunity ID: `{!$Record.Id}`
   - File Types Filter: `pdf,docx`
3. **Loop: Through File Details**
   - Collection: `{!GetOpportunityFiles.File_Details}`
4. **Send Email**
   - Include file download links in email body

### Example Flow Configuration

```
Start: Record-Triggered Flow
Object: Opportunity
Trigger: Record is updated
Conditions: StageName = "Proposal Sent"

Action 1: Get Opportunity Files
  Input:
    - Opportunity ID: {!$Record.Id}
    - File Types Filter: pdf,docx
    - Max Files: 5

Decision 1: Has Files?
  Outcome 1: If File Count > 0
    - Send Email with file links
  Outcome 2: If File Count = 0
    - Log message: No files to share

Email Body:
  Hello,

  Your proposal for {!$Record.Name} is ready.
  
  Attached documents ({!GetOpportunityFiles.File_Count} files):
  {!GetOpportunityFiles.File_List}
  
  Total size: {!GetOpportunityFiles.Formatted_Total_Size}
  
  View files in Salesforce: [Link]
```

---

## Working with File Details Collection

The **File Details** output is a collection of FileDetail objects, each containing:

| Field | Type | Description |
|-------|------|-------------|
| Document ID | ID | ContentDocument ID |
| Version ID | ID | ContentVersion ID |
| Title | Text | File name without extension |
| File Extension | Text | Extension (pdf, docx, etc.) |
| File Type | Text | Salesforce file type |
| Content Size | Number | File size in bytes |
| Formatted Size | Text | Human-readable size |
| Created Date | DateTime | When file was uploaded |
| Created By Name | Text | User who uploaded the file |
| Download URL | Text | Direct download URL |
| View URL | Text | Lightning view URL |

### Looping Through Files

**Loop Configuration:**
- Collection Variable: `{!GetOpportunityFiles.File_Details}`
- Iteration Variable: `CurrentFile` (FileDetail type)

**Inside Loop:**
- Access: `{!CurrentFile.Title}`
- Access: `{!CurrentFile.Formatted_Size}`
- Access: `{!CurrentFile.Download_URL}`

### Example: Create Data Table

| File Name | Type | Size | Uploaded By | Upload Date |
|-----------|------|------|-------------|-------------|
| {!CurrentFile.Title} | {!CurrentFile.File_Extension} | {!CurrentFile.Formatted_Size} | {!CurrentFile.Created_By_Name} | {!CurrentFile.Created_Date} |

---

## Filtering Files

### Filter by File Type

Provide comma-separated extensions to only return specific file types:

**Examples:**
- `pdf` - Only PDF files
- `pdf,docx` - PDF and Word documents
- `pdf,docx,xlsx,pptx` - Common Office documents
- `jpg,png,gif` - Images only

**Note:** Extensions are case-insensitive

### Limit Number of Files

Set the **Max Files** parameter to limit results:

- `5` - Return only first 5 files
- `10` - Return only first 10 files
- Leave blank - Return all files

**Note:** Files are returned in descending order by creation date (newest first)

---

## Error Handling

### Check Success Variable

Always check the **Success** output variable:

```
Decision: Check Success
  Outcome 1: If Success = True
    - Process files normally
  Outcome 2: If Success = False
    - Display error message: {!GetOpportunityFiles.Error_Message}
    - Log error for troubleshooting
```

### Common Error Scenarios

| Error | Cause | Solution |
|-------|-------|----------|
| "Opportunity not found" | Invalid Opportunity ID | Verify record ID is valid |
| "No files found" | No files attached | This is informational, not an error |
| "Error retrieving files" | SOQL/permission issue | Check user permissions |

---

## Best Practices

### 1. Performance Optimization

- **Use filters** when possible to reduce data volume
- **Set max files** for large Opportunities with many attachments
- **Check file count** before processing to avoid unnecessary loops

### 2. User Experience

- Always show **file count** to set user expectations
- Display **formatted sizes** instead of raw bytes
- Provide **download links** for user convenience
- Show **upload date and creator** for context

### 3. AI/Prompt Integration

- Use **File Summary** for structured AI input
- Include **file types** in prompts to help AI understand document types
- Mention **file count** in prompts to set AI expectations
- Use **file list** for quick overviews

### 4. Security Considerations

- Action respects **sharing rules** (uses `with sharing`)
- Users can only see files they have access to
- Download URLs work within Salesforce security context

---

## Real-World Examples

### Example 1: Contract Review Agent

**Scenario:** Agentforce agent needs to analyze contract documents

**Flow Setup:**
1. User invokes agent on Opportunity page
2. Flow retrieves files: `Get Opportunity Files`
   - File Types Filter: `pdf,docx`
3. Pass File Summary to AI prompt template
4. Agent analyzes contract terms and provides insights

**Prompt:**
```
Analyze the following contract documents for risk assessment:

{!FileSummary}

Identify:
1. Payment terms
2. Liability clauses
3. Non-standard terms
4. Risk factors
```

### Example 2: Document Checklist Screen

**Scenario:** Sales rep needs to verify all documents before closing

**Flow Setup:**
1. Screen Flow on Opportunity record page
2. Get Opportunity Files action
3. Display checklist with file counts:
   - ✓ Proposal (1 PDF)
   - ✓ Contract (1 PDF)
   - ✗ SOW (0 files) - MISSING

### Example 3: File Summary Email

**Scenario:** Send weekly summary of opportunity files to sales manager

**Flow Setup:**
1. Scheduled Flow (weekly)
2. Get Records: Open Opportunities
3. Loop through Opportunities
4. For each: Get Opportunity Files
5. Build email with file summaries
6. Send consolidated report

---

## Testing

A comprehensive test class (`OpportunityFileRetriever_Test`) is included with:

✅ Test retrieving files successfully  
✅ Test file type filters  
✅ Test max files limit  
✅ Test Opportunities with no files  
✅ Test invalid Opportunity IDs  
✅ Test file size formatting  
✅ Test all file detail properties  
✅ Test multiple file types filter  

**Run Tests:**
```bash
sf apex run test -n OpportunityFileRetriever_Test -o [your-org-alias]
```

---

## Troubleshooting

### Files Not Appearing

**Check:**
1. Files are actually linked to the Opportunity (not just uploaded)
2. User has permission to view files
3. Files aren't archived or deleted
4. File type filter isn't too restrictive

### Performance Issues

**Solutions:**
1. Add file type filter to reduce query size
2. Set max files limit
3. Avoid calling in large loops
4. Consider caching results if calling multiple times

### URLs Not Working

**Check:**
1. User is accessing from within Salesforce
2. User has ContentDocument permissions
3. Files haven't been deleted
4. Using Lightning Experience (URLs are Lightning-compatible)

---

## API Reference

### Input Class: FileRetrievalRequest

```apex
public class FileRetrievalRequest {
    public Id opportunityId;      // Required
    public String fileTypes;      // Optional: "pdf,docx,xlsx"
    public Integer maxFiles;      // Optional: 10
}
```

### Output Class: FileRetrievalResult

```apex
public class FileRetrievalResult {
    public Boolean success;
    public String errorMessage;
    public Id opportunityId;
    public String opportunityName;
    public Integer fileCount;
    public Decimal totalSize;
    public String formattedTotalSize;
    public String fileList;
    public String fileSummary;
    public String message;
    public List<FileDetail> fileDetails;
}
```

### Output Class: FileDetail

```apex
public class FileDetail {
    public Id documentId;
    public Id versionId;
    public String title;
    public String fileExtension;
    public String fileType;
    public Decimal contentSize;
    public String formattedSize;
    public DateTime createdDate;
    public String createdByName;
    public String downloadUrl;
    public String viewUrl;
}
```

---

## Additional Resources

- [Salesforce Files Documentation](https://help.salesforce.com/s/articleView?id=sf.collab_files_overview.htm)
- [Flow Builder Documentation](https://help.salesforce.com/s/articleView?id=sf.flow.htm)
- [Prompt Builder Documentation](https://help.salesforce.com/s/articleView?id=sf.prompt_builder_overview.htm)
- [ContentDocument Object Reference](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_contentdocument.htm)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024 | Initial release with file retrieval, filtering, and AI-ready outputs |

---

## Support

For issues or questions:
1. Check this guide for common solutions
2. Review test class for usage examples
3. Verify user permissions and file access
4. Contact your Salesforce administrator

---

**Happy building! 🚀**

