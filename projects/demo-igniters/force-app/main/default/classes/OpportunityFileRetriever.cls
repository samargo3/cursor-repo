/**
 * OpportunityFileRetriever
 * 
 * Invocable Apex class to retrieve files attached to an Opportunity.
 * Can be used in:
 * - Screen Flows to display attached files
 * - Prompt Templates to provide file context to AI
 * - Agentforce Agents for document-aware actions
 * 
 * @author Solution Engineering Team
 * @version 1.0
 */
public with sharing class OpportunityFileRetriever {
    
    /**
     * Get Opportunity Files
     * Main invocable method to retrieve all files attached to an Opportunity
     */
    @InvocableMethod(
        label='Get Opportunity Files' 
        description='Retrieves all files attached to an Opportunity with metadata'
        category='Opportunity Management'
    )
    public static List<FileRetrievalResult> getOpportunityFiles(
        List<FileRetrievalRequest> requests
    ) {
        List<FileRetrievalResult> results = new List<FileRetrievalResult>();
        
        for (FileRetrievalRequest request : requests) {
            try {
                FileRetrievalResult result = retrieveFilesForOpportunity(request);
                results.add(result);
            } catch (Exception e) {
                // Return error result
                FileRetrievalResult errorResult = new FileRetrievalResult();
                errorResult.success = false;
                errorResult.errorMessage = 'Error retrieving files: ' + e.getMessage();
                errorResult.opportunityId = request.opportunityId;
                results.add(errorResult);
            }
        }
        
        return results;
    }
    
    /**
     * Retrieve files for a single opportunity
     */
    private static FileRetrievalResult retrieveFilesForOpportunity(
        FileRetrievalRequest request
    ) {
        FileRetrievalResult result = new FileRetrievalResult();
        result.success = true;
        result.opportunityId = request.opportunityId;
        
        // Validate Opportunity exists
        List<Opportunity> opportunities = [
            SELECT Id, Name 
            FROM Opportunity 
            WHERE Id = :request.opportunityId 
            LIMIT 1
        ];
        
        if (opportunities.isEmpty()) {
            result.success = false;
            result.errorMessage = 'Opportunity not found';
            return result;
        }
        
        result.opportunityName = opportunities[0].Name;
        
        // Build dynamic SOQL for ContentDocumentLink
        String fileTypeFilter = '';
        if (String.isNotBlank(request.fileTypes)) {
            // Parse comma-separated file types
            List<String> types = request.fileTypes.split(',');
            List<String> trimmedTypes = new List<String>();
            for (String type : types) {
                trimmedTypes.add('\'' + type.trim().toLowerCase() + '\'');
            }
            fileTypeFilter = ' AND ContentDocument.FileExtension IN (' + 
                           String.join(trimmedTypes, ',') + ')';
        }
        
        // Query all files linked to this Opportunity
        String query = 
            'SELECT ' +
            '    ContentDocument.Id, ' +
            '    ContentDocument.Title, ' +
            '    ContentDocument.FileExtension, ' +
            '    ContentDocument.FileType, ' +
            '    ContentDocument.ContentSize, ' +
            '    ContentDocument.CreatedDate, ' +
            '    ContentDocument.CreatedBy.Name, ' +
            '    ContentDocument.LatestPublishedVersionId ' +
            'FROM ContentDocumentLink ' +
            'WHERE LinkedEntityId = :request.opportunityId' + 
            fileTypeFilter +
            ' ORDER BY ContentDocument.CreatedDate DESC';
        
        // Apply limit if specified
        if (request.maxFiles != null && request.maxFiles > 0) {
            query += ' LIMIT ' + request.maxFiles;
        }
        
        List<ContentDocumentLink> docLinks = Database.query(query);
        
        if (docLinks.isEmpty()) {
            result.success = true;
            result.fileCount = 0;
            result.message = 'No files found attached to this Opportunity';
            result.fileDetails = new List<FileDetail>();
            result.fileList = '';
            return result;
        }
        
        // Build file details
        List<FileDetail> fileDetails = new List<FileDetail>();
        List<String> fileSummaries = new List<String>();
        Decimal totalSize = 0;
        
        for (ContentDocumentLink link : docLinks) {
            FileDetail detail = new FileDetail();
            detail.documentId = link.ContentDocument.Id;
            detail.versionId = link.ContentDocument.LatestPublishedVersionId;
            detail.title = link.ContentDocument.Title;
            detail.fileExtension = link.ContentDocument.FileExtension;
            detail.fileType = link.ContentDocument.FileType;
            detail.contentSize = link.ContentDocument.ContentSize;
            detail.createdDate = link.ContentDocument.CreatedDate;
            detail.createdByName = link.ContentDocument.CreatedBy.Name;
            detail.downloadUrl = '/sfc/servlet.shepherd/document/download/' + 
                                link.ContentDocument.Id;
            detail.viewUrl = '/lightning/r/ContentDocument/' + 
                            link.ContentDocument.Id + '/view';
            
            // Format file size for display
            detail.formattedSize = formatFileSize(link.ContentDocument.ContentSize);
            
            // Build file summary for AI/Prompt context
            String fileSummary = link.ContentDocument.Title + 
                               ' (.' + link.ContentDocument.FileExtension + 
                               ', ' + detail.formattedSize + 
                               ', uploaded by ' + detail.createdByName + 
                               ' on ' + link.ContentDocument.CreatedDate.format() + ')';
            
            fileDetails.add(detail);
            fileSummaries.add(fileSummary);
            totalSize += link.ContentDocument.ContentSize;
        }
        
        // Set result properties
        result.fileCount = docLinks.size();
        result.fileDetails = fileDetails;
        result.totalSize = totalSize;
        result.formattedTotalSize = formatFileSize(totalSize);
        
        // Create file list string for Flow/Prompt Builder
        result.fileList = String.join(fileSummaries, '\n');
        
        // Create structured summary for AI consumption
        result.fileSummary = buildFileSummary(fileDetails, opportunities[0].Name);
        
        // Success message
        result.message = 'Found ' + result.fileCount + ' file' + 
                        (result.fileCount == 1 ? '' : 's') + 
                        ' attached to ' + opportunities[0].Name;
        
        return result;
    }
    
    /**
     * Format file size in human-readable format
     */
    private static String formatFileSize(Decimal bytes) {
        if (bytes == null || bytes == 0) return '0 B';
        
        if (bytes < 1024) {
            return String.valueOf(bytes.format()) + ' B';
        } else if (bytes < 1048576) {
            return String.valueOf((bytes / 1024).setScale(1)) + ' KB';
        } else if (bytes < 1073741824) {
            return String.valueOf((bytes / 1048576).setScale(1)) + ' MB';
        } else {
            return String.valueOf((bytes / 1073741824).setScale(2)) + ' GB';
        }
    }
    
    /**
     * Build AI-friendly file summary
     */
    private static String buildFileSummary(List<FileDetail> files, String opportunityName) {
        String summary = 'Files attached to Opportunity "' + opportunityName + '":\n\n';
        
        Integer counter = 1;
        for (FileDetail file : files) {
            summary += counter + '. ' + file.title + '\n';
            summary += '   - Type: ' + file.fileExtension.toUpperCase() + ' (' + file.fileType + ')\n';
            summary += '   - Size: ' + file.formattedSize + '\n';
            summary += '   - Uploaded: ' + file.createdDate.format() + ' by ' + file.createdByName + '\n';
            summary += '   - Document ID: ' + file.documentId + '\n';
            summary += '\n';
            counter++;
        }
        
        return summary;
    }
    
    // ========================================================================
    // INNER CLASSES
    // ========================================================================
    
    /**
     * Input request for file retrieval
     */
    public class FileRetrievalRequest {
        @InvocableVariable(
            label='Opportunity ID' 
            description='ID of the Opportunity to retrieve files from'
            required=true
        )
        public Id opportunityId;
        
        @InvocableVariable(
            label='File Types Filter' 
            description='Comma-separated file extensions to filter (e.g., pdf,docx,xlsx). Leave blank for all types.'
            required=false
        )
        public String fileTypes;
        
        @InvocableVariable(
            label='Max Files' 
            description='Maximum number of files to retrieve. Leave blank for all files.'
            required=false
        )
        public Integer maxFiles;
    }
    
    /**
     * Result of file retrieval
     */
    public class FileRetrievalResult {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean success;
        
        @InvocableVariable(label='Error Message' description='Error message if operation failed')
        public String errorMessage;
        
        @InvocableVariable(label='Opportunity ID' description='ID of the Opportunity')
        public Id opportunityId;
        
        @InvocableVariable(label='Opportunity Name' description='Name of the Opportunity')
        public String opportunityName;
        
        @InvocableVariable(label='File Count' description='Number of files found')
        public Integer fileCount;
        
        @InvocableVariable(label='Total Size' description='Total size of all files in bytes')
        public Decimal totalSize;
        
        @InvocableVariable(label='Formatted Total Size' description='Total size formatted for display')
        public String formattedTotalSize;
        
        @InvocableVariable(label='File List' description='Formatted list of files for display')
        public String fileList;
        
        @InvocableVariable(label='File Summary' description='Detailed file summary for AI/Prompt context')
        public String fileSummary;
        
        @InvocableVariable(label='Message' description='Result message')
        public String message;
        
        @InvocableVariable(label='File Details' description='List of file detail objects')
        public List<FileDetail> fileDetails;
    }
    
    /**
     * Individual file detail
     */
    public class FileDetail {
        @InvocableVariable(label='Document ID' description='ContentDocument ID')
        public Id documentId;
        
        @InvocableVariable(label='Version ID' description='ContentVersion ID')
        public Id versionId;
        
        @InvocableVariable(label='Title' description='File title')
        public String title;
        
        @InvocableVariable(label='File Extension' description='File extension (e.g., pdf, docx)')
        public String fileExtension;
        
        @InvocableVariable(label='File Type' description='File type')
        public String fileType;
        
        @InvocableVariable(label='Content Size' description='File size in bytes')
        public Decimal contentSize;
        
        @InvocableVariable(label='Formatted Size' description='Formatted file size')
        public String formattedSize;
        
        @InvocableVariable(label='Created Date' description='Date file was created')
        public DateTime createdDate;
        
        @InvocableVariable(label='Created By Name' description='Name of user who uploaded the file')
        public String createdByName;
        
        @InvocableVariable(label='Download URL' description='URL to download the file')
        public String downloadUrl;
        
        @InvocableVariable(label='View URL' description='URL to view the file')
        public String viewUrl;
    }
}

