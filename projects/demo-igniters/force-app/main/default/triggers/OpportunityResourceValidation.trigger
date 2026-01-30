/**
 * Trigger to enforce resource forecasting requirements on opportunities
 * Prevents moving to Closed Won without at least one Resource Forecast
 */
trigger OpportunityResourceValidation on Opportunity (before update) {
    OpportunityResourceValidationHandler.validateResourceForecasts(Trigger.new, Trigger.oldMap);
}
