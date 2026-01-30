/**
 * @description Test class for PromptBuilderDataProvider
 * @author Solution Engineering Team
 * @version 1.0
 */
@isTest
private class PromptBuilderDataProvider_Test {
    
    @testSetup
    static void setup() {
        // Create test Lead
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Smith',
            Company = 'Acme Corp',
            Email = 'john.smith@acme.com',
            Phone = '555-1234',
            Industry = 'Technology',
            Title = 'CTO',
            AnnualRevenue = 5000000,
            NumberOfEmployees = 500,
            Status = 'Open - Not Contacted',
            LeadSource = 'Web',
            City = 'San Francisco',
            State = 'CA',
            Country = 'USA'
        );
        insert testLead;
        
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology',
            AnnualRevenue = 10000000
        );
        insert testAccount;
        
        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            Amount = 100000,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            Probability = 50,
            Type = 'New Business',
            LeadSource = 'Web',
            NextStep = 'Schedule demo'
        );
        insert testOpp;
        
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            Email = 'jane.doe@test.com'
        );
        insert testContact;
        
        // Create test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            Description = 'Test case description',
            Priority = 'High',
            Status = 'New',
            Type = 'Technical',
            Origin = 'Email',
            AccountId = testAccount.Id,
            ContactId = testContact.Id
        );
        insert testCase;
    }
    
    @isTest
    static void testGetLeadContext() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        
        Test.startTest();
        PromptBuilderDataProvider.PromptRequest request = new PromptBuilderDataProvider.PromptRequest();
        request.recordId = testLead.Id;
        
        List<PromptBuilderDataProvider.PromptContext> results = 
            PromptBuilderDataProvider.getRecordContext(new List<PromptBuilderDataProvider.PromptRequest>{request});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one context');
        PromptBuilderDataProvider.PromptContext context = results[0];
        
        System.assertEquals(true, context.success, 'Context should be successful');
        System.assertEquals('Lead', context.recordType, 'Record type should be Lead');
        System.assertEquals('John Smith', context.fullName, 'Full name should match');
        System.assertEquals('Acme Corp', context.companyName, 'Company name should match');
        System.assertEquals('Technology', context.industry, 'Industry should match');
        System.assertNotEquals(null, context.leadScore, 'Lead score should be calculated');
        System.assertNotEquals(null, context.leadGrade, 'Lead grade should be assigned');
        System.assertNotEquals(null, context.contextSummary, 'Context summary should be generated');
    }
    
    @isTest
    static void testGetLeadContextInvalidId() {
        Test.startTest();
        PromptBuilderDataProvider.PromptRequest request = new PromptBuilderDataProvider.PromptRequest();
        request.recordId = '00Q000000000000AAA'; // Invalid Lead ID
        
        List<PromptBuilderDataProvider.PromptContext> results = 
            PromptBuilderDataProvider.getRecordContext(new List<PromptBuilderDataProvider.PromptRequest>{request});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one context');
        PromptBuilderDataProvider.PromptContext context = results[0];
        
        System.assertEquals(false, context.success, 'Context should indicate failure');
        System.assertNotEquals(null, context.errorMessage, 'Error message should be present');
    }
    
    @isTest
    static void testGetOpportunityContext() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        PromptBuilderDataProvider.PromptRequest request = new PromptBuilderDataProvider.PromptRequest();
        request.recordId = testOpp.Id;
        
        List<PromptBuilderDataProvider.PromptContext> results = 
            PromptBuilderDataProvider.getRecordContext(new List<PromptBuilderDataProvider.PromptRequest>{request});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one context');
        PromptBuilderDataProvider.PromptContext context = results[0];
        
        System.assertEquals(true, context.success, 'Context should be successful');
        System.assertEquals('Opportunity', context.recordType, 'Record type should be Opportunity');
        System.assertEquals('Test Opportunity', context.opportunityName, 'Opportunity name should match');
        System.assertEquals('Test Account', context.accountName, 'Account name should match');
        System.assertNotEquals(null, context.riskLevel, 'Risk level should be assessed');
        System.assertNotEquals(null, context.urgencyLevel, 'Urgency level should be assessed');
        System.assertNotEquals(null, context.recommendations, 'Recommendations should be provided');
        System.assertNotEquals(null, context.contextSummary, 'Context summary should be generated');
    }
    
    @isTest
    static void testGetOpportunityContextInvalidId() {
        Test.startTest();
        PromptBuilderDataProvider.PromptRequest request = new PromptBuilderDataProvider.PromptRequest();
        request.recordId = '006000000000000AAA'; // Invalid Opportunity ID
        
        List<PromptBuilderDataProvider.PromptContext> results = 
            PromptBuilderDataProvider.getRecordContext(new List<PromptBuilderDataProvider.PromptRequest>{request});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one context');
        PromptBuilderDataProvider.PromptContext context = results[0];
        
        System.assertEquals(false, context.success, 'Context should indicate failure');
        System.assertNotEquals(null, context.errorMessage, 'Error message should be present');
    }
    
    @isTest
    static void testGetCaseContext() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        PromptBuilderDataProvider.PromptRequest request = new PromptBuilderDataProvider.PromptRequest();
        request.recordId = testCase.Id;
        
        List<PromptBuilderDataProvider.PromptContext> results = 
            PromptBuilderDataProvider.getRecordContext(new List<PromptBuilderDataProvider.PromptRequest>{request});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one context');
        PromptBuilderDataProvider.PromptContext context = results[0];
        
        System.assertEquals(true, context.success, 'Context should be successful');
        System.assertEquals('Case', context.recordType, 'Record type should be Case');
        System.assertEquals('Test Case', context.subject, 'Subject should match');
        System.assertEquals('Test Account', context.accountName, 'Account name should match');
        System.assertNotEquals(null, context.urgencyLevel, 'Urgency level should be assessed');
        System.assertNotEquals(null, context.suggestedResolution, 'Suggested resolution should be provided');
        System.assertNotEquals(null, context.contextSummary, 'Context summary should be generated');
    }
    
    @isTest
    static void testGetCaseContextInvalidId() {
        Test.startTest();
        PromptBuilderDataProvider.PromptRequest request = new PromptBuilderDataProvider.PromptRequest();
        request.recordId = '500000000000000AAA'; // Invalid Case ID
        
        List<PromptBuilderDataProvider.PromptContext> results = 
            PromptBuilderDataProvider.getRecordContext(new List<PromptBuilderDataProvider.PromptRequest>{request});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one context');
        PromptBuilderDataProvider.PromptContext context = results[0];
        
        System.assertEquals(false, context.success, 'Context should indicate failure');
        System.assertNotEquals(null, context.errorMessage, 'Error message should be present');
    }
    
    @isTest
    static void testLeadScoring() {
        // Create lead with high score
        Lead highScoreLead = new Lead(
            FirstName = 'High',
            LastName = 'Score',
            Company = 'Big Corp',
            Email = 'high@bigcorp.com',
            Phone = '555-9999',
            Industry = 'Technology',
            AnnualRevenue = 50000000,
            NumberOfEmployees = 5000,
            LeadSource = 'Referral',
            Status = 'Open - Not Contacted'
        );
        insert highScoreLead;
        
        Test.startTest();
        PromptBuilderDataProvider.PromptRequest request = new PromptBuilderDataProvider.PromptRequest();
        request.recordId = highScoreLead.Id;
        
        List<PromptBuilderDataProvider.PromptContext> results = 
            PromptBuilderDataProvider.getRecordContext(new List<PromptBuilderDataProvider.PromptRequest>{request});
        Test.stopTest();
        
        PromptBuilderDataProvider.PromptContext context = results[0];
        System.assert(context.leadScore >= 80, 'High quality lead should have high score');
        System.assert(context.leadGrade.startsWith('A'), 'High quality lead should have A grade');
    }
    
    @isTest
    static void testOpportunityRiskAssessment() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Create high risk opportunity
        Opportunity highRiskOpp = new Opportunity(
            Name = 'High Risk Opp',
            AccountId = acc.Id,
            Amount = 500000,
            CloseDate = Date.today().addDays(5),
            StageName = 'Prospecting',
            Probability = 20
        );
        insert highRiskOpp;
        
        Test.startTest();
        PromptBuilderDataProvider.PromptRequest request = new PromptBuilderDataProvider.PromptRequest();
        request.recordId = highRiskOpp.Id;
        
        List<PromptBuilderDataProvider.PromptContext> results = 
            PromptBuilderDataProvider.getRecordContext(new List<PromptBuilderDataProvider.PromptRequest>{request});
        Test.stopTest();
        
        PromptBuilderDataProvider.PromptContext context = results[0];
        System.assertEquals('High', context.riskLevel, 'Should be assessed as high risk');
        System.assertEquals('Critical', context.urgencyLevel, 'Should be assessed as critical urgency');
    }
    
    @isTest
    static void testCaseUrgencyAssessment() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        // Create escalated case
        Case escalatedCase = new Case(
            Subject = 'Escalated Case',
            Priority = 'High',
            Status = 'New',
            Type = 'Technical',
            IsEscalated = true,
            AccountId = acc.Id,
            ContactId = con.Id
        );
        insert escalatedCase;
        
        Test.startTest();
        PromptBuilderDataProvider.PromptRequest request = new PromptBuilderDataProvider.PromptRequest();
        request.recordId = escalatedCase.Id;
        
        List<PromptBuilderDataProvider.PromptContext> results = 
            PromptBuilderDataProvider.getRecordContext(new List<PromptBuilderDataProvider.PromptRequest>{request});
        Test.stopTest();
        
        PromptBuilderDataProvider.PromptContext context = results[0];
        System.assertEquals('Critical', context.urgencyLevel, 'Escalated case should be critical urgency');
        System.assertEquals(true, context.isEscalated, 'Case should be marked as escalated');
    }
    
    @isTest
    static void testBulkProcessing() {
        List<Lead> leads = [SELECT Id FROM Lead];
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<Case> cases = [SELECT Id FROM Case];
        
        List<PromptBuilderDataProvider.PromptRequest> leadRequests = new List<PromptBuilderDataProvider.PromptRequest>();
        for (Lead l : leads) {
            PromptBuilderDataProvider.PromptRequest req = new PromptBuilderDataProvider.PromptRequest();
            req.recordId = l.Id;
            leadRequests.add(req);
        }
        
        List<PromptBuilderDataProvider.PromptRequest> oppRequests = new List<PromptBuilderDataProvider.PromptRequest>();
        for (Opportunity o : opps) {
            PromptBuilderDataProvider.PromptRequest req = new PromptBuilderDataProvider.PromptRequest();
            req.recordId = o.Id;
            oppRequests.add(req);
        }
        
        List<PromptBuilderDataProvider.PromptRequest> caseRequests = new List<PromptBuilderDataProvider.PromptRequest>();
        for (Case c : cases) {
            PromptBuilderDataProvider.PromptRequest req = new PromptBuilderDataProvider.PromptRequest();
            req.recordId = c.Id;
            caseRequests.add(req);
        }
        
        Test.startTest();
        List<PromptBuilderDataProvider.PromptContext> leadResults = 
            PromptBuilderDataProvider.getRecordContext(leadRequests);
        List<PromptBuilderDataProvider.PromptContext> oppResults = 
            PromptBuilderDataProvider.getRecordContext(oppRequests);
        List<PromptBuilderDataProvider.PromptContext> caseResults = 
            PromptBuilderDataProvider.getRecordContext(caseRequests);
        Test.stopTest();
        
        System.assertEquals(leads.size(), leadResults.size(), 'All leads should be processed');
        System.assertEquals(opps.size(), oppResults.size(), 'All opportunities should be processed');
        System.assertEquals(cases.size(), caseResults.size(), 'All cases should be processed');
    }
}

