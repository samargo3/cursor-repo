/**
 * Test class for OpportunityResourceValidationHandler and trigger
 */
@isTest
private class OpportunityResourceValidationTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test opportunities
        List<Opportunity> testOpps = new List<Opportunity>();
        
        // Opportunity with forecasts
        testOpps.add(new Opportunity(
            Name = 'Opportunity With Forecasts',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 100000
        ));
        
        // Opportunity without forecasts
        testOpps.add(new Opportunity(
            Name = 'Opportunity Without Forecasts',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 50000
        ));
        
        insert testOpps;
        
        // Add forecasts to first opportunity only
        List<Resource_Forecast__c> forecasts = new List<Resource_Forecast__c>();
        
        forecasts.add(new Resource_Forecast__c(
            Opportunity__c = testOpps[0].Id,
            Role__c = 'PMO',
            Expected_Hours__c = 100,
            Hourly_Cost__c = 150
        ));
        
        forecasts.add(new Resource_Forecast__c(
            Opportunity__c = testOpps[0].Id,
            Role__c = 'Technical Lead',
            Expected_Hours__c = 200,
            Hourly_Cost__c = 200
        ));
        
        insert forecasts;
    }
    
    @isTest
    static void testCloseWonWithForecasts_Success() {
        // Get opportunity with forecasts
        Opportunity opp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Name = 'Opportunity With Forecasts' 
            LIMIT 1
        ];
        
        // Update to Closed Won
        opp.StageName = 'Closed Won';
        
        Test.startTest();
        Database.SaveResult result = Database.update(opp, false);
        Test.stopTest();
        
        // Assertions
        System.assert(result.isSuccess(), 'Update should succeed');
        
        // Verify opportunity is closed won
        Opportunity updatedOpp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Id = :opp.Id
        ];
        System.assertEquals('Closed Won', updatedOpp.StageName, 
            'Opportunity should be Closed Won');
    }
    
    @isTest
    static void testCloseWonWithoutForecasts_Failure() {
        // Get opportunity without forecasts
        Opportunity opp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Name = 'Opportunity Without Forecasts' 
            LIMIT 1
        ];
        
        // Try to update to Closed Won
        opp.StageName = 'Closed Won';
        
        Test.startTest();
        Database.SaveResult result = Database.update(opp, false);
        Test.stopTest();
        
        // Assertions
        System.assert(!result.isSuccess(), 'Update should fail');
        System.assert(result.getErrors().size() > 0, 'Should have errors');
        
        String errorMessage = result.getErrors()[0].getMessage();
        System.assert(errorMessage.contains('resource forecasting'), 
            'Error should mention resource forecasting');
        
        // Verify opportunity is still in original stage
        Opportunity updatedOpp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Id = :opp.Id
        ];
        System.assertEquals('Prospecting', updatedOpp.StageName, 
            'Opportunity should still be in Prospecting');
    }
    
    @isTest
    static void testUpdateOtherFields_Success() {
        // Get opportunity without forecasts
        Opportunity opp = [
            SELECT Id, StageName, Amount 
            FROM Opportunity 
            WHERE Name = 'Opportunity Without Forecasts' 
            LIMIT 1
        ];
        
        // Update other fields (not stage)
        opp.Amount = 75000;
        
        Test.startTest();
        Database.SaveResult result = Database.update(opp, false);
        Test.stopTest();
        
        // Assertions
        System.assert(result.isSuccess(), 
            'Update of non-stage fields should succeed even without forecasts');
        
        // Verify update
        Opportunity updatedOpp = [
            SELECT Id, Amount 
            FROM Opportunity 
            WHERE Id = :opp.Id
        ];
        System.assertEquals(75000, updatedOpp.Amount, 'Amount should be updated');
    }
    
    @isTest
    static void testUpdateToNonClosedWonStage_Success() {
        // Get opportunity without forecasts
        Opportunity opp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Name = 'Opportunity Without Forecasts' 
            LIMIT 1
        ];
        
        // Update to non-Closed Won stage
        opp.StageName = 'Qualification';
        
        Test.startTest();
        Database.SaveResult result = Database.update(opp, false);
        Test.stopTest();
        
        // Assertions
        System.assert(result.isSuccess(), 
            'Update to non-Closed Won stage should succeed without forecasts');
        
        // Verify update
        Opportunity updatedOpp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Id = :opp.Id
        ];
        System.assertEquals('Qualification', updatedOpp.StageName, 
            'Stage should be updated to Qualification');
    }
    
    @isTest
    static void testAlreadyClosedWon_NoValidation() {
        // Get opportunity with forecasts and close it
        Opportunity opp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Name = 'Opportunity With Forecasts' 
            LIMIT 1
        ];
        
        opp.StageName = 'Closed Won';
        update opp;
        
        // Delete all forecasts
        delete [SELECT Id FROM Resource_Forecast__c WHERE Opportunity__c = :opp.Id];
        
        // Update amount while already Closed Won
        opp.Amount = 150000;
        
        Test.startTest();
        Database.SaveResult result = Database.update(opp, false);
        Test.stopTest();
        
        // Assertions
        System.assert(result.isSuccess(), 
            'Update should succeed when already Closed Won, even without forecasts');
    }
    
    @isTest
    static void testBulkCloseWon_Mixed() {
        // Get both opportunities
        List<Opportunity> opps = [
            SELECT Id, Name, StageName 
            FROM Opportunity 
            ORDER BY Name
        ];
        
        // Try to close both
        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
        }
        
        Test.startTest();
        List<Database.SaveResult> results = Database.update(opps, false);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(2, results.size(), 'Should have 2 results');
        
        // First opportunity (with forecasts) should succeed
        System.assert(results[0].isSuccess() || results[1].isSuccess(), 
            'One opportunity should succeed');
        
        // Second opportunity (without forecasts) should fail
        System.assert(!results[0].isSuccess() || !results[1].isSuccess(), 
            'One opportunity should fail');
    }
    
    @isTest
    static void testHasResourceForecasts() {
        // Get both opportunities
        Opportunity oppWithForecasts = [
            SELECT Id 
            FROM Opportunity 
            WHERE Name = 'Opportunity With Forecasts' 
            LIMIT 1
        ];
        
        Opportunity oppWithoutForecasts = [
            SELECT Id 
            FROM Opportunity 
            WHERE Name = 'Opportunity Without Forecasts' 
            LIMIT 1
        ];
        
        Test.startTest();
        Boolean hasForecasts1 = OpportunityResourceValidationHandler.hasResourceForecasts(
            oppWithForecasts.Id
        );
        Boolean hasForecasts2 = OpportunityResourceValidationHandler.hasResourceForecasts(
            oppWithoutForecasts.Id
        );
        Test.stopTest();
        
        // Assertions
        System.assert(hasForecasts1, 'Should have forecasts');
        System.assert(!hasForecasts2, 'Should not have forecasts');
    }
    
    @isTest
    static void testAddForecastThenCloseWon() {
        // Get opportunity without forecasts
        Opportunity opp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Name = 'Opportunity Without Forecasts' 
            LIMIT 1
        ];
        
        // Add a forecast
        Resource_Forecast__c forecast = new Resource_Forecast__c(
            Opportunity__c = opp.Id,
            Role__c = 'Developer',
            Expected_Hours__c = 100,
            Hourly_Cost__c = 125
        );
        insert forecast;
        
        // Now try to close as won
        opp.StageName = 'Closed Won';
        
        Test.startTest();
        Database.SaveResult result = Database.update(opp, false);
        Test.stopTest();
        
        // Assertions
        System.assert(result.isSuccess(), 
            'Update should succeed after adding forecast');
        
        // Verify opportunity is closed won
        Opportunity updatedOpp = [
            SELECT Id, StageName 
            FROM Opportunity 
            WHERE Id = :opp.Id
        ];
        System.assertEquals('Closed Won', updatedOpp.StageName, 
            'Opportunity should be Closed Won');
    }
}
