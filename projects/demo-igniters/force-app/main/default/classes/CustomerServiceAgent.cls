/**
 * @description Agent for intelligent customer service and case management
 * @author Solution Engineering Team
 * @version 1.0
 */
public with sharing class CustomerServiceAgent extends AgentActionController implements AgentAction {
    
    public class CaseInsight {
        @AuraEnabled public String caseId { get; set; }
        @AuraEnabled public String caseNumber { get; set; }
        @AuraEnabled public String priority { get; set; }
        @AuraEnabled public String urgency { get; set; }
        @AuraEnabled public String suggestedResolution { get; set; }
        @AuraEnabled public List<String> similarCases { get; set; }
        @AuraEnabled public String recommendedAssignee { get; set; }
        @AuraEnabled public Decimal estimatedResolutionTime { get; set; }
        @AuraEnabled public List<String> knowledgeArticles { get; set; }
        
        public CaseInsight() {
            this.similarCases = new List<String>();
            this.knowledgeArticles = new List<String>();
        }
    }
    
    public class ServiceMetrics {
        @AuraEnabled public Integer totalCases { get; set; }
        @AuraEnabled public Integer openCases { get; set; }
        @AuraEnabled public Integer closedCases { get; set; }
        @AuraEnabled public Decimal averageResolutionTime { get; set; }
        @AuraEnabled public Decimal customerSatisfactionScore { get; set; }
        @AuraEnabled public List<String> topIssues { get; set; }
        @AuraEnabled public List<String> recommendations { get; set; }
        
        public ServiceMetrics() {
            this.topIssues = new List<String>();
            this.recommendations = new List<String>();
        }
    }
    
    /**
     * @description Analyze a case for intelligent insights
     * @param caseId The ID of the case to analyze
     * @return AgentResponse with case insights
     */
    @AuraEnabled(cacheable=false)
    public static AgentResponse analyzeCase(Id caseId) {
        try {
            if (caseId == null) {
                return createErrorResponse('Case ID is required', new List<String>{'Case ID cannot be null'});
            }
            
            List<Case> cases = [
                SELECT Id, CaseNumber, Subject, Description, Priority, Status, Type, 
                       Origin, Reason, AccountId, ContactId, OwnerId, Owner.Name,
                       CreatedDate, ClosedDate, IsClosed, IsEscalated
                FROM Case 
                WHERE Id = :caseId 
                LIMIT 1
            ];
            
            if (cases.isEmpty()) {
                return createErrorResponse('Case not found', new List<String>{'Case with ID ' + caseId + ' not found'});
            }
            
            Case caseRecord = cases[0];
            CaseInsight insight = generateCaseInsight(caseRecord);
            
            return createSuccessResponse('Case analysis completed', insight);
            
        } catch (Exception e) {
            return createErrorResponse('Error analyzing case: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Get service metrics for a team or individual
     * @param ownerId Optional owner ID to filter by specific user
     * @param daysBack Number of days to look back for metrics
     * @return AgentResponse with service metrics
     */
    @AuraEnabled(cacheable=true)
    public static AgentResponse getServiceMetrics(Id ownerId, Integer daysBack) {
        try {
            if (daysBack == null || daysBack <= 0) {
                daysBack = 30; // Default to 30 days
            }
            
            Date startDate = Date.today().addDays(-daysBack);
            
            String soql = 'SELECT Id, Status, Priority, Type, Origin, CreatedDate, ClosedDate, ' +
                         'IsClosed, IsEscalated, OwnerId, Owner.Name ' +
                         'FROM Case ' +
                         'WHERE CreatedDate >= :startDate ';
            
            if (ownerId != null) {
                soql += 'AND OwnerId = :ownerId ';
            }
            
            List<Case> cases = Database.query(soql);
            
            ServiceMetrics metrics = generateServiceMetrics(cases, daysBack);
            
            return createSuccessResponse('Service metrics generated', metrics);
            
        } catch (Exception e) {
            return createErrorResponse('Error generating service metrics: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Get cases requiring attention
     * @param ownerId Optional owner ID to filter by specific user
     * @return AgentResponse with cases needing attention
     */
    @AuraEnabled(cacheable=true)
    public static AgentResponse getCasesNeedingAttention(Id ownerId) {
        try {
            String soql = 'SELECT Id, CaseNumber, Subject, Priority, Status, Type, ' +
                         'CreatedDate, OwnerId, Owner.Name, IsEscalated ' +
                         'FROM Case ' +
                         'WHERE IsClosed = false AND (IsEscalated = true OR Priority = \'High\' OR Priority = \'Critical\') ';
            
            if (ownerId != null) {
                soql += 'AND OwnerId = :ownerId ';
            }
            
            soql += 'ORDER BY Priority DESC, CreatedDate ASC';
            
            List<Case> cases = Database.query(soql);
            
            List<CaseInsight> insights = new List<CaseInsight>();
            for (Case caseRecord : cases) {
                insights.add(generateCaseInsight(caseRecord));
            }
            
            return createSuccessResponse('Cases needing attention identified', insights);
            
        } catch (Exception e) {
            return createErrorResponse('Error identifying cases needing attention: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Auto-assign case to best available agent
     * @param caseId The ID of the case to assign
     * @return AgentResponse with assignment result
     */
    @AuraEnabled(cacheable=false)
    public static AgentResponse autoAssignCase(Id caseId) {
        try {
            if (caseId == null) {
                return createErrorResponse('Case ID is required', new List<String>{'Case ID cannot be null'});
            }
            
            List<Case> cases = [
                SELECT Id, Type, Priority, Subject, Description, OwnerId
                FROM Case 
                WHERE Id = :caseId 
                LIMIT 1
            ];
            
            if (cases.isEmpty()) {
                return createErrorResponse('Case not found', new List<String>{'Case not found'});
            }
            
            Case caseRecord = cases[0];
            Id recommendedOwner = findBestAssignee(caseRecord);
            
            if (recommendedOwner != null) {
                caseRecord.OwnerId = recommendedOwner;
                update caseRecord;
                
                return createSuccessResponse('Case assigned successfully', new Map<String, Object>{
                    'caseId' => caseId,
                    'assignedTo' => recommendedOwner
                });
            } else {
                return createErrorResponse('No suitable assignee found', new List<String>{'Unable to find appropriate assignee'});
            }
            
        } catch (Exception e) {
            return createErrorResponse('Error auto-assigning case: ' + e.getMessage(), 
                                    new List<String>{e.getMessage()});
        }
    }
    
    /**
     * @description Generate case insights
     */
    private static CaseInsight generateCaseInsight(Case caseRecord) {
        CaseInsight insight = new CaseInsight();
        insight.caseId = caseRecord.Id;
        insight.caseNumber = caseRecord.CaseNumber;
        insight.priority = caseRecord.Priority;
        
        // Determine urgency
        if (caseRecord.IsEscalated) {
            insight.urgency = 'Critical';
        } else if (caseRecord.Priority == 'High') {
            insight.urgency = 'High';
        } else if (caseRecord.Priority == 'Medium') {
            insight.urgency = 'Medium';
        } else {
            insight.urgency = 'Low';
        }
        
        // Suggest resolution based on case type and description
        insight.suggestedResolution = suggestResolution(caseRecord);
        
        // Find similar cases
        insight.similarCases = findSimilarCases(caseRecord);
        
        // Recommend assignee
        insight.recommendedAssignee = findBestAssignee(caseRecord);
        
        // Estimate resolution time
        insight.estimatedResolutionTime = estimateResolutionTime(caseRecord);
        
        // Suggest knowledge articles
        insight.knowledgeArticles = suggestKnowledgeArticles(caseRecord);
        
        return insight;
    }
    
    /**
     * @description Generate service metrics
     */
    private static ServiceMetrics generateServiceMetrics(List<Case> cases, Integer daysBack) {
        ServiceMetrics metrics = new ServiceMetrics();
        
        Integer totalCases = cases.size();
        Integer openCases = 0;
        Integer closedCases = 0;
        Decimal totalResolutionTime = 0;
        Integer casesWithResolutionTime = 0;
        
        Map<String, Integer> issueFrequency = new Map<String, Integer>();
        List<String> recommendations = new List<String>();
        
        for (Case caseRecord : cases) {
            if (caseRecord.IsClosed) {
                closedCases++;
                
                if (caseRecord.ClosedDate != null && caseRecord.CreatedDate != null) {
                    Decimal resolutionDays = caseRecord.CreatedDate.date().daysBetween(caseRecord.ClosedDate.date());
                    totalResolutionTime += resolutionDays;
                    casesWithResolutionTime++;
                }
            } else {
                openCases++;
            }
            
            // Track issue types
            String issueType = caseRecord.Type != null ? caseRecord.Type : 'Unknown';
            issueFrequency.put(issueType, issueFrequency.get(issueType) == null ? 1 : issueFrequency.get(issueType) + 1);
        }
        
        metrics.totalCases = totalCases;
        metrics.openCases = openCases;
        metrics.closedCases = closedCases;
        metrics.averageResolutionTime = casesWithResolutionTime > 0 ? totalResolutionTime / casesWithResolutionTime : 0;
        
        // Calculate customer satisfaction (simplified - would need actual survey data)
        metrics.customerSatisfactionScore = calculateSatisfactionScore(cases);
        
        // Get top issues
        List<String> sortedIssues = new List<String>(issueFrequency.keySet());
        sortedIssues.sort(new IssueFrequencyComparator(issueFrequency));
        
        for (Integer i = 0; i < Math.min(5, sortedIssues.size()); i++) {
            metrics.topIssues.add(sortedIssues[i]);
        }
        
        // Generate recommendations
        if (metrics.averageResolutionTime > 7) {
            recommendations.add('Consider improving resolution time - current average is ' + metrics.averageResolutionTime + ' days');
        }
        
        if (openCases > closedCases) {
            recommendations.add('High number of open cases - consider increasing support capacity');
        }
        
        if (metrics.customerSatisfactionScore < 3.0) {
            recommendations.add('Customer satisfaction is low - review support processes');
        }
        
        metrics.recommendations = recommendations;
        
        return metrics;
    }
    
    /**
     * @description Suggest resolution for a case
     */
    private static String suggestResolution(Case caseRecord) {
        if (caseRecord.Type == 'Technical') {
            return 'Check system logs and verify configuration settings';
        } else if (caseRecord.Type == 'Billing') {
            return 'Review account billing history and payment methods';
        } else if (caseRecord.Type == 'General') {
            return 'Review case details and contact customer for clarification';
        } else {
            return 'Analyze case details and determine appropriate resolution path';
        }
    }
    
    /**
     * @description Find similar cases
     */
    private static List<String> findSimilarCases(Case caseRecord) {
        List<Case> similarCases = [
            SELECT Id, CaseNumber, Subject, Type, Status
            FROM Case 
            WHERE Type = :caseRecord.Type 
            AND Id != :caseRecord.Id
            AND CreatedDate = LAST_N_DAYS:90
            LIMIT 3
        ];
        
        List<String> caseNumbers = new List<String>();
        for (Case similarCase : similarCases) {
            caseNumbers.add(similarCase.CaseNumber);
        }
        
        return caseNumbers;
    }
    
    /**
     * @description Find best assignee for a case
     */
    private static Id findBestAssignee(Case caseRecord) {
        // Simplified logic - in real scenario, would consider:
        // - Agent workload
        // - Agent expertise/skills
        // - Agent availability
        // - Case complexity
        
        List<User> availableUsers = [
            SELECT Id, Name, IsActive
            FROM User 
            WHERE IsActive = true 
            AND Profile.Name LIKE '%Service%'
            LIMIT 5
        ];
        
        if (!availableUsers.isEmpty()) {
            // Simple round-robin or random assignment
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), availableUsers.size());
            return availableUsers[randomIndex].Id;
        }
        
        return null;
    }
    
    /**
     * @description Estimate resolution time
     */
    private static Decimal estimateResolutionTime(Case caseRecord) {
        if (caseRecord.Priority == 'Critical') {
            return 2; // 2 hours
        } else if (caseRecord.Priority == 'High') {
            return 4; // 4 hours
        } else if (caseRecord.Priority == 'Medium') {
            return 8; // 8 hours
        } else {
            return 24; // 24 hours
        }
    }
    
    /**
     * @description Suggest knowledge articles
     */
    private static List<String> suggestKnowledgeArticles(Case caseRecord) {
        // Simplified - in real scenario, would query Knowledge base
        List<String> articles = new List<String>();
        
        if (caseRecord.Type == 'Technical') {
            articles.add('Troubleshooting Guide');
            articles.add('System Configuration');
        } else if (caseRecord.Type == 'Billing') {
            articles.add('Billing FAQ');
            articles.add('Payment Methods');
        }
        
        return articles;
    }
    
    /**
     * @description Calculate customer satisfaction score
     */
    private static Decimal calculateSatisfactionScore(List<Case> cases) {
        // Simplified calculation - in real scenario, would use actual survey data
        Integer totalCases = cases.size();
        Integer highPriorityCases = 0;
        
        for (Case caseRecord : cases) {
            if (caseRecord.Priority == 'High' || caseRecord.Priority == 'Critical') {
                highPriorityCases++;
            }
        }
        
        // Simple formula: fewer high-priority cases = higher satisfaction
        Decimal satisfactionScore = 5.0 - (Decimal.valueOf(highPriorityCases) / totalCases) * 2.0;
        return Math.max(1.0, satisfactionScore);
    }
    
    // AgentAction interface implementation
    public AgentResponse execute(Map<String, Object> parameters) {
        if (parameters.containsKey('caseId')) {
            return analyzeCase((Id) parameters.get('caseId'));
        } else if (parameters.containsKey('ownerId')) {
            Integer daysBack = parameters.containsKey('daysBack') ? (Integer) parameters.get('daysBack') : 30;
            return getServiceMetrics((Id) parameters.get('ownerId'), daysBack);
        } else {
            return getServiceMetrics(null, 30);
        }
    }
    
    public String getActionName() {
        return 'CustomerService';
    }
    
    public String getDescription() {
        return 'Intelligent customer service and case management insights';
    }
    
    public List<String> getRequiredParameters() {
        return new List<String>(); // Optional parameters
    }
    
    /**
     * @description Comparator for sorting by frequency
     */
    public class IssueFrequencyComparator implements Comparator<String> {
        private Map<String, Integer> frequency;
        
        public IssueFrequencyComparator(Map<String, Integer> frequency) {
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
