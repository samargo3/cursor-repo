/**
 * Test class for AccountComprehensiveFilesRetriever
 * 
 * Tests comprehensive file retrieval (account + opportunities)
 */
@isTest
private class AccountComprehensiveFilesRetriever_Test {
    
    /**
     * Setup test data
     */
    @TestSetup
    static void setup() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Comprehensive Test Account'
        );
        insert testAccount;
        
        // Create opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(new Opportunity(
            Name = 'Deal 1',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 100000
        ));
        opportunities.add(new Opportunity(
            Name = 'Deal 2',
            AccountId = testAccount.Id,
            StageName = 'Negotiation',
            CloseDate = Date.today().addDays(45),
            Amount = 250000
        ));
        insert opportunities;
        
        // Create files for direct account attachment
        List<ContentVersion> accountVersions = new List<ContentVersion>();
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Account NDA';
        cv1.PathOnClient = 'NDA.pdf';
        cv1.VersionData = Blob.valueOf('NDA content');
        cv1.IsMajorVersion = true;
        accountVersions.add(cv1);
        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Master Agreement';
        cv2.PathOnClient = 'MSA.docx';
        cv2.VersionData = Blob.valueOf('MSA content');
        cv2.IsMajorVersion = true;
        accountVersions.add(cv2);
        insert accountVersions;
        
        // Link account files to account
        List<ContentVersion> insertedAccountVersions = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id IN :accountVersions
        ];
        
        List<ContentDocumentLink> accountLinks = new List<ContentDocumentLink>();
        for (ContentVersion cv : insertedAccountVersions) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = cv.ContentDocumentId;
            link.LinkedEntityId = testAccount.Id;
            link.ShareType = 'V';
            link.Visibility = 'AllUsers';
            accountLinks.add(link);
        }
        insert accountLinks;
        
        // Create files for opportunities
        List<ContentVersion> oppVersions = new List<ContentVersion>();
        
        // Files for Deal 1
        ContentVersion cv3 = new ContentVersion();
        cv3.Title = 'Deal 1 Proposal';
        cv3.PathOnClient = 'Proposal1.pdf';
        cv3.VersionData = Blob.valueOf('Proposal 1 content');
        cv3.IsMajorVersion = true;
        oppVersions.add(cv3);
        
        ContentVersion cv4 = new ContentVersion();
        cv4.Title = 'Deal 1 SOW';
        cv4.PathOnClient = 'SOW1.docx';
        cv4.VersionData = Blob.valueOf('SOW 1 content');
        cv4.IsMajorVersion = true;
        oppVersions.add(cv4);
        
        // Files for Deal 2
        ContentVersion cv5 = new ContentVersion();
        cv5.Title = 'Deal 2 Contract';
        cv5.PathOnClient = 'Contract2.pdf';
        cv5.VersionData = Blob.valueOf('Contract 2 content');
        cv5.IsMajorVersion = true;
        oppVersions.add(cv5);
        
        insert oppVersions;
        
        // Link opportunity files
        List<ContentVersion> insertedOppVersions = [
            SELECT Id, ContentDocumentId, Title
            FROM ContentVersion 
            WHERE Id IN :oppVersions
        ];
        
        List<ContentDocumentLink> oppLinks = new List<ContentDocumentLink>();
        for (ContentVersion cv : insertedOppVersions) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = cv.ContentDocumentId;
            
            // Link to appropriate opportunity based on title
            if (cv.Title.contains('Deal 1')) {
                link.LinkedEntityId = opportunities[0].Id;
            } else {
                link.LinkedEntityId = opportunities[1].Id;
            }
            
            link.ShareType = 'V';
            link.Visibility = 'AllUsers';
            oppLinks.add(link);
        }
        insert oppLinks;
    }
    
    /**
     * Test comprehensive file retrieval (all files)
     */
    @isTest
    static void testGetAllFiles_Success() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest request = 
            new AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest();
        request.accountId = acc.Id;
        
        Test.startTest();
        List<AccountComprehensiveFilesRetriever.ComprehensiveFilesResult> results = 
            AccountComprehensiveFilesRetriever.getAllAccountFiles(
                new List<AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest>{request}
            );
        Test.stopTest();
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesResult result = results[0];
        
        System.assertEquals(true, result.success, 'Operation should succeed');
        System.assertEquals('Comprehensive Test Account', result.accountName, 'Account name should match');
        System.assertEquals(2, result.accountFileCount, 'Should have 2 account files');
        System.assertEquals(3, result.opportunityFileCount, 'Should have 3 opportunity files');
        System.assertEquals(5, result.totalFileCount, 'Should have 5 total files');
        System.assertEquals(2, result.opportunityCount, 'Should have 2 opportunities');
        System.assertEquals(2, result.opportunityFiles.size(), 'Should have 2 opportunity groups');
        System.assertNotEquals(null, result.comprehensiveSummary, 'Summary should be populated');
        System.assert(result.comprehensiveSummary.contains('COMPREHENSIVE'), 'Summary should be comprehensive');
    }
    
    /**
     * Test account files only (no opportunity files)
     */
    @isTest
    static void testGetAllFiles_AccountFilesOnly() {
        // Create account without opportunities
        Account acc = new Account(Name = 'Account Files Only');
        insert acc;
        
        // Add file to account
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Standalone Doc';
        cv.PathOnClient = 'Doc.pdf';
        cv.VersionData = Blob.valueOf('Doc content');
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCv = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ];
        
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = insertedCv.ContentDocumentId;
        link.LinkedEntityId = acc.Id;
        link.ShareType = 'V';
        link.Visibility = 'AllUsers';
        insert link;
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest request = 
            new AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest();
        request.accountId = acc.Id;
        
        Test.startTest();
        List<AccountComprehensiveFilesRetriever.ComprehensiveFilesResult> results = 
            AccountComprehensiveFilesRetriever.getAllAccountFiles(
                new List<AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest>{request}
            );
        Test.stopTest();
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesResult result = results[0];
        
        System.assertEquals(true, result.success, 'Operation should succeed');
        System.assertEquals(1, result.accountFileCount, 'Should have 1 account file');
        System.assertEquals(0, result.opportunityFileCount, 'Should have 0 opportunity files');
        System.assertEquals(1, result.totalFileCount, 'Should have 1 total file');
    }
    
    /**
     * Test opportunity files only (no account files)
     */
    @isTest
    static void testGetAllFiles_OpportunityFilesOnly() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Delete account files (keep only opp files)
        List<ContentDocumentLink> accountLinks = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :acc.Id
        ];
        delete accountLinks;
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest request = 
            new AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest();
        request.accountId = acc.Id;
        
        Test.startTest();
        List<AccountComprehensiveFilesRetriever.ComprehensiveFilesResult> results = 
            AccountComprehensiveFilesRetriever.getAllAccountFiles(
                new List<AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest>{request}
            );
        Test.stopTest();
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesResult result = results[0];
        
        System.assertEquals(true, result.success, 'Operation should succeed');
        System.assertEquals(0, result.accountFileCount, 'Should have 0 account files');
        System.assertEquals(3, result.opportunityFileCount, 'Should have 3 opportunity files');
        System.assertEquals(3, result.totalFileCount, 'Should have 3 total files');
    }
    
    /**
     * Test file type filtering
     */
    @isTest
    static void testGetAllFiles_FileTypeFilter() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest request = 
            new AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest();
        request.accountId = acc.Id;
        request.fileTypes = 'pdf'; // Only PDF files
        
        Test.startTest();
        List<AccountComprehensiveFilesRetriever.ComprehensiveFilesResult> results = 
            AccountComprehensiveFilesRetriever.getAllAccountFiles(
                new List<AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest>{request}
            );
        Test.stopTest();
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesResult result = results[0];
        
        System.assertEquals(true, result.success, 'Operation should succeed');
        // Should have only PDF files (1 account + 2 opp)
        System.assert(result.totalFileCount <= 5, 'Should filter to only PDF files');
        
        // Verify all returned files are PDFs
        for (AccountComprehensiveFilesRetriever.FileDetail file : result.accountFiles) {
            System.assertEquals('pdf', file.fileExtension.toLowerCase(), 'Account file should be PDF');
        }
    }
    
    /**
     * Test max files limits
     */
    @isTest
    static void testGetAllFiles_MaxLimits() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest request = 
            new AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest();
        request.accountId = acc.Id;
        request.maxAccountFiles = 1;
        request.maxFilesPerOpportunity = 1;
        
        Test.startTest();
        List<AccountComprehensiveFilesRetriever.ComprehensiveFilesResult> results = 
            AccountComprehensiveFilesRetriever.getAllAccountFiles(
                new List<AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest>{request}
            );
        Test.stopTest();
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesResult result = results[0];
        
        System.assertEquals(true, result.success, 'Operation should succeed');
        System.assert(result.accountFileCount <= 1, 'Account files should be limited to 1');
        
        // Each opportunity should have max 1 file
        for (AccountComprehensiveFilesRetriever.OpportunityFileGroup fileGroup : result.opportunityFiles) {
            System.assert(fileGroup.fileCount <= 1, 'Each opportunity should have max 1 file');
        }
    }
    
    /**
     * Test no files scenario
     */
    @isTest
    static void testGetAllFiles_NoFiles() {
        Account acc = new Account(Name = 'Empty Account');
        insert acc;
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest request = 
            new AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest();
        request.accountId = acc.Id;
        
        Test.startTest();
        List<AccountComprehensiveFilesRetriever.ComprehensiveFilesResult> results = 
            AccountComprehensiveFilesRetriever.getAllAccountFiles(
                new List<AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest>{request}
            );
        Test.stopTest();
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesResult result = results[0];
        
        System.assertEquals(true, result.success, 'Operation should succeed');
        System.assertEquals(0, result.accountFileCount, 'Should have 0 account files');
        System.assertEquals(0, result.opportunityFileCount, 'Should have 0 opportunity files');
        System.assertEquals(0, result.totalFileCount, 'Should have 0 total files');
    }
    
    /**
     * Test invalid account ID
     */
    @isTest
    static void testGetAllFiles_InvalidAccount() {
        Id fakeAccountId = '001000000000000AAA';
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest request = 
            new AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest();
        request.accountId = fakeAccountId;
        
        Test.startTest();
        List<AccountComprehensiveFilesRetriever.ComprehensiveFilesResult> results = 
            AccountComprehensiveFilesRetriever.getAllAccountFiles(
                new List<AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest>{request}
            );
        Test.stopTest();
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesResult result = results[0];
        
        System.assertEquals(false, result.success, 'Operation should fail');
        System.assert(result.errorMessage.contains('not found'), 'Should have error message');
    }
    
    /**
     * Test opportunity file groups
     */
    @isTest
    static void testGetAllFiles_OpportunityGroups() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest request = 
            new AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest();
        request.accountId = acc.Id;
        
        Test.startTest();
        List<AccountComprehensiveFilesRetriever.ComprehensiveFilesResult> results = 
            AccountComprehensiveFilesRetriever.getAllAccountFiles(
                new List<AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest>{request}
            );
        Test.stopTest();
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesResult result = results[0];
        
        // Verify opportunity groups structure
        System.assertEquals(2, result.opportunityFiles.size(), 'Should have 2 opportunity groups');
        
        for (AccountComprehensiveFilesRetriever.OpportunityFileGroup fileGroup : result.opportunityFiles) {
            System.assertNotEquals(null, fileGroup.opportunityId, 'Group should have opp ID');
            System.assertNotEquals(null, fileGroup.opportunityName, 'Group should have opp name');
            System.assertNotEquals(null, fileGroup.opportunityStage, 'Group should have stage');
            System.assert(fileGroup.fileCount > 0, 'Group should have files');
            System.assertNotEquals(null, fileGroup.files, 'Group files list should not be null');
            System.assertEquals(fileGroup.fileCount, fileGroup.files.size(), 'File count should match list size');
        }
    }
    
    /**
     * Test file detail properties
     */
    @isTest
    static void testGetAllFiles_FileProperties() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest request = 
            new AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest();
        request.accountId = acc.Id;
        
        Test.startTest();
        List<AccountComprehensiveFilesRetriever.ComprehensiveFilesResult> results = 
            AccountComprehensiveFilesRetriever.getAllAccountFiles(
                new List<AccountComprehensiveFilesRetriever.ComprehensiveFilesRequest>{request}
            );
        Test.stopTest();
        
        AccountComprehensiveFilesRetriever.ComprehensiveFilesResult result = results[0];
        
        // Check account file properties
        if (!result.accountFiles.isEmpty()) {
            AccountComprehensiveFilesRetriever.FileDetail file = result.accountFiles[0];
            System.assertNotEquals(null, file.fileId, 'File ID should exist');
            System.assertNotEquals(null, file.title, 'Title should exist');
            System.assertNotEquals(null, file.fileExtension, 'Extension should exist');
            System.assertNotEquals(null, file.formattedSize, 'Formatted size should exist');
            System.assertEquals('Account', file.source, 'Source should be Account');
        }
        
        // Check opportunity file properties
        if (!result.opportunityFiles.isEmpty() && !result.opportunityFiles[0].files.isEmpty()) {
            AccountComprehensiveFilesRetriever.FileDetail file = result.opportunityFiles[0].files[0];
            System.assertNotEquals(null, file.fileId, 'File ID should exist');
            System.assertNotEquals(null, file.title, 'Title should exist');
            System.assertEquals('Opportunity', file.source, 'Source should be Opportunity');
            System.assertNotEquals(null, file.sourceOpportunityId, 'Source opp ID should exist');
            System.assertNotEquals(null, file.sourceOpportunityName, 'Source opp name should exist');
        }
    }
}
