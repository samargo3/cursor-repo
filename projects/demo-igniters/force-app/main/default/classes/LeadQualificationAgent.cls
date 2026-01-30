/**
 * @description Agent for intelligent lead qualification and scoring
 * @author Solution Engineering Team
 * @version 1.0
 */
public with sharing class LeadQualificationAgent extends AgentActionController implements AgentAction {
    
    public class QualificationResult {
        @AuraEnabled public Decimal score { get; set; }
        @AuraEnabled public String grade { get; set; }
        @AuraEnabled public List<String> strengths { get; set; }
        @AuraEnabled public List<String> recommendations { get; set; }
        @AuraEnabled public String nextAction { get; set; }
        
        public QualificationResult() {
            this.strengths = new List<String>();
            this.recommendations = new List<String>();
        }
    }
    
    /**
     * @description Qualify a lead based on multiple criteria
     * @param leadId The ID of the lead to qualify
     * @return AgentResponse with qualification results
     */
    @AuraEnabled(cacheable=false)
    public static AgentResponse qualifyLead(Id leadId) {
        try {
            // Validate input
            if (leadId == null) {
                return createErrorResponse('Lead ID is required', new List<String>{'Lead ID cannot be null'});
            }
            
            // Query lead with related data
            List<Lead> leads = [
                SELECT Id, FirstName, LastName, Company, Email, Phone, Industry, 
                       AnnualRevenue, NumberOfEmployees, Status, Rating, LeadSource,
                       CreatedDate, LastModifiedDate, OwnerId, Owner.Name
                FROM Lead 
                WHERE Id = :leadId 
                LIMIT 1
            ];
            
            if (leads.isEmpty()) {
                return createErrorResponse('Lead not found', new List<String>{'Lead with ID ' + leadId + ' not found'});
            }
            
            Lead lead = leads[0];
            QualificationResult result = calculateQualificationScore(lead);
            
            // Update lead with qualification results
            lead.Rating = result.grade;
            update lead;
            
            return createSuccessResponse('Lead qualified successfully', result);
            
        } catch (Exception e) {
            return createErrorResponse('Error qualifying lead: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Batch qualify multiple leads
     * @param leadIds List of lead IDs to qualify
     * @return AgentResponse with batch results
     */
    @AuraEnabled(cacheable=false)
    public static AgentResponse batchQualifyLeads(List<Id> leadIds) {
        try {
            if (leadIds == null || leadIds.isEmpty()) {
                return createErrorResponse('Lead IDs are required', new List<String>{'Lead IDs list cannot be empty'});
            }
            
            List<Lead> leads = [
                SELECT Id, FirstName, LastName, Company, Email, Phone, Industry, 
                       AnnualRevenue, NumberOfEmployees, Status, Rating, LeadSource,
                       CreatedDate, LastModifiedDate, OwnerId, Owner.Name
                FROM Lead 
                WHERE Id IN :leadIds
            ];
            
            List<QualificationResult> results = new List<QualificationResult>();
            List<Lead> leadsToUpdate = new List<Lead>();
            
            for (Lead lead : leads) {
                QualificationResult result = calculateQualificationScore(lead);
                results.add(result);
                
                // Update lead rating
                lead.Rating = result.grade;
                leadsToUpdate.add(lead);
            }
            
            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
            }
            
            return createSuccessResponse('Batch qualification completed', results);
            
        } catch (Exception e) {
            return createErrorResponse('Error in batch qualification: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Get qualification insights for a lead
     * @param leadId The ID of the lead
     * @return AgentResponse with insights
     */
    @AuraEnabled(cacheable=true)
    public static AgentResponse getQualificationInsights(Id leadId) {
        try {
            List<Lead> leads = [
                SELECT Id, FirstName, LastName, Company, Industry, AnnualRevenue, 
                       NumberOfEmployees, LeadSource, Status, Rating, CreatedDate
                FROM Lead 
                WHERE Id = :leadId 
                LIMIT 1
            ];
            
            if (leads.isEmpty()) {
                return createErrorResponse('Lead not found', new List<String>{'Lead not found'});
            }
            
            Lead lead = leads[0];
            Map<String, Object> insights = generateInsights(lead);
            
            return createSuccessResponse('Insights generated successfully', insights);
            
        } catch (Exception e) {
            return createErrorResponse('Error generating insights: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Calculate qualification score for a lead
     */
    private static QualificationResult calculateQualificationScore(Lead lead) {
        QualificationResult result = new QualificationResult();
        Decimal score = 0;
        List<String> strengths = new List<String>();
        List<String> recommendations = new List<String>();
        
        // Company size scoring (0-25 points)
        if (lead.NumberOfEmployees != null) {
            if (lead.NumberOfEmployees >= 1000) {
                score += 25;
                strengths.add('Large company size (' + lead.NumberOfEmployees + ' employees)');
            } else if (lead.NumberOfEmployees >= 100) {
                score += 15;
                strengths.add('Medium company size (' + lead.NumberOfEmployees + ' employees)');
            } else if (lead.NumberOfEmployees >= 10) {
                score += 10;
                strengths.add('Small company size (' + lead.NumberOfEmployees + ' employees)');
            } else {
                recommendations.add('Consider company size for qualification');
            }
        } else {
            recommendations.add('Gather company size information');
        }
        
        // Revenue scoring (0-25 points)
        if (lead.AnnualRevenue != null) {
            if (lead.AnnualRevenue >= 10000000) {
                score += 25;
                strengths.add('High revenue potential ($' + formatCurrency(lead.AnnualRevenue) + ')');
            } else if (lead.AnnualRevenue >= 1000000) {
                score += 15;
                strengths.add('Good revenue potential ($' + formatCurrency(lead.AnnualRevenue) + ')');
            } else if (lead.AnnualRevenue >= 100000) {
                score += 10;
                strengths.add('Moderate revenue potential ($' + formatCurrency(lead.AnnualRevenue) + ')');
            }
        } else {
            recommendations.add('Gather revenue information');
        }
        
        // Contact completeness (0-20 points)
        if (String.isNotBlank(lead.Email) && String.isNotBlank(lead.Phone)) {
            score += 20;
            strengths.add('Complete contact information available');
        } else if (String.isNotBlank(lead.Email) || String.isNotBlank(lead.Phone)) {
            score += 10;
            recommendations.add('Complete contact information (missing phone or email)');
        } else {
            recommendations.add('Gather contact information');
        }
        
        // Industry scoring (0-15 points)
        if (String.isNotBlank(lead.Industry)) {
            score += 15;
            strengths.add('Industry identified: ' + lead.Industry);
        } else {
            recommendations.add('Identify industry for better targeting');
        }
        
        // Lead source scoring (0-15 points)
        if (String.isNotBlank(lead.LeadSource)) {
            score += 15;
            strengths.add('Lead source identified: ' + lead.LeadSource);
        } else {
            recommendations.add('Track lead source for attribution');
        }
        
        result.score = score;
        result.strengths = strengths;
        result.recommendations = recommendations;
        
        // Determine grade and next action
        if (score >= 80) {
            result.grade = 'A';
            result.nextAction = 'Immediate follow-up - High priority lead';
        } else if (score >= 60) {
            result.grade = 'B';
            result.nextAction = 'Schedule follow-up within 24 hours';
        } else if (score >= 40) {
            result.grade = 'C';
            result.nextAction = 'Nurture campaign - Follow up in 1 week';
        } else {
            result.grade = 'D';
            result.nextAction = 'Qualify further or consider disqualifying';
        }
        
        return result;
    }
    
    /**
     * @description Generate insights for a lead
     */
    private static Map<String, Object> generateInsights(Lead lead) {
        Map<String, Object> insights = new Map<String, Object>();
        
        // Similar leads analysis
        List<Lead> similarLeads = [
            SELECT Id, Company, Industry, AnnualRevenue, Status, Rating
            FROM Lead 
            WHERE Industry = :lead.Industry 
            AND Id != :lead.Id
            AND CreatedDate = LAST_N_DAYS:90
            LIMIT 5
        ];
        
        insights.put('similarLeads', similarLeads.size());
        
        // Industry performance
        List<AggregateResult> industryStats = [
            SELECT COUNT(Id) leadCount, AVG(AnnualRevenue) avgRevenue
            FROM Lead 
            WHERE Industry = :lead.Industry 
            AND CreatedDate = LAST_N_DAYS:90
        ];
        
        if (!industryStats.isEmpty()) {
            insights.put('industryLeadCount', industryStats[0].get('leadCount'));
            insights.put('industryAvgRevenue', industryStats[0].get('avgRevenue'));
        }
        
        // Time-based insights
        insights.put('daysSinceCreated', Date.today().daysBetween(lead.CreatedDate.date()));
        
        return insights;
    }
    
    /**
     * @description Format currency for display
     */
    private static String formatCurrency(Decimal amount) {
        if (amount == null) return '0';
        return String.valueOf(amount.format());
    }
    
    // AgentAction interface implementation
    public AgentResponse execute(Map<String, Object> parameters) {
        if (parameters.containsKey('leadId')) {
            return qualifyLead((Id) parameters.get('leadId'));
        } else if (parameters.containsKey('leadIds')) {
            return batchQualifyLeads((List<Id>) parameters.get('leadIds'));
        } else {
            return createErrorResponse('Invalid parameters', new List<String>{'leadId or leadIds required'});
        }
    }
    
    public String getActionName() {
        return 'LeadQualification';
    }
    
    public String getDescription() {
        return 'Intelligent lead qualification and scoring based on multiple business criteria';
    }
    
    public List<String> getRequiredParameters() {
        return new List<String>{'leadId'};
    }
}
