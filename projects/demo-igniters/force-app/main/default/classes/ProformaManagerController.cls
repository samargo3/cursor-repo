/**
 * Controller for the Proforma Manager Lightning Web Component
 * Handles CRUD operations for Resource Forecast records
 */
public with sharing class ProformaManagerController {
    
    /**
     * Retrieves resource forecasts and opportunity data for a given opportunity
     * @param opportunityId The ID of the opportunity
     * @return ProformaData wrapper containing forecasts and opportunity info
     */
    @AuraEnabled(cacheable=true)
    public static ProformaData getProformaData(Id opportunityId) {
        try {
            ProformaData data = new ProformaData();
            
            // Query opportunity with relevant fields
            List<Opportunity> opps = [
                SELECT Id, Name, Amount, Total_Resource_Cost__c, StageName
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
            ];
            
            if (opps.isEmpty()) {
                throw new AuraHandledException('Opportunity not found');
            }
            
            data.opportunity = opps[0];
            
            // Query resource forecasts
            data.resourceForecasts = [
                SELECT Id, Role__c, Expected_Hours__c, Hourly_Cost__c, 
                       Total_Estimated_Cost__c, CreatedDate
                FROM Resource_Forecast__c
                WHERE Opportunity__c = :opportunityId
                ORDER BY CreatedDate ASC
            ];
            
            return data;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving proforma data: ' + e.getMessage());
        }
    }
    
    /**
     * Retrieves the picklist values for the Role field
     * @return List of picklist options
     */
    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getRolePicklistValues() {
        List<PicklistOption> options = new List<PicklistOption>();
        
        Schema.DescribeFieldResult fieldResult = Resource_Forecast__c.Role__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                options.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
        }
        
        return options;
    }
    
    /**
     * Saves (insert or update) resource forecast records
     * @param forecasts List of resource forecasts to save
     * @param opportunityId The parent opportunity ID
     * @return List of saved forecasts with IDs
     */
    @AuraEnabled
    public static List<Resource_Forecast__c> saveResourceForecasts(
        List<Resource_Forecast__c> forecasts, 
        Id opportunityId
    ) {
        try {
            List<Resource_Forecast__c> forecastsToUpsert = new List<Resource_Forecast__c>();
            
            for (Resource_Forecast__c forecast : forecasts) {
                // Only set opportunity relationship for new records (no Id)
                if (forecast.Id == null) {
                    forecast.Opportunity__c = opportunityId;
                }
                forecastsToUpsert.add(forecast);
            }
            
            upsert forecastsToUpsert;
            
            // Return updated records with calculated fields
            return [
                SELECT Id, Role__c, Expected_Hours__c, Hourly_Cost__c, 
                       Total_Estimated_Cost__c, CreatedDate
                FROM Resource_Forecast__c
                WHERE Id IN :forecastsToUpsert
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error saving resource forecasts: ' + e.getMessage());
        }
    }
    
    /**
     * Deletes a resource forecast record
     * @param forecastId The ID of the forecast to delete
     */
    @AuraEnabled
    public static void deleteResourceForecast(Id forecastId) {
        try {
            delete new Resource_Forecast__c(Id = forecastId);
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting resource forecast: ' + e.getMessage());
        }
    }
    
    /**
     * Wrapper class for proforma data
     */
    public class ProformaData {
        @AuraEnabled public Opportunity opportunity { get; set; }
        @AuraEnabled public List<Resource_Forecast__c> resourceForecasts { get; set; }
        
        public ProformaData() {
            this.resourceForecasts = new List<Resource_Forecast__c>();
        }
    }
    
    /**
     * Wrapper class for picklist options
     */
    public class PicklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        
        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}
