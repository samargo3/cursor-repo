/**
 * @description Agent for opportunity analysis and actionable insights
 * @author Solution Engineering Team
 * @version 1.0
 */
public with sharing class OpportunityInsightAgent extends AgentActionController implements AgentAction {
    
    public class OpportunityInsight {
        @AuraEnabled public String opportunityId { get; set; }
        @AuraEnabled public String opportunityName { get; set; }
        @AuraEnabled public Decimal winProbability { get; set; }
        @AuraEnabled public String riskLevel { get; set; }
        @AuraEnabled public List<String> riskFactors { get; set; }
        @AuraEnabled public List<String> recommendations { get; set; }
        @AuraEnabled public String nextBestAction { get; set; }
        @AuraEnabled public Decimal daysToClose { get; set; }
        @AuraEnabled public String urgencyLevel { get; set; }
        
        public OpportunityInsight() {
            this.riskFactors = new List<String>();
            this.recommendations = new List<String>();
        }
    }
    
    public class PipelineInsight {
        @AuraEnabled public Decimal totalPipelineValue { get; set; }
        @AuraEnabled public Decimal weightedPipelineValue { get; set; }
        @AuraEnabled public Integer totalOpportunities { get; set; }
        @AuraEnabled public Decimal averageDealSize { get; set; }
        @AuraEnabled public Decimal closeRate { get; set; }
        @AuraEnabled public List<String> topRisks { get; set; }
        @AuraEnabled public List<String> topRecommendations { get; set; }
        
        public PipelineInsight() {
            this.topRisks = new List<String>();
            this.topRecommendations = new List<String>();
        }
    }
    
    /**
     * @description Analyze a single opportunity for insights
     * @param opportunityId The ID of the opportunity to analyze
     * @return AgentResponse with opportunity insights
     */
    @AuraEnabled(cacheable=false)
    public static AgentResponse analyzeOpportunity(Id opportunityId) {
        try {
            if (opportunityId == null) {
                return createErrorResponse('Opportunity ID is required', new List<String>{'Opportunity ID cannot be null'});
            }
            
            List<Opportunity> opportunities = [
                SELECT Id, Name, Amount, CloseDate, StageName, Probability, 
                       Type, LeadSource, OwnerId, Owner.Name, CreatedDate,
                       LastModifiedDate, Description, NextStep
                FROM Opportunity 
                WHERE Id = :opportunityId 
                LIMIT 1
            ];
            
            if (opportunities.isEmpty()) {
                return createErrorResponse('Opportunity not found', new List<String>{'Opportunity with ID ' + opportunityId + ' not found'});
            }
            
            Opportunity opp = opportunities[0];
            OpportunityInsight insight = generateOpportunityInsight(opp);
            
            return createSuccessResponse('Opportunity analysis completed', insight);
            
        } catch (Exception e) {
            return createErrorResponse('Error analyzing opportunity: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Analyze pipeline for overall insights
     * @param ownerId Optional owner ID to filter by specific user
     * @return AgentResponse with pipeline insights
     */
    @AuraEnabled(cacheable=true)
    public static AgentResponse analyzePipeline(Id ownerId) {
        try {
            String soql = 'SELECT Id, Name, Amount, CloseDate, StageName, Probability, Type, OwnerId, Owner.Name ' +
                         'FROM Opportunity ' +
                         'WHERE IsClosed = false ';
            
            if (ownerId != null) {
                soql += 'AND OwnerId = :ownerId ';
            }
            
            soql += 'ORDER BY Amount DESC';
            
            List<Opportunity> opportunities = Database.query(soql);
            
            PipelineInsight insight = generatePipelineInsight(opportunities);
            
            return createSuccessResponse('Pipeline analysis completed', insight);
            
        } catch (Exception e) {
            return createErrorResponse('Error analyzing pipeline: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Get opportunities at risk
     * @param ownerId Optional owner ID to filter by specific user
     * @return AgentResponse with at-risk opportunities
     */
    @AuraEnabled(cacheable=true)
    public static AgentResponse getAtRiskOpportunities(Id ownerId) {
        try {
            String soql = 'SELECT Id, Name, Amount, CloseDate, StageName, Probability, OwnerId, Owner.Name ' +
                         'FROM Opportunity ' +
                         'WHERE IsClosed = false AND (Probability < 30 OR CloseDate < :nextWeek) ';
            
            if (ownerId != null) {
                soql += 'AND OwnerId = :ownerId ';
            }
            
            soql += 'ORDER BY CloseDate ASC';
            
            Date nextWeek = Date.today().addDays(7);
            List<Opportunity> opportunities = Database.query(soql);
            
            List<OpportunityInsight> insights = new List<OpportunityInsight>();
            for (Opportunity opp : opportunities) {
                insights.add(generateOpportunityInsight(opp));
            }
            
            return createSuccessResponse('At-risk opportunities identified', insights);
            
        } catch (Exception e) {
            return createErrorResponse('Error identifying at-risk opportunities: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Generate insights for a single opportunity
     */
    private static OpportunityInsight generateOpportunityInsight(Opportunity opp) {
        OpportunityInsight insight = new OpportunityInsight();
        insight.opportunityId = opp.Id;
        insight.opportunityName = opp.Name;
        insight.winProbability = opp.Probability;
        insight.daysToClose = Date.today().daysBetween(opp.CloseDate);
        
        // Risk assessment
        List<String> riskFactors = new List<String>();
        List<String> recommendations = new List<String>();
        
        // Probability risk
        if (opp.Probability < 20) {
            riskFactors.add('Very low win probability (' + opp.Probability + '%)');
            recommendations.add('Review qualification criteria and consider disqualifying');
        } else if (opp.Probability < 40) {
            riskFactors.add('Low win probability (' + opp.Probability + '%)');
            recommendations.add('Strengthen value proposition and stakeholder engagement');
        }
        
        // Timeline risk
        if (opp.CloseDate < Date.today().addDays(7)) {
            riskFactors.add('Closing within 7 days');
            recommendations.add('Accelerate decision-making process');
        } else if (opp.CloseDate < Date.today().addDays(30)) {
            riskFactors.add('Closing within 30 days');
            recommendations.add('Ensure all stakeholders are engaged');
        }
        
        // Amount risk
        if (opp.Amount != null && opp.Amount > 100000) {
            riskFactors.add('High-value opportunity');
            recommendations.add('Ensure executive sponsorship and detailed proposal');
        }
        
        // Stage risk
        if (opp.StageName == 'Prospecting' || opp.StageName == 'Qualification') {
            riskFactors.add('Early stage opportunity');
            recommendations.add('Focus on qualification and stakeholder mapping');
        }
        
        insight.riskFactors = riskFactors;
        insight.recommendations = recommendations;
        
        // Determine risk level
        if (riskFactors.size() >= 3) {
            insight.riskLevel = 'High';
            insight.nextBestAction = 'Immediate intervention required';
        } else if (riskFactors.size() >= 2) {
            insight.riskLevel = 'Medium';
            insight.nextBestAction = 'Schedule review meeting';
        } else if (riskFactors.size() == 1) {
            insight.riskLevel = 'Low';
            insight.nextBestAction = 'Monitor and follow up';
        } else {
            insight.riskLevel = 'Low';
            insight.nextBestAction = 'Continue current approach';
        }
        
        // Determine urgency
        if (opp.CloseDate < Date.today().addDays(7)) {
            insight.urgencyLevel = 'Critical';
        } else if (opp.CloseDate < Date.today().addDays(30)) {
            insight.urgencyLevel = 'High';
        } else if (opp.CloseDate < Date.today().addDays(90)) {
            insight.urgencyLevel = 'Medium';
        } else {
            insight.urgencyLevel = 'Low';
        }
        
        return insight;
    }
    
    /**
     * @description Generate pipeline insights
     */
    private static PipelineInsight generatePipelineInsight(List<Opportunity> opportunities) {
        PipelineInsight insight = new PipelineInsight();
        
        Decimal totalValue = 0;
        Decimal weightedValue = 0;
        Integer totalCount = opportunities.size();
        Integer closedWonCount = 0;
        
        List<String> allRisks = new List<String>();
        List<String> allRecommendations = new List<String>();
        
        for (Opportunity opp : opportunities) {
            if (opp.Amount != null) {
                totalValue += opp.Amount;
                weightedValue += (opp.Amount * (opp.Probability / 100));
            }
            
            // Count closed won (simplified - in real scenario, query closed won separately)
            if (opp.StageName == 'Closed Won') {
                closedWonCount++;
            }
            
            // Collect risks and recommendations
            OpportunityInsight oppInsight = generateOpportunityInsight(opp);
            allRisks.addAll(oppInsight.riskFactors);
            allRecommendations.addAll(oppInsight.recommendations);
        }
        
        insight.totalPipelineValue = totalValue;
        insight.weightedPipelineValue = weightedValue;
        insight.totalOpportunities = totalCount;
        insight.averageDealSize = totalCount > 0 ? totalValue / totalCount : 0;
        insight.closeRate = totalCount > 0 ? (Decimal.valueOf(closedWonCount) / totalCount) * 100 : 0;
        
        // Get top risks and recommendations
        insight.topRisks = getTopItems(allRisks, 5);
        insight.topRecommendations = getTopItems(allRecommendations, 5);
        
        return insight;
    }
    
    /**
     * @description Get top items from a list (simplified frequency analysis)
     */
    private static List<String> getTopItems(List<String> items, Integer limitCount) {
        Map<String, Integer> frequency = new Map<String, Integer>();
        
        for (String item : items) {
            frequency.put(item, frequency.get(item) == null ? 1 : frequency.get(item) + 1);
        }
        
        List<String> sortedItems = new List<String>(frequency.keySet());
        sortedItems.sort(new FrequencyComparator(frequency));
        
        List<String> result = new List<String>();
        for (Integer i = 0; i < Math.min(limitCount, sortedItems.size()); i++) {
            result.add(sortedItems[i]);
        }
        
        return result;
    }
    
    // AgentAction interface implementation
    public AgentResponse execute(Map<String, Object> parameters) {
        if (parameters.containsKey('opportunityId')) {
            return analyzeOpportunity((Id) parameters.get('opportunityId'));
        } else if (parameters.containsKey('ownerId')) {
            return analyzePipeline((Id) parameters.get('ownerId'));
        } else {
            return analyzePipeline(null);
        }
    }
    
    public String getActionName() {
        return 'OpportunityInsight';
    }
    
    public String getDescription() {
        return 'Analyze opportunities for risk assessment and actionable insights';
    }
    
    public List<String> getRequiredParameters() {
        return new List<String>(); // Optional parameters
    }
    
    /**
     * @description Comparator for sorting by frequency
     */
    public class FrequencyComparator implements Comparator<String> {
        private Map<String, Integer> frequency;
        
        public FrequencyComparator(Map<String, Integer> frequency) {
            this.frequency = frequency;
        }
        
        public Integer compare(String a, String b) {
            Integer freqA = frequency.get(a);
            Integer freqB = frequency.get(b);
            
            if (freqA > freqB) return -1;
            if (freqA < freqB) return 1;
            return 0;
        }
    }
}
