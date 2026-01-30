/**
 * Test class for AccountFilesRetriever
 * 
 * Tests file retrieval functionality for files directly attached to Accounts
 */
@isTest
private class AccountFilesRetriever_Test {
    
    /**
     * Setup test data
     */
    @TestSetup
    static void setup() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account for File Retrieval'
        );
        insert testAccount;
        
        // Create test files (ContentVersion objects)
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        // PDF file
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Contract';
        cv1.PathOnClient = 'TestContract.pdf';
        cv1.VersionData = Blob.valueOf('Test PDF content');
        cv1.IsMajorVersion = true;
        contentVersions.add(cv1);
        
        // DOCX file
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test Proposal';
        cv2.PathOnClient = 'TestProposal.docx';
        cv2.VersionData = Blob.valueOf('Test DOCX content');
        cv2.IsMajorVersion = true;
        contentVersions.add(cv2);
        
        // XLSX file
        ContentVersion cv3 = new ContentVersion();
        cv3.Title = 'Test Pricing';
        cv3.PathOnClient = 'TestPricing.xlsx';
        cv3.VersionData = Blob.valueOf('Test XLSX content');
        cv3.IsMajorVersion = true;
        contentVersions.add(cv3);
        
        insert contentVersions;
        
        // Get ContentDocument IDs
        List<ContentVersion> insertedVersions = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id IN :contentVersions
        ];
        
        // Link files to Account
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion cv : insertedVersions) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = cv.ContentDocumentId;
            link.LinkedEntityId = testAccount.Id;
            link.ShareType = 'V';
            link.Visibility = 'AllUsers';
            links.add(link);
        }
        insert links;
    }
    
    /**
     * Test successful file retrieval
     */
    @isTest
    static void testGetAccountFiles_Success() {
        // Get test account
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Prepare request
        AccountFilesRetriever.AccountFilesRequest request = 
            new AccountFilesRetriever.AccountFilesRequest();
        request.accountId = acc.Id;
        
        Test.startTest();
        List<AccountFilesRetriever.AccountFilesResult> results = 
            AccountFilesRetriever.getAccountFiles(new List<AccountFilesRetriever.AccountFilesRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Should return one result');
        
        AccountFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should succeed');
        System.assertEquals(acc.Id, result.accountId, 'Account ID should match');
        System.assertEquals('Test Account for File Retrieval', result.accountName, 'Account name should match');
        System.assertEquals(3, result.fileCount, 'Should find 3 files');
        System.assertNotEquals(null, result.fileDetails, 'File details should not be null');
        System.assertEquals(3, result.fileDetails.size(), 'Should have 3 file detail objects');
        System.assert(result.fileSummary.contains('Test Contract'), 'Summary should contain file name');
        System.assert(result.fileList.contains('Test Contract.pdf'), 'File list should contain PDF');
    }
    
    /**
     * Test file type filtering
     */
    @isTest
    static void testGetAccountFiles_FilterByType() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Request only PDF files
        AccountFilesRetriever.AccountFilesRequest request = 
            new AccountFilesRetriever.AccountFilesRequest();
        request.accountId = acc.Id;
        request.fileTypes = 'pdf';
        
        Test.startTest();
        List<AccountFilesRetriever.AccountFilesResult> results = 
            AccountFilesRetriever.getAccountFiles(new List<AccountFilesRetriever.AccountFilesRequest>{request});
        Test.stopTest();
        
        AccountFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should succeed');
        System.assertEquals(1, result.fileCount, 'Should find only 1 PDF file');
        System.assertEquals('pdf', result.fileDetails[0].fileExtension, 'File should be PDF');
    }
    
    /**
     * Test multiple file type filtering
     */
    @isTest
    static void testGetAccountFiles_FilterMultipleTypes() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Request PDF and DOCX files
        AccountFilesRetriever.AccountFilesRequest request = 
            new AccountFilesRetriever.AccountFilesRequest();
        request.accountId = acc.Id;
        request.fileTypes = 'pdf, docx';
        
        Test.startTest();
        List<AccountFilesRetriever.AccountFilesResult> results = 
            AccountFilesRetriever.getAccountFiles(new List<AccountFilesRetriever.AccountFilesRequest>{request});
        Test.stopTest();
        
        AccountFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should succeed');
        System.assertEquals(2, result.fileCount, 'Should find 2 files (PDF + DOCX)');
    }
    
    /**
     * Test max files limit
     */
    @isTest
    static void testGetAccountFiles_MaxFilesLimit() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        AccountFilesRetriever.AccountFilesRequest request = 
            new AccountFilesRetriever.AccountFilesRequest();
        request.accountId = acc.Id;
        request.maxFiles = 2;
        
        Test.startTest();
        List<AccountFilesRetriever.AccountFilesResult> results = 
            AccountFilesRetriever.getAccountFiles(new List<AccountFilesRetriever.AccountFilesRequest>{request});
        Test.stopTest();
        
        AccountFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should succeed');
        System.assertEquals(2, result.fileCount, 'Should be limited to 2 files');
    }
    
    /**
     * Test account with no files
     */
    @isTest
    static void testGetAccountFiles_NoFiles() {
        // Create account without files
        Account accNoFiles = new Account(Name = 'Account Without Files');
        insert accNoFiles;
        
        AccountFilesRetriever.AccountFilesRequest request = 
            new AccountFilesRetriever.AccountFilesRequest();
        request.accountId = accNoFiles.Id;
        
        Test.startTest();
        List<AccountFilesRetriever.AccountFilesResult> results = 
            AccountFilesRetriever.getAccountFiles(new List<AccountFilesRetriever.AccountFilesRequest>{request});
        Test.stopTest();
        
        AccountFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should succeed even with no files');
        System.assertEquals(0, result.fileCount, 'Should find 0 files');
        System.assert(result.message.contains('No files'), 'Message should indicate no files');
    }
    
    /**
     * Test invalid account ID
     */
    @isTest
    static void testGetAccountFiles_InvalidAccountId() {
        // Use a fake account ID (won't exist in test context)
        Id fakeAccountId = '001000000000000AAA';
        
        AccountFilesRetriever.AccountFilesRequest request = 
            new AccountFilesRetriever.AccountFilesRequest();
        request.accountId = fakeAccountId;
        
        Test.startTest();
        List<AccountFilesRetriever.AccountFilesResult> results = 
            AccountFilesRetriever.getAccountFiles(new List<AccountFilesRetriever.AccountFilesRequest>{request});
        Test.stopTest();
        
        AccountFilesRetriever.AccountFilesResult result = results[0];
        System.assertEquals(false, result.success, 'Operation should fail');
        System.assert(result.errorMessage.contains('not found'), 'Error message should indicate account not found');
    }
    
    /**
     * Test file detail properties
     */
    @isTest
    static void testGetAccountFiles_FileDetailProperties() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        AccountFilesRetriever.AccountFilesRequest request = 
            new AccountFilesRetriever.AccountFilesRequest();
        request.accountId = acc.Id;
        
        Test.startTest();
        List<AccountFilesRetriever.AccountFilesResult> results = 
            AccountFilesRetriever.getAccountFiles(new List<AccountFilesRetriever.AccountFilesRequest>{request});
        Test.stopTest();
        
        AccountFilesRetriever.AccountFilesResult result = results[0];
        AccountFilesRetriever.FileDetail fileDetail = result.fileDetails[0];
        
        // Check all properties are populated
        System.assertNotEquals(null, fileDetail.fileId, 'File ID should be populated');
        System.assertNotEquals(null, fileDetail.title, 'Title should be populated');
        System.assertNotEquals(null, fileDetail.fileExtension, 'File extension should be populated');
        System.assertNotEquals(null, fileDetail.contentSize, 'Content size should be populated');
        System.assertNotEquals(null, fileDetail.formattedSize, 'Formatted size should be populated');
        System.assertNotEquals(null, fileDetail.createdDate, 'Created date should be populated');
        System.assertNotEquals(null, fileDetail.downloadUrl, 'Download URL should be populated');
        System.assertNotEquals(null, fileDetail.viewUrl, 'View URL should be populated');
        
        // Check URL formats
        System.assert(fileDetail.downloadUrl.contains('/sfc/servlet.shepherd'), 'Download URL should be valid');
        System.assert(fileDetail.viewUrl.contains('/lightning/r/ContentDocument'), 'View URL should be valid');
    }
    
    /**
     * Test file size formatting
     */
    @isTest
    static void testGetAccountFiles_FileSizeFormatting() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        AccountFilesRetriever.AccountFilesRequest request = 
            new AccountFilesRetriever.AccountFilesRequest();
        request.accountId = acc.Id;
        
        Test.startTest();
        List<AccountFilesRetriever.AccountFilesResult> results = 
            AccountFilesRetriever.getAccountFiles(new List<AccountFilesRetriever.AccountFilesRequest>{request});
        Test.stopTest();
        
        AccountFilesRetriever.AccountFilesResult result = results[0];
        
        // Check that formatted size exists and contains units
        System.assertNotEquals(null, result.formattedTotalSize, 'Formatted total size should exist');
        System.assert(
            result.formattedTotalSize.contains('B') || 
            result.formattedTotalSize.contains('KB') || 
            result.formattedTotalSize.contains('MB'),
            'Formatted size should contain units'
        );
    }
    
    /**
     * Test bulk operation (multiple accounts)
     */
    @isTest
    static void testGetAccountFiles_BulkOperation() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Create multiple requests
        List<AccountFilesRetriever.AccountFilesRequest> requests = 
            new List<AccountFilesRetriever.AccountFilesRequest>();
        
        for (Integer i = 0; i < 3; i++) {
            AccountFilesRetriever.AccountFilesRequest request = 
                new AccountFilesRetriever.AccountFilesRequest();
            request.accountId = acc.Id;
            requests.add(request);
        }
        
        Test.startTest();
        List<AccountFilesRetriever.AccountFilesResult> results = 
            AccountFilesRetriever.getAccountFiles(requests);
        Test.stopTest();
        
        System.assertEquals(3, results.size(), 'Should return 3 results');
        for (AccountFilesRetriever.AccountFilesResult result : results) {
            System.assertEquals(true, result.success, 'All operations should succeed');
            System.assertEquals(3, result.fileCount, 'All should find 3 files');
        }
    }
}
