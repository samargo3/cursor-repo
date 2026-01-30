// Salesforce Agent APEX Classes - Usage Examples
// Run this script to test the Agent classes functionality

System.debug('=== Salesforce Agent APEX Classes Test ===\n');

// Test 1: Lead Qualification Agent
System.debug('--- Testing Lead Qualification Agent ---');

// Create a test lead
Lead testLead = new Lead(
    FirstName = 'John',
    LastName = 'Doe',
    Company = 'Acme Corporation',
    Email = 'john.doe@acme.com',
    Phone = '555-123-4567',
    Industry = 'Technology',
    AnnualRevenue = 5000000,
    NumberOfEmployees = 500,
    LeadSource = 'Website'
);
insert testLead;

System.debug('Created test lead: ' + testLead.Id);

// Test lead qualification
try {
    AgentActionController.AgentResponse response = LeadQualificationAgent.qualifyLead(testLead.Id);
    System.debug('Lead qualification result: ' + response);
    
    if (response.success) {
        System.debug('✅ Lead qualification successful');
    } else {
        System.debug('❌ Lead qualification failed: ' + response.message);
    }
} catch (Exception e) {
    System.debug('❌ Lead qualification error: ' + e.getMessage());
}

// Test 2: Opportunity Insight Agent
System.debug('\n--- Testing Opportunity Insight Agent ---');

// Create a test opportunity
Opportunity testOpp = new Opportunity(
    Name = 'Test Opportunity',
    StageName = 'Prospecting',
    CloseDate = Date.today().addDays(30),
    Amount = 100000,
    Probability = 25,
    Type = 'New Business'
);
insert testOpp;

System.debug('Created test opportunity: ' + testOpp.Id);

// Test opportunity analysis
try {
    AgentActionController.AgentResponse response = OpportunityInsightAgent.analyzeOpportunity(testOpp.Id);
    System.debug('Opportunity analysis result: ' + response);
    
    if (response.success) {
        System.debug('✅ Opportunity analysis successful');
    } else {
        System.debug('❌ Opportunity analysis failed: ' + response.message);
    }
} catch (Exception e) {
    System.debug('❌ Opportunity analysis error: ' + e.getMessage());
}

// Test pipeline analysis
try {
    AgentActionController.AgentResponse response = OpportunityInsightAgent.analyzePipeline(null);
    System.debug('Pipeline analysis result: ' + response);
    
    if (response.success) {
        System.debug('✅ Pipeline analysis successful');
    } else {
        System.debug('❌ Pipeline analysis failed: ' + response.message);
    }
} catch (Exception e) {
    System.debug('❌ Pipeline analysis error: ' + e.getMessage());
}

// Test 3: Customer Service Agent
System.debug('\n--- Testing Customer Service Agent ---');

// Create a test case
Case testCase = new Case(
    Subject = 'Test Support Case',
    Description = 'This is a test case for the Customer Service Agent',
    Priority = 'Medium',
    Type = 'Technical',
    Status = 'New',
    Origin = 'Web'
);
insert testCase;

System.debug('Created test case: ' + testCase.Id);

// Test case analysis
try {
    AgentActionController.AgentResponse response = CustomerServiceAgent.analyzeCase(testCase.Id);
    System.debug('Case analysis result: ' + response);
    
    if (response.success) {
        System.debug('✅ Case analysis successful');
    } else {
        System.debug('❌ Case analysis failed: ' + response.message);
    }
} catch (Exception e) {
    System.debug('❌ Case analysis error: ' + e.getMessage());
}

// Test service metrics
try {
    AgentActionController.AgentResponse response = CustomerServiceAgent.getServiceMetrics(null, 30);
    System.debug('Service metrics result: ' + response);
    
    if (response.success) {
        System.debug('✅ Service metrics successful');
    } else {
        System.debug('❌ Service metrics failed: ' + response.message);
    }
} catch (Exception e) {
    System.debug('❌ Service metrics error: ' + e.getMessage());
}

System.debug('\n=== Agent Classes Test Complete ===');

// Cleanup test data
try {
    delete [SELECT Id FROM Lead WHERE FirstName = 'John' AND LastName = 'Doe'];
    delete [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'];
    delete [SELECT Id FROM Case WHERE Subject = 'Test Support Case'];
    System.debug('✅ Test data cleaned up');
} catch (Exception e) {
    System.debug('⚠️ Cleanup warning: ' + e.getMessage());
}
