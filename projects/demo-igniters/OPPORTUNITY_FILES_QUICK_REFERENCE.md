# Opportunity Files Retriever - Quick Reference

## Action Name
**Get Opportunity Files**

## Category
Opportunity Management

---

## Input Parameters

| Parameter | Required | Type | Example |
|-----------|----------|------|---------|
| Opportunity ID | ✓ | ID | `{!recordId}` |
| File Types Filter | ✗ | Text | `pdf,docx,xlsx` |
| Max Files | ✗ | Number | `10` |

---

## Key Outputs

| Output | Type | Use For |
|--------|------|---------|
| **Success** | Boolean | Error checking |
| **File Count** | Number | Checking if files exist |
| **File List** | Text | Quick display in screen |
| **File Summary** | Text | AI/Prompt Builder input |
| **File Details** | Collection | Loop processing |
| **Formatted Total Size** | Text | Display to users |

---

## Common Patterns

### Screen Flow Pattern
```
1. Add Action: Get Opportunity Files
   - Opportunity ID: {!recordId}
   
2. Display Text:
   Files ({!GetOpportunityFiles.File_Count}):
   {!GetOpportunityFiles.File_List}
```

### Prompt Template Pattern
```
Context:
{!GetOpportunityFiles.File_Summary}

Analyze these files and provide recommendations...
```

### Loop Pattern
```
1. Get Opportunity Files
2. Loop: {!GetOpportunityFiles.File_Details}
3. Access: {!CurrentFile.Title}
         {!CurrentFile.Download_URL}
```

---

## File Type Filters

| Filter Value | Result |
|--------------|--------|
| `pdf` | PDF files only |
| `pdf,docx` | PDF and Word |
| `pdf,docx,xlsx,pptx` | Office docs |
| `jpg,png,gif` | Images only |
| *(blank)* | All file types |

---

## Error Handling

```
Decision: Success Check
  If {!GetOpportunityFiles.Success} = True
    → Process files
  If {!GetOpportunityFiles.Success} = False
    → Show {!GetOpportunityFiles.Error_Message}
```

---

## File Detail Fields

Access in loop: `{!CurrentFile.[field]}`

- `Title` - File name
- `File_Extension` - pdf, docx, etc.
- `Formatted_Size` - "2.5 MB"
- `Created_Date` - Upload date
- `Created_By_Name` - Uploader
- `Download_URL` - Direct link
- `View_URL` - Lightning link

---

## Tips

✅ Always check `Success` before processing  
✅ Use `File_Count` to check if files exist  
✅ Use filters to improve performance  
✅ Use `File_Summary` for AI prompts  
✅ Use `File_Details` collection for loops  

❌ Don't assume files exist  
❌ Don't show raw bytes (use `Formatted_Size`)  
❌ Don't call in large loops without filters  

---

## Quick Test

```bash
# Run in Anonymous Apex
List<OpportunityFileRetriever.FileRetrievalRequest> requests = 
    new List<OpportunityFileRetriever.FileRetrievalRequest>();

OpportunityFileRetriever.FileRetrievalRequest req = 
    new OpportunityFileRetriever.FileRetrievalRequest();
req.opportunityId = 'YOUR_OPP_ID';

requests.add(req);

List<OpportunityFileRetriever.FileRetrievalResult> results = 
    OpportunityFileRetriever.getOpportunityFiles(requests);

System.debug('Files found: ' + results[0].fileCount);
System.debug('File list: ' + results[0].fileList);
```

---

## Example Use Cases

1. **Document Checklist** - Verify required files exist
2. **AI Contract Analysis** - Pass files to Agentforce
3. **Email Notifications** - Include file list in email
4. **File Gallery** - Display files in custom component
5. **Compliance Check** - Ensure all docs uploaded before close

---

For detailed documentation, see: `OPPORTUNITY_FILES_RETRIEVER_GUIDE.md`

