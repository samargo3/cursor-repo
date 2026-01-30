/**
 * Test class for OpportunityFileRetriever
 * 
 * @author Solution Engineering Team
 * @version 1.0
 */
@isTest
private class OpportunityFileRetriever_Test {
    
    /**
     * Setup test data
     */
    @testSetup
    static void setupTestData() {
        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity for Files',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 100000
        );
        insert testOpp;
        
        // Create test ContentVersion (file)
        ContentVersion cv1 = new ContentVersion(
            Title = 'Test Contract Document',
            PathOnClient = 'TestContract.pdf',
            VersionData = Blob.valueOf('Test contract content'),
            IsMajorVersion = true
        );
        insert cv1;
        
        // Get ContentDocument ID
        ContentVersion insertedCV1 = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv1.Id
        ];
        
        // Link file to Opportunity
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            LinkedEntityId = testOpp.Id,
            ContentDocumentId = insertedCV1.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl1;
        
        // Create second file
        ContentVersion cv2 = new ContentVersion(
            Title = 'Test Proposal',
            PathOnClient = 'TestProposal.docx',
            VersionData = Blob.valueOf('Test proposal content'),
            IsMajorVersion = true
        );
        insert cv2;
        
        // Get ContentDocument ID
        ContentVersion insertedCV2 = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv2.Id
        ];
        
        // Link second file to Opportunity
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            LinkedEntityId = testOpp.Id,
            ContentDocumentId = insertedCV2.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl2;
    }
    
    /**
     * Test retrieving all files from an Opportunity
     */
    @isTest
    static void testGetOpportunityFilesSuccess() {
        // Get test Opportunity
        Opportunity testOpp = [
            SELECT Id 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity for Files' 
            LIMIT 1
        ];
        
        // Create request
        OpportunityFileRetriever.FileRetrievalRequest request = 
            new OpportunityFileRetriever.FileRetrievalRequest();
        request.opportunityId = testOpp.Id;
        
        Test.startTest();
        List<OpportunityFileRetriever.FileRetrievalResult> results = 
            OpportunityFileRetriever.getOpportunityFiles(
                new List<OpportunityFileRetriever.FileRetrievalRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result');
        
        OpportunityFileRetriever.FileRetrievalResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(2, result.fileCount, 'Should find 2 files');
        System.assertNotEquals(null, result.fileDetails, 'File details should not be null');
        System.assertEquals(2, result.fileDetails.size(), 'Should have 2 file details');
        System.assertNotEquals(null, result.fileList, 'File list should not be null');
        System.assertNotEquals(null, result.fileSummary, 'File summary should not be null');
        System.assert(result.totalSize > 0, 'Total size should be greater than 0');
    }
    
    /**
     * Test retrieving files with file type filter
     */
    @isTest
    static void testGetOpportunityFilesWithFilter() {
        // Get test Opportunity
        Opportunity testOpp = [
            SELECT Id 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity for Files' 
            LIMIT 1
        ];
        
        // Create request with PDF filter
        OpportunityFileRetriever.FileRetrievalRequest request = 
            new OpportunityFileRetriever.FileRetrievalRequest();
        request.opportunityId = testOpp.Id;
        request.fileTypes = 'pdf';
        
        Test.startTest();
        List<OpportunityFileRetriever.FileRetrievalResult> results = 
            OpportunityFileRetriever.getOpportunityFiles(
                new List<OpportunityFileRetriever.FileRetrievalRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        OpportunityFileRetriever.FileRetrievalResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(1, result.fileCount, 'Should find 1 PDF file');
        System.assertEquals('pdf', result.fileDetails[0].fileExtension, 
                          'File should be PDF');
    }
    
    /**
     * Test retrieving files with max files limit
     */
    @isTest
    static void testGetOpportunityFilesWithLimit() {
        // Get test Opportunity
        Opportunity testOpp = [
            SELECT Id 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity for Files' 
            LIMIT 1
        ];
        
        // Create request with limit
        OpportunityFileRetriever.FileRetrievalRequest request = 
            new OpportunityFileRetriever.FileRetrievalRequest();
        request.opportunityId = testOpp.Id;
        request.maxFiles = 1;
        
        Test.startTest();
        List<OpportunityFileRetriever.FileRetrievalResult> results = 
            OpportunityFileRetriever.getOpportunityFiles(
                new List<OpportunityFileRetriever.FileRetrievalRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        OpportunityFileRetriever.FileRetrievalResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(1, result.fileCount, 'Should find only 1 file due to limit');
    }
    
    /**
     * Test with Opportunity that has no files
     */
    @isTest
    static void testGetOpportunityFilesNoFiles() {
        // Create Opportunity without files
        Opportunity oppWithoutFiles = new Opportunity(
            Name = 'Opportunity Without Files',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 50000
        );
        insert oppWithoutFiles;
        
        // Create request
        OpportunityFileRetriever.FileRetrievalRequest request = 
            new OpportunityFileRetriever.FileRetrievalRequest();
        request.opportunityId = oppWithoutFiles.Id;
        
        Test.startTest();
        List<OpportunityFileRetriever.FileRetrievalResult> results = 
            OpportunityFileRetriever.getOpportunityFiles(
                new List<OpportunityFileRetriever.FileRetrievalRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        OpportunityFileRetriever.FileRetrievalResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(0, result.fileCount, 'Should find 0 files');
        System.assertNotEquals(null, result.message, 'Should have a message');
        System.assert(result.message.contains('No files found'), 
                     'Message should indicate no files found');
    }
    
    /**
     * Test with invalid Opportunity ID
     */
    @isTest
    static void testGetOpportunityFilesInvalidId() {
        // Create request with non-existent Opportunity ID
        OpportunityFileRetriever.FileRetrievalRequest request = 
            new OpportunityFileRetriever.FileRetrievalRequest();
        request.opportunityId = '006000000000000AAA'; // Invalid ID
        
        Test.startTest();
        List<OpportunityFileRetriever.FileRetrievalResult> results = 
            OpportunityFileRetriever.getOpportunityFiles(
                new List<OpportunityFileRetriever.FileRetrievalRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        OpportunityFileRetriever.FileRetrievalResult result = results[0];
        System.assertEquals(false, result.success, 'Operation should fail');
        System.assertNotEquals(null, result.errorMessage, 'Should have error message');
    }
    
    /**
     * Test file size formatting
     */
    @isTest
    static void testFileSizeFormatting() {
        // Get test Opportunity
        Opportunity testOpp = [
            SELECT Id 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity for Files' 
            LIMIT 1
        ];
        
        // Create request
        OpportunityFileRetriever.FileRetrievalRequest request = 
            new OpportunityFileRetriever.FileRetrievalRequest();
        request.opportunityId = testOpp.Id;
        
        Test.startTest();
        List<OpportunityFileRetriever.FileRetrievalResult> results = 
            OpportunityFileRetriever.getOpportunityFiles(
                new List<OpportunityFileRetriever.FileRetrievalRequest>{ request }
            );
        Test.stopTest();
        
        // Verify file size is formatted
        OpportunityFileRetriever.FileRetrievalResult result = results[0];
        for (OpportunityFileRetriever.FileDetail detail : result.fileDetails) {
            System.assertNotEquals(null, detail.formattedSize, 
                                 'Formatted size should not be null');
            System.assert(detail.formattedSize.contains('B') || 
                         detail.formattedSize.contains('KB') ||
                         detail.formattedSize.contains('MB'),
                         'Formatted size should contain size unit');
        }
    }
    
    /**
     * Test file detail properties
     */
    @isTest
    static void testFileDetailProperties() {
        // Get test Opportunity
        Opportunity testOpp = [
            SELECT Id 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity for Files' 
            LIMIT 1
        ];
        
        // Create request
        OpportunityFileRetriever.FileRetrievalRequest request = 
            new OpportunityFileRetriever.FileRetrievalRequest();
        request.opportunityId = testOpp.Id;
        
        Test.startTest();
        List<OpportunityFileRetriever.FileRetrievalResult> results = 
            OpportunityFileRetriever.getOpportunityFiles(
                new List<OpportunityFileRetriever.FileRetrievalRequest>{ request }
            );
        Test.stopTest();
        
        // Verify file details have all required properties
        OpportunityFileRetriever.FileRetrievalResult result = results[0];
        for (OpportunityFileRetriever.FileDetail detail : result.fileDetails) {
            System.assertNotEquals(null, detail.documentId, 'Document ID should not be null');
            System.assertNotEquals(null, detail.versionId, 'Version ID should not be null');
            System.assertNotEquals(null, detail.title, 'Title should not be null');
            System.assertNotEquals(null, detail.fileExtension, 'File extension should not be null');
            System.assertNotEquals(null, detail.downloadUrl, 'Download URL should not be null');
            System.assertNotEquals(null, detail.viewUrl, 'View URL should not be null');
            System.assertNotEquals(null, detail.createdDate, 'Created date should not be null');
        }
    }
    
    /**
     * Test multiple file types filter
     */
    @isTest
    static void testMultipleFileTypesFilter() {
        // Get test Opportunity
        Opportunity testOpp = [
            SELECT Id 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity for Files' 
            LIMIT 1
        ];
        
        // Create request with multiple file types
        OpportunityFileRetriever.FileRetrievalRequest request = 
            new OpportunityFileRetriever.FileRetrievalRequest();
        request.opportunityId = testOpp.Id;
        request.fileTypes = 'pdf, docx';
        
        Test.startTest();
        List<OpportunityFileRetriever.FileRetrievalResult> results = 
            OpportunityFileRetriever.getOpportunityFiles(
                new List<OpportunityFileRetriever.FileRetrievalRequest>{ request }
            );
        Test.stopTest();
        
        // Verify results
        OpportunityFileRetriever.FileRetrievalResult result = results[0];
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(2, result.fileCount, 'Should find 2 files with specified types');
    }
}

