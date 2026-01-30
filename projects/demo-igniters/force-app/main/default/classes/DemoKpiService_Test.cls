/**
 * Test class for DemoKpiService
 */
@isTest
private class DemoKpiService_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= 5; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Industry = 'Technology',
                AnnualRevenue = 1000000
            ));
        }
        insert accounts;
        
        // Create test opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
        Integer counter = 0;
        for (Account acc : accounts) {
            opportunities.add(new Opportunity(
                Name = 'Test Opp ' + counter,
                AccountId = acc.Id,
                StageName = counter < 2 ? 'Closed Won' : 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = 100000 + (counter * 10000)
            ));
            counter++;
        }
        insert opportunities;
        
        // Create test contacts
        List<Contact> contacts = new List<Contact>();
        for (Account acc : accounts) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                AccountId = acc.Id,
                Email = 'test@example.com'
            ));
        }
        insert contacts;
    }
    
    @isTest
    static void testGetKpiData() {
        Test.startTest();
        DemoKpiService.KpiData data = DemoKpiService.getKpiData();
        Test.stopTest();
        
        // Verify KPI data
        System.assertNotEquals(null, data, 'KPI data should not be null');
        System.assertEquals(5, data.totalOpportunities, 'Should have 5 opportunities');
        System.assertEquals(5, data.totalAccounts, 'Should have 5 accounts');
        System.assertEquals(5, data.totalContacts, 'Should have 5 contacts');
        System.assertEquals(2, data.wonOpportunities, 'Should have 2 won opportunities');
        System.assertEquals(3, data.openOpportunities, 'Should have 3 open opportunities');
        System.assert(data.totalRevenue > 0, 'Total revenue should be greater than 0');
        System.assert(data.averageDealSize > 0, 'Average deal size should be greater than 0');
        System.assert(data.winRate >= 0, 'Win rate should be calculated');
    }
    
    @isTest
    static void testGetPipelineData() {
        Test.startTest();
        DemoKpiService.KpiData data = DemoKpiService.getKpiData();
        Test.stopTest();
        
        // Verify pipeline data
        System.assertNotEquals(null, data.pipelineData, 'Pipeline data should not be null');
        System.assert(data.pipelineData.size() > 0, 'Should have pipeline stages');
        
        for (DemoKpiService.PipelineStage stage : data.pipelineData) {
            System.assertNotEquals(null, stage.stage, 'Stage name should not be null');
            System.assert(stage.count > 0, 'Stage count should be greater than 0');
        }
    }
    
    @isTest
    static void testGetRecentActivities() {
        Test.startTest();
        DemoKpiService.KpiData data = DemoKpiService.getKpiData();
        Test.stopTest();
        
        // Verify recent activities
        System.assertNotEquals(null, data.recentActivities, 'Recent activities should not be null');
        System.assertEquals(5, data.recentActivities.size(), 'Should have 5 recent activities');
        
        for (DemoKpiService.RecentActivity activity : data.recentActivities) {
            System.assertNotEquals(null, activity.id, 'Activity ID should not be null');
            System.assertNotEquals(null, activity.name, 'Activity name should not be null');
            System.assertNotEquals(null, activity.status, 'Activity status should not be null');
        }
    }
    
    @isTest
    static void testCreateSampleOpportunity() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        String oppId = DemoKpiService.createSampleOpportunity(acc.Id);
        Test.stopTest();
        
        // Verify opportunity was created
        System.assertNotEquals(null, oppId, 'Opportunity ID should not be null');
        
        Opportunity opp = [SELECT Id, Name, AccountId, StageName, Amount FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(acc.Id, opp.AccountId, 'Account should match');
        System.assertEquals('Prospecting', opp.StageName, 'Stage should be Prospecting');
        System.assertEquals(75000, opp.Amount, 'Amount should be 75000');
    }
    
    @isTest
    static void testCreateSampleOpportunityNoAccount() {
        // Delete all accounts first
        delete [SELECT Id FROM Account];
        
        Test.startTest();
        String oppId = DemoKpiService.createSampleOpportunity(null);
        Test.stopTest();
        
        // Verify opportunity and account were created
        System.assertNotEquals(null, oppId, 'Opportunity ID should not be null');
        
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId];
        System.assertNotEquals(null, opp.AccountId, 'Account should be created');
        
        Account acc = [SELECT Name FROM Account WHERE Id = :opp.AccountId];
        System.assertEquals('Sample Account', acc.Name, 'Account name should be Sample Account');
    }
}

