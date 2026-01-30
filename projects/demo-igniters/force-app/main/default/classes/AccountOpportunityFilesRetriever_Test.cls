/**
 * Test class for AccountOpportunityFilesRetriever
 * 
 * @author Solution Engineering Team
 * @version 1.0
 */
@isTest
private class AccountOpportunityFilesRetriever_Test {
    
    /**
     * Setup test data
     */
    @testSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Acme Corporation'
        );
        insert testAccount;
        
        // Create Opportunities
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(
                Name = 'Enterprise Deal Q1',
                AccountId = testAccount.Id,
                StageName = 'Proposal/Price Quote',
                CloseDate = Date.today().addDays(30),
                Amount = 500000
            ),
            new Opportunity(
                Name = 'Renewal Deal',
                AccountId = testAccount.Id,
                StageName = 'Negotiation/Review',
                CloseDate = Date.today().addDays(45),
                Amount = 250000
            ),
            new Opportunity(
                Name = 'Expansion Deal',
                AccountId = testAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(60),
                Amount = 150000
            )
        };
        insert opps;
        
        // Create files for first opportunity
        ContentVersion cv1 = new ContentVersion(
            Title = 'MSA Contract',
            PathOnClient = 'MSA.pdf',
            VersionData = Blob.valueOf('MSA contract content'),
            IsMajorVersion = true
        );
        insert cv1;
        
        ContentVersion cv2 = new ContentVersion(
            Title = 'Statement of Work',
            PathOnClient = 'SOW.docx',
            VersionData = Blob.valueOf('SOW content'),
            IsMajorVersion = true
        );
        insert cv2;
        
        // Get ContentDocument IDs
        List<ContentVersion> insertedCVs = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id IN :new List<Id>{cv1.Id, cv2.Id}
        ];
        
        // Link files to first opportunity
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion cv : insertedCVs) {
            links.add(new ContentDocumentLink(
                LinkedEntityId = opps[0].Id,
                ContentDocumentId = cv.ContentDocumentId,
                ShareType = 'V'
            ));
        }
        
        // Create files for second opportunity
        ContentVersion cv3 = new ContentVersion(
            Title = 'Renewal Contract',
            PathOnClient = 'Renewal.pdf',
            VersionData = Blob.valueOf('Renewal contract content'),
            IsMajorVersion = true
        );
        insert cv3;
        
        ContentVersion insertedCV3 = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv3.Id
        ];
        
        links.add(new ContentDocumentLink(
            LinkedEntityId = opps[1].Id,
            ContentDocumentId = insertedCV3.ContentDocumentId,
            ShareType = 'V'
        ));
        
        // Create file for third opportunity
        ContentVersion cv4 = new ContentVersion(
            Title = 'Expansion Proposal',
            PathOnClient = 'Expansion.pdf',
            VersionData = Blob.valueOf('Expansion proposal content'),
            IsMajorVersion = true
        );
        insert cv4;
        
        ContentVersion insertedCV4 = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv4.Id
        ];
        
        links.add(new ContentDocumentLink(
            LinkedEntityId = opps[2].Id,
            ContentDocumentId = insertedCV4.ContentDocumentId,
            ShareType = 'V'
        ));
        
        insert links;
    }
    
    /**
     * Test retrieving files for all opportunities on an account
     */
    @isTest
    static void testGetAccountOpportunityFilesSuccess() {
        // Get test Account
        Account testAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Acme Corporation' 
            LIMIT 1
        ];
        
        // Create request
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = testAccount.Id;
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result');
        
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(3, result.opportunityCount, 'Should find 3 opportunities');
        System.assertEquals(4, result.totalFileCount, 'Should find 4 total files');
        System.assertNotEquals(null, result.filesByOpportunity, 'Files by opportunity should not be null');
        System.assertEquals(3, result.filesByOpportunity.size(), 'Should have 3 opportunities with files');
        System.assertNotEquals(null, result.aggregatedFileSummary, 'Aggregated summary should not be null');
        System.assert(result.totalSize > 0, 'Total size should be greater than 0');
    }
    
    /**
     * Test with file type filter
     */
    @isTest
    static void testGetAccountOpportunityFilesWithFilter() {
        // Get test Account
        Account testAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Acme Corporation' 
            LIMIT 1
        ];
        
        // Create request with PDF filter
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = testAccount.Id;
        request.fileTypes = 'pdf';
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(3, result.totalFileCount, 'Should find 3 PDF files');
        
        // Verify all files are PDFs
        for (AccountOpportunityFilesRetriever.OpportunityFiles oppFiles : result.filesByOpportunity) {
            for (OpportunityFileRetriever.FileDetail file : oppFiles.fileDetails) {
                System.assertEquals('pdf', file.fileExtension, 'All files should be PDF');
            }
        }
    }
    
    /**
     * Test with max files per opportunity limit
     */
    @isTest
    static void testGetAccountOpportunityFilesWithPerOppLimit() {
        // Get test Account
        Account testAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Acme Corporation' 
            LIMIT 1
        ];
        
        // Create request with per-opportunity limit
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = testAccount.Id;
        request.maxFilesPerOpportunity = 1;
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results - should have max 1 file per opportunity
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(3, result.totalFileCount, 'Should find 3 files total (1 per opp)');
        
        for (AccountOpportunityFilesRetriever.OpportunityFiles oppFiles : result.filesByOpportunity) {
            System.assert(oppFiles.fileCount <= 1, 'Each opportunity should have at most 1 file');
        }
    }
    
    /**
     * Test with max total files limit
     */
    @isTest
    static void testGetAccountOpportunityFilesWithTotalLimit() {
        // Get test Account
        Account testAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Acme Corporation' 
            LIMIT 1
        ];
        
        // Create request with total limit
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = testAccount.Id;
        request.maxTotalFiles = 2;
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assert(result.totalFileCount <= 2, 'Should find at most 2 files total');
    }
    
    /**
     * Test with Account that has no opportunities
     */
    @isTest
    static void testGetAccountOpportunityFilesNoOpportunities() {
        // Create Account without opportunities
        Account emptyAccount = new Account(Name = 'Empty Account');
        insert emptyAccount;
        
        // Create request
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = emptyAccount.Id;
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(0, result.opportunityCount, 'Should find 0 opportunities');
        System.assertEquals(0, result.totalFileCount, 'Should find 0 files');
        System.assertNotEquals(null, result.message, 'Should have a message');
    }
    
    /**
     * Test with invalid Account ID
     */
    @isTest
    static void testGetAccountOpportunityFilesInvalidId() {
        // Create request with non-existent Account ID
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = '001000000000000AAA'; // Invalid ID
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(false, result.success, 'Operation should fail');
        System.assertNotEquals(null, result.errorMessage, 'Should have error message');
    }
    
    /**
     * Test aggregated summary format
     */
    @isTest
    static void testAggregatedSummaryFormat() {
        // Get test Account
        Account testAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Acme Corporation' 
            LIMIT 1
        ];
        
        // Create request
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = testAccount.Id;
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify aggregated summary contains key information
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        String summary = result.aggregatedFileSummary;
        
        System.assert(summary.contains('Acme Corporation'), 'Summary should contain account name');
        System.assert(summary.contains('ACCOUNT-LEVEL'), 'Summary should have account-level header');
        System.assert(summary.contains('Total Opportunities'), 'Summary should mention total opportunities');
        System.assert(summary.contains('Total Contract Files'), 'Summary should mention total files');
    }
    
    /**
     * Test OpportunityFiles structure
     */
    @isTest
    static void testOpportunityFilesStructure() {
        // Get test Account
        Account testAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Acme Corporation' 
            LIMIT 1
        ];
        
        // Create request
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = testAccount.Id;
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify OpportunityFiles structure
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        for (AccountOpportunityFilesRetriever.OpportunityFiles oppFiles : result.filesByOpportunity) {
            System.assertNotEquals(null, oppFiles.opportunityId, 'Opportunity ID should not be null');
            System.assertNotEquals(null, oppFiles.opportunityName, 'Opportunity Name should not be null');
            System.assertNotEquals(null, oppFiles.opportunityStage, 'Opportunity Stage should not be null');
            System.assert(oppFiles.fileCount > 0, 'File count should be greater than 0');
            System.assertNotEquals(null, oppFiles.fileDetails, 'File details should not be null');
            System.assertEquals(oppFiles.fileCount, oppFiles.fileDetails.size(), 
                              'File count should match file details size');
        }
    }
    
    /**
     * Test file details properties
     */
    @isTest
    static void testFileDetailsProperties() {
        // Get test Account
        Account testAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Acme Corporation' 
            LIMIT 1
        ];
        
        // Create request
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = testAccount.Id;
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify file details have all required properties
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        for (AccountOpportunityFilesRetriever.OpportunityFiles oppFiles : result.filesByOpportunity) {
            for (OpportunityFileRetriever.FileDetail file : oppFiles.fileDetails) {
                System.assertNotEquals(null, file.documentId, 'Document ID should not be null');
                System.assertNotEquals(null, file.versionId, 'Version ID should not be null');
                System.assertNotEquals(null, file.title, 'Title should not be null');
                System.assertNotEquals(null, file.fileExtension, 'File extension should not be null');
                System.assertNotEquals(null, file.downloadUrl, 'Download URL should not be null');
                System.assertNotEquals(null, file.viewUrl, 'View URL should not be null');
                System.assertNotEquals(null, file.formattedSize, 'Formatted size should not be null');
            }
        }
    }
    
    /**
     * Test multiple file types filter
     */
    @isTest
    static void testMultipleFileTypesFilter() {
        // Get test Account
        Account testAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Acme Corporation' 
            LIMIT 1
        ];
        
        // Create request with multiple file types
        AccountOpportunityFilesRetriever.AccountFilesRequest request = 
            new AccountOpportunityFilesRetriever.AccountFilesRequest();
        request.accountId = testAccount.Id;
        request.fileTypes = 'pdf, docx';
        
        Test.startTest();
        List<AccountOpportunityFilesRetriever.AccountFilesResult> results = 
            AccountOpportunityFilesRetriever.getAccountOpportunityFiles(
                new List<AccountOpportunityFilesRetriever.AccountFilesRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        AccountOpportunityFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(4, result.totalFileCount, 'Should find all PDF and DOCX files');
    }
}

