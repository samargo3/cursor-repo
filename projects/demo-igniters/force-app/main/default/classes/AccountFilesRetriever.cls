/**
 * AccountFilesRetriever
 * 
 * Invocable Apex action to retrieve files directly attached to an Account
 * (not through Opportunities - use AccountOpportunityFilesRetriever for that)
 * 
 * Use Cases:
 * - Account-level documents (contracts, NDAs, account plans)
 * - Files uploaded directly to Account record
 * - Document compliance checking at account level
 * - AI-powered account document analysis
 * 
 * @author Solution Engineering Team
 * @version 1.0
 */
public with sharing class AccountFilesRetriever {
    
    /**
     * Get Account Files
     * Main invocable method to retrieve files directly attached to an Account
     */
    @InvocableMethod(
        label='Get Account Files' 
        description='Retrieves all files directly attached to an Account record'
        category='Account Management'
    )
    public static List<AccountFilesResult> getAccountFiles(
        List<AccountFilesRequest> requests
    ) {
        List<AccountFilesResult> results = new List<AccountFilesResult>();
        
        for (AccountFilesRequest request : requests) {
            try {
                AccountFilesResult result = retrieveFilesForAccount(request);
                results.add(result);
            } catch (Exception e) {
                // Return error result
                AccountFilesResult errorResult = new AccountFilesResult();
                errorResult.success = false;
                errorResult.errorMessage = 'Error retrieving account files: ' + e.getMessage();
                errorResult.accountId = request.accountId;
                results.add(errorResult);
            }
        }
        
        return results;
    }
    
    /**
     * Retrieve files directly attached to an account
     */
    private static AccountFilesResult retrieveFilesForAccount(
        AccountFilesRequest request
    ) {
        AccountFilesResult result = new AccountFilesResult();
        result.success = true;
        result.accountId = request.accountId;
        
        // Query Account with CombinedAttachments (files)
        List<Account> accounts = [
            SELECT 
                Id, 
                Name,
                (SELECT 
                    Id,
                    Title,
                    FileExtension,
                    ContentSize,
                    CreatedDate,
                    CreatedBy.Name,
                    LastModifiedDate
                 FROM CombinedAttachments
                 ORDER BY CreatedDate DESC)
            FROM Account 
            WHERE Id = :request.accountId 
            LIMIT 1
        ];
        
        if (accounts.isEmpty()) {
            result.success = false;
            result.errorMessage = 'Account not found';
            return result;
        }
        
        Account acc = accounts[0];
        result.accountName = acc.Name;
        
        // Get the attachments from the query
        List<CombinedAttachment> attachments = acc.CombinedAttachments;
        
        if (attachments == null || attachments.isEmpty()) {
            result.success = true;
            result.fileCount = 0;
            result.message = 'No files found directly attached to this Account';
            result.fileDetails = new List<FileDetail>();
            result.fileSummary = buildEmptySummary(acc.Name);
            result.fileList = 'No files attached';
            return result;
        }
        
        // Apply file type filter if specified
        List<CombinedAttachment> filteredAttachments = attachments;
        if (String.isNotBlank(request.fileTypes)) {
            List<String> allowedTypes = new List<String>();
            for (String type : request.fileTypes.split(',')) {
                allowedTypes.add(type.trim().toLowerCase());
            }
            
            filteredAttachments = new List<CombinedAttachment>();
            for (CombinedAttachment att : attachments) {
                if (String.isNotBlank(att.FileExtension) && 
                    allowedTypes.contains(att.FileExtension.toLowerCase())) {
                    filteredAttachments.add(att);
                }
            }
        }
        
        // Apply max files limit if specified
        if (request.maxFiles != null && request.maxFiles > 0 && 
            filteredAttachments.size() > request.maxFiles) {
            List<CombinedAttachment> limitedAttachments = new List<CombinedAttachment>();
            for (Integer i = 0; i < request.maxFiles && i < filteredAttachments.size(); i++) {
                limitedAttachments.add(filteredAttachments[i]);
            }
            filteredAttachments = limitedAttachments;
        }
        
        result.fileCount = filteredAttachments.size();
        result.fileDetails = new List<FileDetail>();
        result.totalSize = 0;
        
        // Build file details
        for (CombinedAttachment att : filteredAttachments) {
            FileDetail detail = new FileDetail();
            detail.fileId = att.Id;
            detail.title = att.Title;
            detail.fileExtension = att.FileExtension != null ? att.FileExtension : 'unknown';
            detail.contentSize = att.ContentSize != null ? att.ContentSize : 0;
            detail.formattedSize = formatFileSize(detail.contentSize);
            detail.createdDate = att.CreatedDate;
            detail.createdByName = att.CreatedBy.Name;
            detail.lastModifiedDate = att.LastModifiedDate;
            detail.downloadUrl = '/sfc/servlet.shepherd/document/download/' + att.Id;
            detail.viewUrl = '/lightning/r/ContentDocument/' + att.Id + '/view';
            
            result.fileDetails.add(detail);
            result.totalSize += detail.contentSize;
        }
        
        result.formattedTotalSize = formatFileSize(result.totalSize);
        result.fileSummary = buildFileSummary(acc.Name, result.fileDetails, result.totalSize);
        result.fileList = buildFileList(result.fileDetails);
        result.message = 'Found ' + result.fileCount + ' file(s) attached to Account';
        
        return result;
    }
    
    /**
     * Build summary for empty result
     */
    private static String buildEmptySummary(String accountName) {
        return 'ACCOUNT FILES\n' +
               '==================================================\n\n' +
               'Account: ' + accountName + '\n' +
               'Files Found: 0\n\n' +
               'No files are directly attached to this account.\n';
    }
    
    /**
     * Build formatted file summary for AI/display
     */
    private static String buildFileSummary(
        String accountName, 
        List<FileDetail> files, 
        Long totalSize
    ) {
        String summary = 'ACCOUNT FILES\n';
        summary += '==================================================\n\n';
        summary += 'Account: ' + accountName + '\n';
        summary += 'Total Files: ' + files.size() + '\n';
        summary += 'Total Size: ' + formatFileSize(totalSize) + '\n\n';
        summary += '==================================================\n';
        summary += 'FILES\n';
        summary += '==================================================\n\n';
        
        Integer index = 1;
        for (FileDetail file : files) {
            summary += index + '. ' + file.title;
            if (String.isNotBlank(file.fileExtension)) {
                summary += '.' + file.fileExtension;
            }
            summary += '\n';
            summary += '   Type: ' + file.fileExtension.toUpperCase() + 
                      ' | Size: ' + file.formattedSize;
            if (file.createdDate != null) {
                summary += ' | Uploaded: ' + file.createdDate.format('yyyy-MM-dd HH:mm');
            }
            if (String.isNotBlank(file.createdByName)) {
                summary += ' by ' + file.createdByName;
            }
            summary += '\n\n';
            index++;
        }
        
        return summary;
    }
    
    /**
     * Build simple file list
     */
    private static String buildFileList(List<FileDetail> files) {
        if (files.isEmpty()) {
            return 'No files';
        }
        
        List<String> fileNames = new List<String>();
        for (FileDetail file : files) {
            String name = file.title;
            if (String.isNotBlank(file.fileExtension)) {
                name += '.' + file.fileExtension;
            }
            fileNames.add(name);
        }
        
        return String.join(fileNames, ', ');
    }
    
    /**
     * Format file size in human-readable format
     */
    private static String formatFileSize(Long bytes) {
        if (bytes == null || bytes == 0) {
            return '0 B';
        }
        
        if (bytes < 1024) {
            return bytes + ' B';
        } else if (bytes < 1024 * 1024) {
            Decimal kb = Decimal.valueOf(bytes).divide(1024, 1, System.RoundingMode.HALF_UP);
            return kb.format() + ' KB';
        } else if (bytes < 1024 * 1024 * 1024) {
            Decimal mb = Decimal.valueOf(bytes).divide(1024 * 1024, 2, System.RoundingMode.HALF_UP);
            return mb.format() + ' MB';
        } else {
            Decimal gb = Decimal.valueOf(bytes).divide(1024 * 1024 * 1024, 2, System.RoundingMode.HALF_UP);
            return gb.format() + ' GB';
        }
    }
    
    // ========================================================================
    // INNER CLASSES
    // ========================================================================
    
    /**
     * Input request for account file retrieval
     */
    public class AccountFilesRequest {
        @InvocableVariable(
            label='Account ID' 
            description='ID of the Account to retrieve files from'
            required=true
        )
        public Id accountId;
        
        @InvocableVariable(
            label='File Types Filter' 
            description='Comma-separated list of file extensions (e.g., pdf,docx,xlsx). Leave blank for all types.'
            required=false
        )
        public String fileTypes;
        
        @InvocableVariable(
            label='Max Files' 
            description='Maximum number of files to return. Leave blank for all files.'
            required=false
        )
        public Integer maxFiles;
    }
    
    /**
     * Result of account file retrieval
     */
    public class AccountFilesResult {
        @InvocableVariable(label='Success' description='Whether the operation succeeded')
        public Boolean success;
        
        @InvocableVariable(label='Error Message' description='Error message if operation failed')
        public String errorMessage;
        
        @InvocableVariable(label='Account ID' description='The Account ID queried')
        public Id accountId;
        
        @InvocableVariable(label='Account Name' description='Name of the Account')
        public String accountName;
        
        @InvocableVariable(label='File Count' description='Number of files found')
        public Integer fileCount;
        
        @InvocableVariable(label='Total Size' description='Total size of all files in bytes')
        public Long totalSize;
        
        @InvocableVariable(label='Formatted Total Size' description='Human-readable total size')
        public String formattedTotalSize;
        
        @InvocableVariable(label='File List' description='Comma-separated list of file names')
        public String fileList;
        
        @InvocableVariable(label='File Summary' description='Formatted summary for AI/display')
        public String fileSummary;
        
        @InvocableVariable(label='File Details' description='Collection of file detail objects')
        public List<FileDetail> fileDetails;
        
        @InvocableVariable(label='Message' description='Result message')
        public String message;
    }
    
    /**
     * File detail information
     */
    public class FileDetail {
        @InvocableVariable(label='File ID' description='ContentDocument ID')
        public Id fileId;
        
        @InvocableVariable(label='Title' description='File title/name')
        public String title;
        
        @InvocableVariable(label='File Extension' description='File extension (pdf, docx, etc.)')
        public String fileExtension;
        
        @InvocableVariable(label='Content Size' description='File size in bytes')
        public Long contentSize;
        
        @InvocableVariable(label='Formatted Size' description='Human-readable file size')
        public String formattedSize;
        
        @InvocableVariable(label='Created Date' description='When file was uploaded')
        public DateTime createdDate;
        
        @InvocableVariable(label='Created By Name' description='Name of user who uploaded file')
        public String createdByName;
        
        @InvocableVariable(label='Last Modified Date' description='When file was last modified')
        public DateTime lastModifiedDate;
        
        @InvocableVariable(label='Download URL' description='URL to download file')
        public String downloadUrl;
        
        @InvocableVariable(label='View URL' description='URL to view file in Lightning')
        public String viewUrl;
    }
}
