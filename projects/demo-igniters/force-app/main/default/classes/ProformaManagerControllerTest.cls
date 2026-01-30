/**
 * Test class for ProformaManagerController
 */
@isTest
private class ProformaManagerControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 100000
        );
        insert testOpp;
        
        // Create test resource forecasts
        List<Resource_Forecast__c> forecasts = new List<Resource_Forecast__c>();
        
        forecasts.add(new Resource_Forecast__c(
            Opportunity__c = testOpp.Id,
            Role__c = 'PMO',
            Expected_Hours__c = 100,
            Hourly_Cost__c = 150
        ));
        
        forecasts.add(new Resource_Forecast__c(
            Opportunity__c = testOpp.Id,
            Role__c = 'Technical Lead',
            Expected_Hours__c = 200,
            Hourly_Cost__c = 200
        ));
        
        insert forecasts;
    }
    
    @isTest
    static void testGetProformaData() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        ProformaManagerController.ProformaData data = 
            ProformaManagerController.getProformaData(testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, data, 'Data should not be null');
        System.assertNotEquals(null, data.opportunity, 'Opportunity should not be null');
        System.assertEquals(2, data.resourceForecasts.size(), 'Should have 2 forecasts');
        System.assertEquals(100000, data.opportunity.Amount, 'Amount should be 100000');
        System.assertEquals(55000, data.opportunity.Total_Resource_Cost__c, 
            'Total resource cost should be 55000 (100*150 + 200*200)');
    }
    
    @isTest
    static void testGetProformaDataInvalidId() {
        // Use a non-existent ID
        Id fakeId = '006000000000000AAA';
        
        Test.startTest();
        try {
            ProformaManagerController.ProformaData data = 
                ProformaManagerController.getProformaData(fakeId);
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            // Can be AuraHandledException or other exception
            System.assertNotEquals(null, e.getMessage(), 
                'Should have error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetRolePicklistValues() {
        Test.startTest();
        List<ProformaManagerController.PicklistOption> options = 
            ProformaManagerController.getRolePicklistValues();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should have picklist values');
        
        // Check for expected roles
        Set<String> roleValues = new Set<String>();
        for (ProformaManagerController.PicklistOption option : options) {
            roleValues.add(option.value);
        }
        
        System.assert(roleValues.contains('PMO'), 'Should contain PMO role');
        System.assert(roleValues.contains('Technical Lead'), 'Should contain Technical Lead role');
    }
    
    @isTest
    static void testSaveResourceForecasts() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Create new forecast to insert
        List<Resource_Forecast__c> forecastsToSave = new List<Resource_Forecast__c>();
        forecastsToSave.add(new Resource_Forecast__c(
            Role__c = 'Developer',
            Expected_Hours__c = 150,
            Hourly_Cost__c = 125
        ));
        
        Test.startTest();
        List<Resource_Forecast__c> savedForecasts = 
            ProformaManagerController.saveResourceForecasts(
                forecastsToSave, 
                testOpp.Id
            );
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, savedForecasts.size(), 'Should have 1 saved forecast');
        System.assertNotEquals(null, savedForecasts[0].Id, 'Should have an ID');
        System.assertEquals('Developer', savedForecasts[0].Role__c, 'Role should be Developer');
        System.assertEquals(18750, savedForecasts[0].Total_Estimated_Cost__c, 
            'Total should be 18750 (150*125)');
    }
    
    @isTest
    static void testUpdateResourceForecasts() {
        // Get existing forecast - without Opportunity__c to avoid master-detail update issues
        List<Resource_Forecast__c> existingForecasts = [
            SELECT Id, Role__c, Expected_Hours__c, Hourly_Cost__c
            FROM Resource_Forecast__c 
            WHERE Role__c = 'PMO' 
            LIMIT 1
        ];
        
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Create a new forecast object with updated values
        Resource_Forecast__c forecastToUpdate = new Resource_Forecast__c(
            Id = existingForecasts[0].Id,
            Role__c = 'PMO',
            Expected_Hours__c = 120,
            Hourly_Cost__c = 160
        );
        
        Test.startTest();
        List<Resource_Forecast__c> savedForecasts = 
            ProformaManagerController.saveResourceForecasts(
                new List<Resource_Forecast__c>{ forecastToUpdate }, 
                testOpp.Id
            );
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, savedForecasts.size(), 'Should have 1 saved forecast');
        System.assertEquals(forecastToUpdate.Id, savedForecasts[0].Id, 'Should be same record');
        System.assertEquals(120, savedForecasts[0].Expected_Hours__c, 'Hours should be updated');
        System.assertEquals(19200, savedForecasts[0].Total_Estimated_Cost__c, 
            'Total should be 19200 (120*160)');
    }
    
    @isTest
    static void testDeleteResourceForecast() {
        // Get existing forecast
        Resource_Forecast__c forecastToDelete = [
            SELECT Id 
            FROM Resource_Forecast__c 
            WHERE Role__c = 'PMO' 
            LIMIT 1
        ];
        
        Id forecastId = forecastToDelete.Id;
        
        Test.startTest();
        ProformaManagerController.deleteResourceForecast(forecastId);
        Test.stopTest();
        
        // Verify deletion
        List<Resource_Forecast__c> remainingForecasts = [
            SELECT Id 
            FROM Resource_Forecast__c 
            WHERE Id = :forecastId
        ];
        
        System.assertEquals(0, remainingForecasts.size(), 'Forecast should be deleted');
    }
    
    @isTest
    static void testDeleteInvalidForecast() {
        // Use a non-existent ID
        Id fakeId = Schema.SObjectType.Resource_Forecast__c.getKeyPrefix() + '000000000000AAA';
        
        Test.startTest();
        try {
            ProformaManagerController.deleteResourceForecast(fakeId);
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            // Can be AuraHandledException or DmlException
            System.assertNotEquals(null, e.getMessage(), 
                'Should have error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveMultipleForecasts() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Create multiple forecasts
        List<Resource_Forecast__c> forecastsToSave = new List<Resource_Forecast__c>();
        
        forecastsToSave.add(new Resource_Forecast__c(
            Role__c = 'Solution Architect',
            Expected_Hours__c = 80,
            Hourly_Cost__c = 175
        ));
        
        forecastsToSave.add(new Resource_Forecast__c(
            Role__c = 'Business Analyst',
            Expected_Hours__c = 120,
            Hourly_Cost__c = 125
        ));
        
        forecastsToSave.add(new Resource_Forecast__c(
            Role__c = 'QA Engineer',
            Expected_Hours__c = 60,
            Hourly_Cost__c = 100
        ));
        
        Test.startTest();
        List<Resource_Forecast__c> savedForecasts = 
            ProformaManagerController.saveResourceForecasts(
                forecastsToSave, 
                testOpp.Id
            );
        Test.stopTest();
        
        // Assertions
        System.assertEquals(3, savedForecasts.size(), 'Should have 3 saved forecasts');
        
        // Verify all have IDs
        for (Resource_Forecast__c forecast : savedForecasts) {
            System.assertNotEquals(null, forecast.Id, 'All forecasts should have IDs');
        }
        
        // Query to verify opportunity link
        List<Resource_Forecast__c> verifyForecasts = [
            SELECT Id, Opportunity__c 
            FROM Resource_Forecast__c 
            WHERE Id IN :savedForecasts
        ];
        for (Resource_Forecast__c forecast : verifyForecasts) {
            System.assertEquals(testOpp.Id, forecast.Opportunity__c, 
                'All should be linked to test opportunity');
        }
    }
}
