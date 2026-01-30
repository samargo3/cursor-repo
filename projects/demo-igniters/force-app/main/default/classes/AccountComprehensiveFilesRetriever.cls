/**
 * AccountComprehensiveFilesRetriever
 * 
 * Invocable Apex action to retrieve ALL files for an Account:
 * 1. Files directly attached to the Account (CombinedAttachments)
 * 2. Files attached to all related Opportunities (ContentDocumentLink)
 * 
 * Use Cases:
 * - Complete document inventory for an account
 * - Comprehensive contract analysis (account + deal level)
 * - Full document compliance checking
 * - Complete AI-powered document analysis
 * 
 * @author Solution Engineering Team
 * @version 1.0
 */
public with sharing class AccountComprehensiveFilesRetriever {
    
    /**
     * Get All Account and Opportunity Files
     * Main invocable method to retrieve all files for an Account
     */
    @InvocableMethod(
        label='Get All Account and Opportunity Files' 
        description='Retrieves all files attached to an Account and its related Opportunities'
        category='Account Management'
    )
    public static List<ComprehensiveFilesResult> getAllAccountFiles(
        List<ComprehensiveFilesRequest> requests
    ) {
        List<ComprehensiveFilesResult> results = new List<ComprehensiveFilesResult>();
        
        for (ComprehensiveFilesRequest request : requests) {
            try {
                ComprehensiveFilesResult result = retrieveAllFiles(request);
                results.add(result);
            } catch (Exception e) {
                // Return error result
                ComprehensiveFilesResult errorResult = new ComprehensiveFilesResult();
                errorResult.success = false;
                errorResult.errorMessage = 'Error retrieving files: ' + e.getMessage();
                errorResult.accountId = request.accountId;
                results.add(errorResult);
            }
        }
        
        return results;
    }
    
    /**
     * Retrieve all files for an account (direct + opportunities)
     */
    private static ComprehensiveFilesResult retrieveAllFiles(
        ComprehensiveFilesRequest request
    ) {
        ComprehensiveFilesResult result = new ComprehensiveFilesResult();
        result.success = true;
        result.accountId = request.accountId;
        
        // Query Account with direct files and opportunities
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
                 ORDER BY CreatedDate DESC),
                (SELECT 
                    Id, 
                    Name, 
                    StageName, 
                    Amount, 
                    CloseDate
                 FROM Opportunities
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
        result.opportunityCount = acc.Opportunities != null ? acc.Opportunities.size() : 0;
        
        // Process direct account files
        List<FileDetail> accountFiles = processAccountFiles(
            acc.CombinedAttachments, 
            request.fileTypes,
            request.maxAccountFiles
        );
        result.accountFileCount = accountFiles.size();
        result.accountFiles = accountFiles;
        
        // Calculate account files total size
        result.accountFilesTotalSize = 0;
        for (FileDetail file : accountFiles) {
            result.accountFilesTotalSize += file.contentSize;
        }
        result.formattedAccountFilesSize = formatFileSize(result.accountFilesTotalSize);
        
        // Process opportunity files
        result.opportunityFiles = new List<OpportunityFileGroup>();
        result.opportunityFileCount = 0;
        result.opportunityFilesTotalSize = 0;
        
        if (acc.Opportunities != null && !acc.Opportunities.isEmpty()) {
            // Get all opportunity IDs
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity opp : acc.Opportunities) {
                oppIds.add(opp.Id);
            }
            
            // Query files for all opportunities
            Map<Id, List<ContentDocumentLink>> oppFilesMap = getOpportunityFiles(
                oppIds, 
                request.fileTypes,
                request.maxFilesPerOpportunity
            );
            
            // Build opportunity file groups
            for (Opportunity opp : acc.Opportunities) {
                List<ContentDocumentLink> links = oppFilesMap.get(opp.Id);
                if (links != null && !links.isEmpty()) {
                    OpportunityFileGroup fileGroup = new OpportunityFileGroup();
                    fileGroup.opportunityId = opp.Id;
                    fileGroup.opportunityName = opp.Name;
                    fileGroup.opportunityStage = opp.StageName;
                    fileGroup.opportunityAmount = opp.Amount;
                    fileGroup.fileCount = links.size();
                    fileGroup.files = new List<FileDetail>();
                    
                    Long groupSize = 0;
                    for (ContentDocumentLink link : links) {
                        FileDetail detail = buildFileDetail(link.ContentDocument);
                        detail.sourceOpportunityId = opp.Id;
                        detail.sourceOpportunityName = opp.Name;
                        fileGroup.files.add(detail);
                        groupSize += detail.contentSize;
                        result.opportunityFileCount++;
                    }
                    
                    fileGroup.totalSize = groupSize;
                    fileGroup.formattedTotalSize = formatFileSize(groupSize);
                    result.opportunityFilesTotalSize += groupSize;
                    result.opportunityFiles.add(fileGroup);
                }
            }
        }
        
        result.formattedOpportunityFilesSize = formatFileSize(result.opportunityFilesTotalSize);
        
        // Calculate totals
        result.totalFileCount = result.accountFileCount + result.opportunityFileCount;
        result.totalSize = result.accountFilesTotalSize + result.opportunityFilesTotalSize;
        result.formattedTotalSize = formatFileSize(result.totalSize);
        
        // Build comprehensive summary
        result.comprehensiveSummary = buildComprehensiveSummary(result);
        result.message = 'Found ' + result.totalFileCount + ' file(s): ' + 
                        result.accountFileCount + ' account-level, ' + 
                        result.opportunityFileCount + ' from ' + 
                        result.opportunityFiles.size() + ' opportunity(ies)';
        
        return result;
    }
    
    /**
     * Process direct account files
     */
    private static List<FileDetail> processAccountFiles(
        List<CombinedAttachment> attachments,
        String fileTypesFilter,
        Integer maxFiles
    ) {
        List<FileDetail> files = new List<FileDetail>();
        
        if (attachments == null || attachments.isEmpty()) {
            return files;
        }
        
        // Apply file type filter
        List<CombinedAttachment> filtered = attachments;
        if (String.isNotBlank(fileTypesFilter)) {
            List<String> allowedTypes = new List<String>();
            for (String type : fileTypesFilter.split(',')) {
                allowedTypes.add(type.trim().toLowerCase());
            }
            
            filtered = new List<CombinedAttachment>();
            for (CombinedAttachment att : attachments) {
                if (String.isNotBlank(att.FileExtension) && 
                    allowedTypes.contains(att.FileExtension.toLowerCase())) {
                    filtered.add(att);
                }
            }
        }
        
        // Apply max files limit
        Integer count = 0;
        for (CombinedAttachment att : filtered) {
            if (maxFiles != null && maxFiles > 0 && count >= maxFiles) {
                break;
            }
            
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
            detail.source = 'Account';
            
            files.add(detail);
            count++;
        }
        
        return files;
    }
    
    /**
     * Get files for all opportunities
     */
    private static Map<Id, List<ContentDocumentLink>> getOpportunityFiles(
        Set<Id> oppIds,
        String fileTypesFilter,
        Integer maxFilesPerOpp
    ) {
        Map<Id, List<ContentDocumentLink>> filesMap = new Map<Id, List<ContentDocumentLink>>();
        
        // Build WHERE clause for file types
        String whereClause = 'LinkedEntityId IN :oppIds';
        if (String.isNotBlank(fileTypesFilter)) {
            List<String> types = fileTypesFilter.split(',');
            List<String> trimmedTypes = new List<String>();
            for (String type : types) {
                trimmedTypes.add('\'' + String.escapeSingleQuotes(type.trim()) + '\'');
            }
            whereClause += ' AND ContentDocument.FileExtension IN (' + String.join(trimmedTypes, ',') + ')';
        }
        
        String queryString = 
            'SELECT ContentDocument.Id, ContentDocument.Title, ' +
            'ContentDocument.FileExtension, ContentDocument.ContentSize, ' +
            'ContentDocument.CreatedDate, ContentDocument.CreatedBy.Name, ' +
            'ContentDocument.LatestPublishedVersionId, LinkedEntityId ' +
            'FROM ContentDocumentLink ' +
            'WHERE ' + whereClause + ' ' +
            'ORDER BY ContentDocument.CreatedDate DESC';
        
        List<ContentDocumentLink> allLinks = Database.query(queryString);
        
        // Group by opportunity
        for (ContentDocumentLink link : allLinks) {
            Id oppId = link.LinkedEntityId;
            if (!filesMap.containsKey(oppId)) {
                filesMap.put(oppId, new List<ContentDocumentLink>());
            }
            
            List<ContentDocumentLink> oppFiles = filesMap.get(oppId);
            
            // Apply per-opportunity limit
            if (maxFilesPerOpp == null || maxFilesPerOpp <= 0 || 
                oppFiles.size() < maxFilesPerOpp) {
                oppFiles.add(link);
            }
        }
        
        return filesMap;
    }
    
    /**
     * Build file detail from ContentDocument
     */
    private static FileDetail buildFileDetail(ContentDocument doc) {
        FileDetail detail = new FileDetail();
        detail.fileId = doc.Id;
        detail.title = doc.Title;
        detail.fileExtension = doc.FileExtension != null ? doc.FileExtension : 'unknown';
        detail.contentSize = doc.ContentSize != null ? doc.ContentSize : 0;
        detail.formattedSize = formatFileSize(detail.contentSize);
        detail.createdDate = doc.CreatedDate;
        detail.createdByName = doc.CreatedBy.Name;
        detail.downloadUrl = '/sfc/servlet.shepherd/version/download/' + doc.LatestPublishedVersionId;
        detail.viewUrl = '/lightning/r/ContentDocument/' + doc.Id + '/view';
        detail.source = 'Opportunity';
        return detail;
    }
    
    /**
     * Build comprehensive summary for AI/display
     */
    private static String buildComprehensiveSummary(ComprehensiveFilesResult result) {
        String summary = 'COMPREHENSIVE ACCOUNT FILE ANALYSIS\n';
        summary += '==================================================\n\n';
        summary += 'Account: ' + result.accountName + '\n';
        summary += 'Total Files: ' + result.totalFileCount + '\n';
        summary += 'Total Size: ' + result.formattedTotalSize + '\n\n';
        
        // Account-level files section
        summary += '==================================================\n';
        summary += 'ACCOUNT-LEVEL FILES: ' + result.accountFileCount + ' (' + 
                  result.formattedAccountFilesSize + ')\n';
        summary += '==================================================\n\n';
        
        if (result.accountFiles.isEmpty()) {
            summary += 'No files directly attached to account.\n\n';
        } else {
            Integer index = 1;
            for (FileDetail file : result.accountFiles) {
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
                summary += '\n\n';
                index++;
            }
        }
        
        // Opportunity files section
        summary += '==================================================\n';
        summary += 'OPPORTUNITY FILES: ' + result.opportunityFileCount + 
                  ' from ' + result.opportunityFiles.size() + ' opportunity(ies) (' + 
                  result.formattedOpportunityFilesSize + ')\n';
        summary += '==================================================\n\n';
        
        if (result.opportunityFiles.isEmpty()) {
            summary += 'No files attached to opportunities.\n\n';
        } else {
            for (OpportunityFileGroup fileGroup : result.opportunityFiles) {
                summary += 'OPPORTUNITY: ' + fileGroup.opportunityName + '\n';
                summary += 'Stage: ' + fileGroup.opportunityStage;
                if (fileGroup.opportunityAmount != null) {
                    summary += ' | Amount: $' + fileGroup.opportunityAmount.format();
                }
                summary += '\n';
                summary += 'Files: ' + fileGroup.fileCount + ' (' + fileGroup.formattedTotalSize + ')\n';
                summary += '----------------------------------------\n';
                
                Integer index = 1;
                for (FileDetail file : fileGroup.files) {
                    summary += '  ' + index + '. ' + file.title;
                    if (String.isNotBlank(file.fileExtension)) {
                        summary += '.' + file.fileExtension;
                    }
                    summary += '\n';
                    summary += '     Type: ' + file.fileExtension.toUpperCase() + 
                              ' | Size: ' + file.formattedSize;
                    if (file.createdDate != null) {
                        summary += ' | Uploaded: ' + file.createdDate.format('yyyy-MM-dd');
                    }
                    summary += '\n';
                    index++;
                }
                summary += '\n';
            }
        }
        
        return summary;
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
     * Input request
     */
    public class ComprehensiveFilesRequest {
        @InvocableVariable(
            label='Account ID' 
            description='ID of the Account to retrieve all files from'
            required=true
        )
        public Id accountId;
        
        @InvocableVariable(
            label='File Types Filter' 
            description='Comma-separated list of file extensions (e.g., pdf,docx). Leave blank for all types.'
            required=false
        )
        public String fileTypes;
        
        @InvocableVariable(
            label='Max Account Files' 
            description='Maximum number of account-level files to return'
            required=false
        )
        public Integer maxAccountFiles;
        
        @InvocableVariable(
            label='Max Files Per Opportunity' 
            description='Maximum number of files per opportunity'
            required=false
        )
        public Integer maxFilesPerOpportunity;
    }
    
    /**
     * Result of comprehensive file retrieval
     */
    public class ComprehensiveFilesResult {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String errorMessage;
        @InvocableVariable public Id accountId;
        @InvocableVariable public String accountName;
        
        // Account-level files
        @InvocableVariable public Integer accountFileCount;
        @InvocableVariable public Long accountFilesTotalSize;
        @InvocableVariable public String formattedAccountFilesSize;
        @InvocableVariable public List<FileDetail> accountFiles;
        
        // Opportunity files
        @InvocableVariable public Integer opportunityCount;
        @InvocableVariable public Integer opportunityFileCount;
        @InvocableVariable public Long opportunityFilesTotalSize;
        @InvocableVariable public String formattedOpportunityFilesSize;
        @InvocableVariable public List<OpportunityFileGroup> opportunityFiles;
        
        // Totals
        @InvocableVariable public Integer totalFileCount;
        @InvocableVariable public Long totalSize;
        @InvocableVariable public String formattedTotalSize;
        
        // Summary
        @InvocableVariable public String comprehensiveSummary;
        @InvocableVariable public String message;
    }
    
    /**
     * Opportunity file group
     */
    public class OpportunityFileGroup {
        @InvocableVariable public Id opportunityId;
        @InvocableVariable public String opportunityName;
        @InvocableVariable public String opportunityStage;
        @InvocableVariable public Decimal opportunityAmount;
        @InvocableVariable public Integer fileCount;
        @InvocableVariable public Long totalSize;
        @InvocableVariable public String formattedTotalSize;
        @InvocableVariable public List<FileDetail> files;
    }
    
    /**
     * File detail information
     */
    public class FileDetail {
        @InvocableVariable public Id fileId;
        @InvocableVariable public String title;
        @InvocableVariable public String fileExtension;
        @InvocableVariable public Long contentSize;
        @InvocableVariable public String formattedSize;
        @InvocableVariable public DateTime createdDate;
        @InvocableVariable public String createdByName;
        @InvocableVariable public DateTime lastModifiedDate;
        @InvocableVariable public String downloadUrl;
        @InvocableVariable public String viewUrl;
        @InvocableVariable public String source; // 'Account' or 'Opportunity'
        @InvocableVariable public Id sourceOpportunityId;
        @InvocableVariable public String sourceOpportunityName;
    }
}
