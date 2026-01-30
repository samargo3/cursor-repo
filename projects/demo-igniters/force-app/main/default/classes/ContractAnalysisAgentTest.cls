/**
 * ContractAnalysisAgentTest
 * Test class for ContractAnalysisAgent
 */
@isTest
private class ContractAnalysisAgentTest {
    
    @testSetup
    static void setup() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test MSA Deal',
            AccountId = testAccount.Id,
            StageName = 'Negotiation/Review',
            CloseDate = Date.today().addDays(30),
            Amount = 100000
        );
        insert testOpp;
        
        // Create test ContentVersion (simulates uploaded file)
        ContentVersion cv = new ContentVersion(
            Title = 'Test_MSA_Contract',
            PathOnClient = 'Test_MSA_Contract.pdf',
            VersionData = Blob.valueOf('Test contract content'),
            IsMajorVersion = true
        );
        insert cv;
        
        // Get ContentDocument Id
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        // Link document to Opportunity
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = testOpp.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }
    
    @isTest
    static void testAnalyzeContract_Success() {
        // Get test Opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Create request
        ContractAnalysisAgent.ContractAnalysisRequest request = 
            new ContractAnalysisAgent.ContractAnalysisRequest();
        request.opportunityId = testOpp.Id;
        
        // Execute
        Test.startTest();
        List<ContractAnalysisAgent.ContractAnalysisResult> results = 
            ContractAnalysisAgent.analyzeContract(new List<ContractAnalysisAgent.ContractAnalysisRequest>{request});
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, results.size(), 'Should return one result');
        ContractAnalysisAgent.ContractAnalysisResult result = results[0];
        
        System.assertEquals(true, result.success, 'Analysis should succeed');
        System.assertEquals(testOpp.Id, result.opportunityId, 'Should match Opportunity ID');
        System.assertEquals(1, result.documentsFound, 'Should find one document');
        System.assertNotEquals(null, result.riskLevel, 'Should have risk level');
        System.assertNotEquals(null, result.summary, 'Should have summary');
    }
    
    @isTest
    static void testAnalyzeContract_NoDocuments() {
        // Create Opportunity without documents
        Account acc = new Account(Name = 'Test Account 2');
        insert acc;
        
        Opportunity oppNoDoc = new Opportunity(
            Name = 'No Doc Deal',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(60)
        );
        insert oppNoDoc;
        
        // Create request
        ContractAnalysisAgent.ContractAnalysisRequest request = 
            new ContractAnalysisAgent.ContractAnalysisRequest();
        request.opportunityId = oppNoDoc.Id;
        
        // Execute
        Test.startTest();
        List<ContractAnalysisAgent.ContractAnalysisResult> results = 
            ContractAnalysisAgent.analyzeContract(new List<ContractAnalysisAgent.ContractAnalysisRequest>{request});
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, results.size(), 'Should return one result');
        ContractAnalysisAgent.ContractAnalysisResult result = results[0];
        
        System.assertEquals(false, result.success, 'Should indicate no documents found');
        System.assertNotEquals(null, result.errorMessage, 'Should have error message');
    }
    
    @isTest
    static void testAnalyzeContract_MultipleDocuments() {
        // Get test Opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Add second document
        ContentVersion cv2 = new ContentVersion(
            Title = 'Test_Order_Form',
            PathOnClient = 'Test_Order_Form.pdf',
            VersionData = Blob.valueOf('Test order form content'),
            IsMajorVersion = true
        );
        insert cv2;
        
        cv2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id];
        
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            LinkedEntityId = testOpp.Id,
            ContentDocumentId = cv2.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl2;
        
        // Create request
        ContractAnalysisAgent.ContractAnalysisRequest request = 
            new ContractAnalysisAgent.ContractAnalysisRequest();
        request.opportunityId = testOpp.Id;
        
        // Execute
        Test.startTest();
        List<ContractAnalysisAgent.ContractAnalysisResult> results = 
            ContractAnalysisAgent.analyzeContract(new List<ContractAnalysisAgent.ContractAnalysisRequest>{request});
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, results.size(), 'Should return one result');
        ContractAnalysisAgent.ContractAnalysisResult result = results[0];
        
        System.assertEquals(true, result.success, 'Analysis should succeed');
        System.assertEquals(2, result.documentsFound, 'Should find two documents');
        System.assertEquals(2, result.documentNames.size(), 'Should list both document names');
    }
    
    @isTest
    static void testRiskCalculation() {
        // This test verifies the risk calculation logic
        // In a real implementation, you would test various risk scenarios
        
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        ContractAnalysisAgent.ContractAnalysisRequest request = 
            new ContractAnalysisAgent.ContractAnalysisRequest();
        request.opportunityId = testOpp.Id;
        
        Test.startTest();
        List<ContractAnalysisAgent.ContractAnalysisResult> results = 
            ContractAnalysisAgent.analyzeContract(new List<ContractAnalysisAgent.ContractAnalysisRequest>{request});
        Test.stopTest();
        
        ContractAnalysisAgent.ContractAnalysisResult result = results[0];
        
        // Verify risk assessment fields exist
        System.assertNotEquals(null, result.riskLevel, 'Risk level should be set');
        System.assertNotEquals(null, result.riskScore, 'Risk score should be set');
        System.assertNotEquals(null, result.riskFactors, 'Risk factors should be set');
        System.assertNotEquals(null, result.recommendations, 'Recommendations should be set');
        
        // Verify risk level is valid
        Set<String> validRiskLevels = new Set<String>{'Low', 'Medium', 'High', 'Critical'};
        System.assert(validRiskLevels.contains(result.riskLevel), 
                     'Risk level should be Low, Medium, High, or Critical');
    }
}

