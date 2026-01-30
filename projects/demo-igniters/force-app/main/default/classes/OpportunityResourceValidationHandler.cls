/**
 * Handler class for Opportunity Resource Validation trigger
 * Implements business logic for resource forecasting stage gates
 */
public with sharing class OpportunityResourceValidationHandler {
    
    private static final String CLOSED_WON_STAGE = 'Closed Won';
    private static final String ERROR_MESSAGE = 
        'Cannot close opportunity as Won without resource forecasting. ' +
        'Please add at least one Resource Forecast to proceed.';
    
    /**
     * Validates that opportunities moving to Closed Won have resource forecasts
     * @param newOpportunities List of opportunities being updated
     * @param oldOpportunityMap Map of old opportunity values
     */
    public static void validateResourceForecasts(
        List<Opportunity> newOpportunities,
        Map<Id, Opportunity> oldOpportunityMap
    ) {
        // Collect IDs of opportunities moving to Closed Won
        Set<Id> opportunitiesMovingToClosedWon = new Set<Id>();
        
        for (Opportunity opp : newOpportunities) {
            Opportunity oldOpp = oldOpportunityMap.get(opp.Id);
            
            // Check if stage is changing to Closed Won
            if (opp.StageName == CLOSED_WON_STAGE && 
                oldOpp.StageName != CLOSED_WON_STAGE) {
                opportunitiesMovingToClosedWon.add(opp.Id);
            }
        }
        
        // If no opportunities are moving to Closed Won, exit early
        if (opportunitiesMovingToClosedWon.isEmpty()) {
            return;
        }
        
        // Query for resource forecasts
        Map<Id, Integer> opportunityToForecastCount = getResourceForecastCounts(
            opportunitiesMovingToClosedWon
        );
        
        // Add errors to opportunities without forecasts
        for (Opportunity opp : newOpportunities) {
            if (opportunitiesMovingToClosedWon.contains(opp.Id)) {
                Integer forecastCount = opportunityToForecastCount.get(opp.Id);
                
                if (forecastCount == null || forecastCount == 0) {
                    opp.addError(ERROR_MESSAGE);
                }
            }
        }
    }
    
    /**
     * Queries and counts resource forecasts for given opportunities
     * @param opportunityIds Set of opportunity IDs to check
     * @return Map of opportunity ID to count of resource forecasts
     */
    private static Map<Id, Integer> getResourceForecastCounts(Set<Id> opportunityIds) {
        Map<Id, Integer> countMap = new Map<Id, Integer>();
        
        // Aggregate query to count forecasts per opportunity
        List<AggregateResult> results = [
            SELECT Opportunity__c, COUNT(Id) forecastCount
            FROM Resource_Forecast__c
            WHERE Opportunity__c IN :opportunityIds
            GROUP BY Opportunity__c
        ];
        
        for (AggregateResult result : results) {
            Id oppId = (Id) result.get('Opportunity__c');
            Integer count = (Integer) result.get('forecastCount');
            countMap.put(oppId, count);
        }
        
        return countMap;
    }
    
    /**
     * Checks if a specific opportunity has resource forecasts
     * Utility method for external validation
     * @param opportunityId The opportunity ID to check
     * @return True if the opportunity has at least one resource forecast
     */
    public static Boolean hasResourceForecasts(Id opportunityId) {
        Integer count = [
            SELECT COUNT() 
            FROM Resource_Forecast__c 
            WHERE Opportunity__c = :opportunityId
        ];
        return count > 0;
    }
}
