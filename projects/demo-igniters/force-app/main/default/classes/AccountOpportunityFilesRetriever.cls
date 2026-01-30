/**
 * AccountOpportunityFilesRetriever
 * 
 * Invocable Apex class to retrieve files attached to all Opportunities
 * for a given Account. Designed for account-level contract analysis.
 * 
 * Use Cases:
 * - Analyze all contracts across account opportunities
 * - Account-level document compliance checking
 * - Cross-opportunity contract comparison
 * - AI-powered account contract analysis
 * 
 * @author Solution Engineering Team
 * @version 1.0
 */
public with sharing class AccountOpportunityFilesRetriever {
    
    /**
     * Get Account Opportunity Files
     * Main invocable method to retrieve files from all Opportunities for an Account
     */
    @InvocableMethod(
        label='Get Account Opportunity Files' 
        description='Retrieves all files attached to Opportunities for a given Account'
        category='Account Management'
    )
    public static List<AccountFilesResult> getAccountOpportunityFiles(
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
     * Retrieve files for all opportunities on an account
     */
    private static AccountFilesResult retrieveFilesForAccount(
        AccountFilesRequest request
    ) {
        AccountFilesResult result = new AccountFilesResult();
        result.success = true;
        result.accountId = request.accountId;
        
        // Validate Account exists
        List<Account> accounts = [
            SELECT Id, Name 
            FROM Account 
            WHERE Id = :request.accountId 
            LIMIT 1
        ];
        
        if (accounts.isEmpty()) {
            result.success = false;
            result.errorMessage = 'Account not found';
            return result;
        }
        
        result.accountName = accounts[0].Name;
        
        // Get all Opportunities for this Account
        List<Opportunity> opportunities = [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity 
            WHERE AccountId = :request.accountId
            ORDER BY CreatedDate DESC
        ];
        
        if (opportunities.isEmpty()) {
            result.success = true;
            result.opportunityCount = 0;
            result.totalFileCount = 0;
            result.message = 'No opportunities found for this Account';
            result.filesByOpportunity = new List<OpportunityFiles>();
            result.aggregatedFileSummary = 'No opportunities found for Account: ' + result.accountName;
            return result;
        }
        
        result.opportunityCount = opportunities.size();
        
        // Build file type filter for SOQL
        String fileTypeFilter = '';
        if (String.isNotBlank(request.fileTypes)) {
            List<String> types = request.fileTypes.split(',');
            List<String> trimmedTypes = new List<String>();
            for (String type : types) {
                trimmedTypes.add('\'' + type.trim().toLowerCase() + '\'');
            }
            fileTypeFilter = ' AND ContentDocument.FileExtension IN (' + 
                           String.join(trimmedTypes, ',') + ')';
        }
        
        // Get all Opportunity IDs
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opp : opportunities) {
            opportunityIds.add(opp.Id);
        }
        
        // Query all files linked to these Opportunities in one go
        String query = 
            'SELECT ' +
            '    LinkedEntityId, ' +
            '    ContentDocument.Id, ' +
            '    ContentDocument.Title, ' +
            '    ContentDocument.FileExtension, ' +
            '    ContentDocument.FileType, ' +
            '    ContentDocument.ContentSize, ' +
            '    ContentDocument.CreatedDate, ' +
            '    ContentDocument.CreatedBy.Name, ' +
            '    ContentDocument.LatestPublishedVersionId ' +
            'FROM ContentDocumentLink ' +
            'WHERE LinkedEntityId IN :opportunityIds' + 
            fileTypeFilter +
            ' ORDER BY LinkedEntityId, ContentDocument.CreatedDate DESC';
        
        List<ContentDocumentLink> allDocLinks = Database.query(query);
        
        if (allDocLinks.isEmpty()) {
            result.success = true;
            result.totalFileCount = 0;
            result.message = 'No files found attached to opportunities for this Account';
            result.filesByOpportunity = new List<OpportunityFiles>();
            result.aggregatedFileSummary = buildEmptyAccountSummary(result.accountName, opportunities.size());
            return result;
        }
        
        // Group files by Opportunity
        Map<Id, List<ContentDocumentLink>> filesByOppId = new Map<Id, List<ContentDocumentLink>>();
        for (ContentDocumentLink link : allDocLinks) {
            Id oppId = link.LinkedEntityId;
            if (!filesByOppId.containsKey(oppId)) {
                filesByOppId.put(oppId, new List<ContentDocumentLink>());
            }
            filesByOppId.get(oppId).add(link);
        }
        
        // Build OpportunityFiles for each opportunity
        List<OpportunityFiles> opportunityFilesList = new List<OpportunityFiles>();
        Integer totalFiles = 0;
        Decimal totalSize = 0;
        Integer filesProcessed = 0;
        
        for (Opportunity opp : opportunities) {
            // Check if we've hit max total files limit
            if (request.maxTotalFiles != null && 
                request.maxTotalFiles > 0 && 
                filesProcessed >= request.maxTotalFiles) {
                break;
            }
            
            if (!filesByOppId.containsKey(opp.Id)) {
                // Opportunity has no files - skip or include based on preference
                continue;
            }
            
            List<ContentDocumentLink> oppDocLinks = filesByOppId.get(opp.Id);
            
            // Apply per-opportunity limit
            if (request.maxFilesPerOpportunity != null && 
                request.maxFilesPerOpportunity > 0 && 
                oppDocLinks.size() > request.maxFilesPerOpportunity) {
                oppDocLinks = new List<ContentDocumentLink>();
                for (Integer i = 0; i < request.maxFilesPerOpportunity; i++) {
                    oppDocLinks.add(filesByOppId.get(opp.Id)[i]);
                }
            }
            
            OpportunityFiles oppFiles = buildOpportunityFiles(opp, oppDocLinks);
            opportunityFilesList.add(oppFiles);
            
            totalFiles += oppFiles.fileCount;
            totalSize += oppFiles.totalSize;
            filesProcessed += oppFiles.fileCount;
            
            // Check if we've hit max total files limit
            if (request.maxTotalFiles != null && 
                request.maxTotalFiles > 0 && 
                filesProcessed >= request.maxTotalFiles) {
                break;
            }
        }
        
        // Set result properties
        result.filesByOpportunity = opportunityFilesList;
        result.totalFileCount = totalFiles;
        result.totalSize = totalSize;
        result.formattedTotalSize = formatFileSize(totalSize);
        
        // Build aggregated summary for AI
        result.aggregatedFileSummary = buildAggregatedSummary(
            result.accountName,
            opportunities.size(),
            totalFiles,
            result.formattedTotalSize,
            opportunityFilesList
        );
        
        // Success message
        result.message = 'Found ' + totalFiles + ' file' + 
                        (totalFiles == 1 ? '' : 's') + 
                        ' across ' + opportunityFilesList.size() + 
                        ' opportunit' + (opportunityFilesList.size() == 1 ? 'y' : 'ies') +
                        ' for ' + result.accountName;
        
        return result;
    }
    
    /**
     * Build OpportunityFiles object for a single opportunity
     */
    private static OpportunityFiles buildOpportunityFiles(
        Opportunity opp,
        List<ContentDocumentLink> docLinks
    ) {
        OpportunityFiles oppFiles = new OpportunityFiles();
        oppFiles.opportunityId = opp.Id;
        oppFiles.opportunityName = opp.Name;
        oppFiles.opportunityStage = opp.StageName;
        oppFiles.opportunityAmount = opp.Amount;
        oppFiles.fileCount = docLinks.size();
        
        List<OpportunityFileRetriever.FileDetail> fileDetails = new List<OpportunityFileRetriever.FileDetail>();
        Decimal totalSize = 0;
        
        for (ContentDocumentLink link : docLinks) {
            OpportunityFileRetriever.FileDetail detail = new OpportunityFileRetriever.FileDetail();
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
            detail.formattedSize = formatFileSize(link.ContentDocument.ContentSize);
            
            fileDetails.add(detail);
            totalSize += link.ContentDocument.ContentSize;
        }
        
        oppFiles.fileDetails = fileDetails;
        oppFiles.totalSize = totalSize;
        oppFiles.formattedTotalSize = formatFileSize(totalSize);
        
        // Build summary for this opportunity
        oppFiles.fileSummary = buildOpportunitySummary(opp, fileDetails);
        
        return oppFiles;
    }
    
    /**
     * Build summary for a single opportunity's files
     */
    private static String buildOpportunitySummary(
        Opportunity opp,
        List<OpportunityFileRetriever.FileDetail> files
    ) {
        String summary = 'Files for Opportunity: ' + opp.Name + '\n';
        summary += 'Stage: ' + opp.StageName + '\n';
        if (opp.Amount != null) {
            summary += 'Amount: $' + String.valueOf(opp.Amount.format()) + '\n';
        }
        summary += 'File Count: ' + files.size() + '\n\n';
        
        Integer counter = 1;
        for (OpportunityFileRetriever.FileDetail file : files) {
            summary += '  ' + counter + '. ' + file.title + 
                      ' (.' + file.fileExtension + ', ' + file.formattedSize + ')\n';
            counter++;
        }
        
        return summary;
    }
    
    /**
     * Build aggregated summary across all opportunities
     */
    private static String buildAggregatedSummary(
        String accountName,
        Integer totalOpportunities,
        Integer totalFiles,
        String formattedTotalSize,
        List<OpportunityFiles> opportunityFilesList
    ) {
        String summary = 'ACCOUNT-LEVEL CONTRACT ANALYSIS\n';
        summary += '=' .repeat(50) + '\n\n';
        summary += 'Account: ' + accountName + '\n';
        summary += 'Total Opportunities: ' + totalOpportunities + '\n';
        summary += 'Opportunities with Files: ' + opportunityFilesList.size() + '\n';
        summary += 'Total Contract Files: ' + totalFiles + '\n';
        summary += 'Total Size: ' + formattedTotalSize + '\n\n';
        summary += '=' .repeat(50) + '\n\n';
        
        Integer oppCounter = 1;
        for (OpportunityFiles oppFiles : opportunityFilesList) {
            summary += 'OPPORTUNITY ' + oppCounter + ': ' + oppFiles.opportunityName + '\n';
            summary += 'Stage: ' + oppFiles.opportunityStage + '\n';
            if (oppFiles.opportunityAmount != null) {
                summary += 'Amount: $' + String.valueOf(oppFiles.opportunityAmount.format()) + '\n';
            }
            summary += 'Files: ' + oppFiles.fileCount + ' (' + oppFiles.formattedTotalSize + ')\n';
            summary += '-' .repeat(40) + '\n';
            
            Integer fileCounter = 1;
            for (OpportunityFileRetriever.FileDetail file : oppFiles.fileDetails) {
                summary += '  ' + fileCounter + '. ' + file.title + '\n';
                summary += '     Type: ' + file.fileExtension.toUpperCase() + 
                          ' | Size: ' + file.formattedSize + 
                          ' | Uploaded: ' + file.createdDate.format() + '\n';
                fileCounter++;
            }
            summary += '\n';
            oppCounter++;
        }
        
        return summary;
    }
    
    /**
     * Build empty summary when no files found
     */
    private static String buildEmptyAccountSummary(String accountName, Integer opportunityCount) {
        String summary = 'ACCOUNT-LEVEL CONTRACT ANALYSIS\n';
        summary += '=' .repeat(50) + '\n\n';
        summary += 'Account: ' + accountName + '\n';
        summary += 'Total Opportunities: ' + opportunityCount + '\n';
        summary += 'Total Contract Files: 0\n\n';
        summary += 'No files found attached to opportunities for this account.\n';
        return summary;
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
    
    // ========================================================================
    // INNER CLASSES
    // ========================================================================
    
    /**
     * Input request for account files retrieval
     */
    public class AccountFilesRequest {
        @InvocableVariable(
            label='Account ID' 
            description='ID of the Account to retrieve opportunity files from'
            required=true
        )
        public Id accountId;
        
        @InvocableVariable(
            label='File Types Filter' 
            description='Comma-separated file extensions (e.g., pdf,docx). Leave blank for all types.'
            required=false
        )
        public String fileTypes;
        
        @InvocableVariable(
            label='Max Files Per Opportunity' 
            description='Maximum files to retrieve per opportunity. Leave blank for all.'
            required=false
        )
        public Integer maxFilesPerOpportunity;
        
        @InvocableVariable(
            label='Max Total Files' 
            description='Maximum total files across all opportunities. Leave blank for all.'
            required=false
        )
        public Integer maxTotalFiles;
    }
    
    /**
     * Result of account files retrieval
     */
    public class AccountFilesResult {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean success;
        
        @InvocableVariable(label='Error Message' description='Error message if operation failed')
        public String errorMessage;
        
        @InvocableVariable(label='Account ID' description='ID of the Account')
        public Id accountId;
        
        @InvocableVariable(label='Account Name' description='Name of the Account')
        public String accountName;
        
        @InvocableVariable(label='Opportunity Count' description='Total number of opportunities')
        public Integer opportunityCount;
        
        @InvocableVariable(label='Total File Count' description='Total number of files across all opportunities')
        public Integer totalFileCount;
        
        @InvocableVariable(label='Total Size' description='Total size of all files in bytes')
        public Decimal totalSize;
        
        @InvocableVariable(label='Formatted Total Size' description='Total size formatted for display')
        public String formattedTotalSize;
        
        @InvocableVariable(label='Aggregated File Summary' description='Complete summary for AI/Prompt context')
        public String aggregatedFileSummary;
        
        @InvocableVariable(label='Message' description='Result message')
        public String message;
        
        @InvocableVariable(label='Files By Opportunity' description='Collection of files grouped by opportunity')
        public List<OpportunityFiles> filesByOpportunity;
    }
    
    /**
     * Files for a single opportunity
     */
    public class OpportunityFiles {
        @InvocableVariable(label='Opportunity ID' description='ID of the Opportunity')
        public Id opportunityId;
        
        @InvocableVariable(label='Opportunity Name' description='Name of the Opportunity')
        public String opportunityName;
        
        @InvocableVariable(label='Opportunity Stage' description='Stage of the Opportunity')
        public String opportunityStage;
        
        @InvocableVariable(label='Opportunity Amount' description='Amount of the Opportunity')
        public Decimal opportunityAmount;
        
        @InvocableVariable(label='File Count' description='Number of files for this opportunity')
        public Integer fileCount;
        
        @InvocableVariable(label='Total Size' description='Total size of files for this opportunity')
        public Decimal totalSize;
        
        @InvocableVariable(label='Formatted Total Size' description='Formatted size for this opportunity')
        public String formattedTotalSize;
        
        @InvocableVariable(label='File Summary' description='Summary of files for this opportunity')
        public String fileSummary;
        
        @InvocableVariable(label='File Details' description='List of file details')
        public List<OpportunityFileRetriever.FileDetail> fileDetails;
    }
}

