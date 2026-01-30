/**
 * @description Data Provider for Salesforce Prompt Builder
 * Provides contextual data to AI-generated fields and prompt templates
 * @author Solution Engineering Team
 * @version 1.0
 */
public with sharing class PromptBuilderDataProvider {
    
    /**
     * @description Get enriched record data for prompt context
     * @param recordId The record ID (Lead, Opportunity, or Case)
     * @return Map of enriched record data for prompt builder
     */
    @InvocableMethod(label='Get Record Context for Prompt' 
                     description='Retrieves enriched record data for AI prompt generation (Lead, Opportunity, or Case)' 
                     category='Prompt Builder')
    public static List<PromptContext> getRecordContext(List<PromptRequest> requests) {
        List<PromptContext> contexts = new List<PromptContext>();
        
        for (PromptRequest request : requests) {
            if (request.recordId == null) {
                PromptContext errorContext = new PromptContext();
                errorContext.success = false;
                errorContext.errorMessage = 'Record ID is required';
                contexts.add(errorContext);
                continue;
            }
            
            // Determine object type from ID prefix
            String objectType = String.valueOf(request.recordId.getSObjectType());
            
            if (objectType == 'Lead') {
                contexts.add(getLeadContextSingle(request.recordId));
            } else if (objectType == 'Opportunity') {
                contexts.add(getOpportunityContextSingle(request.recordId));
            } else if (objectType == 'Case') {
                contexts.add(getCaseContextSingle(request.recordId));
            } else {
                PromptContext errorContext = new PromptContext();
                errorContext.success = false;
                errorContext.errorMessage = 'Unsupported object type: ' + objectType;
                contexts.add(errorContext);
            }
        }
        
        return contexts;
    }
    
    /**
     * @description Get Lead context for a single record
     */
    private static PromptContext getLeadContextSingle(Id recordId) {
        PromptContext context = new PromptContext();
        
        try {
            // Query lead with all relevant fields
            List<Lead> leads = [
                SELECT Id, FirstName, LastName, Company, Email, Phone, Industry, 
                       AnnualRevenue, NumberOfEmployees, Status, Rating, LeadSource,
                       Title, Description, Street, City, State, PostalCode, Country,
                       Website, CreatedDate, LastModifiedDate, OwnerId, Owner.Name
                FROM Lead 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            
            if (leads.isEmpty()) {
                context.success = false;
                context.errorMessage = 'Lead not found';
                return context;
            }
            
            Lead lead = leads[0];
            
            // Build enriched context
            context.success = true;
            context.recordId = lead.Id;
            context.recordType = 'Lead';
            
            // Basic Information
            context.fullName = getFullName(lead.FirstName, lead.LastName);
            context.companyName = lead.Company;
            context.industry = lead.Industry;
            context.title = lead.Title;
            context.email = lead.Email;
            context.phone = lead.Phone;
            
            // Company Information
            context.companySize = getCompanySize(lead.NumberOfEmployees);
            context.revenueRange = getRevenueRange(lead.AnnualRevenue);
            context.location = getLocation(lead.City, lead.State, lead.Country);
            
            // Lead Qualification
            context.leadScore = calculateLeadScore(lead);
            context.leadGrade = getLeadGrade(context.leadScore);
            context.qualificationSummary = getQualificationSummary(lead);
            
            // Engagement Data
            context.daysSinceCreated = Date.today().daysBetween(lead.CreatedDate.date());
            context.leadStatus = lead.Status;
            context.leadSource = lead.LeadSource;
            context.ownerName = lead.Owner.Name;
            
            // Similar Leads Analysis
            context.similarLeadsCount = getSimilarLeadsCount(lead);
            context.industryTrends = getIndustryTrends(lead.Industry);
            
            // AI-Ready Context String
            context.contextSummary = buildContextSummary(lead, context);
            
        } catch (Exception e) {
            context.success = false;
            context.errorMessage = e.getMessage();
        }
        
        return context;
    }
    
    /**
     * @description Get Opportunity context for a single record
     */
    private static PromptContext getOpportunityContextSingle(Id recordId) {
        PromptContext context = new PromptContext();
        
        try {
            List<Opportunity> opportunities = [
                SELECT Id, Name, Amount, CloseDate, StageName, Probability, Type, 
                       LeadSource, Description, NextStep, AccountId, Account.Name,
                       Account.Industry, Account.AnnualRevenue, OwnerId, Owner.Name,
                       CreatedDate, LastModifiedDate, IsClosed, IsWon, ForecastCategory
                FROM Opportunity 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            
            if (opportunities.isEmpty()) {
                context.success = false;
                context.errorMessage = 'Opportunity not found';
                return context;
            }
            
            Opportunity opp = opportunities[0];
            
            context.success = true;
            context.recordId = opp.Id;
            context.recordType = 'Opportunity';
            
            // Basic Information
            context.opportunityName = opp.Name;
            context.accountName = opp.Account?.Name;
            context.amount = opp.Amount;
            context.stage = opp.StageName;
            context.probability = opp.Probability;
            
            // Risk Assessment
            context.daysToClose = Date.today().daysBetween(opp.CloseDate);
            context.riskLevel = assessRiskLevel(opp);
            context.urgencyLevel = assessUrgency(opp.CloseDate);
            
            // Industry and Market Context
            context.industry = opp.Account?.Industry;
            context.accountRevenue = opp.Account?.AnnualRevenue;
            
            // Engagement Metrics
            context.ownerName = opp.Owner.Name;
            context.daysSinceCreated = Date.today().daysBetween(opp.CreatedDate.date());
            
            // Similar Opportunities
            context.similarOpportunitiesCount = getSimilarOpportunitiesCount(opp);
            
            // Recommendations
            context.recommendations = getOpportunityRecommendations(opp);
            
            // AI-Ready Context String
            context.contextSummary = buildOpportunityContextSummary(opp, context);
            
        } catch (Exception e) {
            context.success = false;
            context.errorMessage = e.getMessage();
        }
        
        return context;
    }
    
    /**
     * @description Get Case context for a single record
     */
    private static PromptContext getCaseContextSingle(Id recordId) {
        PromptContext context = new PromptContext();
        
        try {
            List<Case> cases = [
                SELECT Id, CaseNumber, Subject, Description, Priority, Status, Type, 
                       Origin, Reason, AccountId, Account.Name, ContactId, Contact.Name,
                       OwnerId, Owner.Name, CreatedDate, ClosedDate, IsClosed, IsEscalated
                FROM Case 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            
            if (cases.isEmpty()) {
                context.success = false;
                context.errorMessage = 'Case not found';
                return context;
            }
            
            Case caseRecord = cases[0];
            
            context.success = true;
            context.recordId = caseRecord.Id;
            context.recordType = 'Case';
            
            // Basic Information
            context.caseNumber = caseRecord.CaseNumber;
            context.subject = caseRecord.Subject;
            context.description = caseRecord.Description;
            context.priority = caseRecord.Priority;
            context.status = caseRecord.Status;
            context.type = caseRecord.Type;
            
            // Customer Information
            context.accountName = caseRecord.Account?.Name;
            context.contactName = caseRecord.Contact?.Name;
            context.ownerName = caseRecord.Owner.Name;
            
            // Case Metrics
            context.daysSinceCreated = Date.today().daysBetween(caseRecord.CreatedDate.date());
            context.isEscalated = caseRecord.IsEscalated;
            context.urgencyLevel = assessCaseUrgency(caseRecord);
            
            // Similar Cases
            context.similarCasesCount = getSimilarCasesCount(caseRecord);
            
            // Resolution Suggestions
            context.suggestedResolution = suggestCaseResolution(caseRecord);
            
            // AI-Ready Context String
            context.contextSummary = buildCaseContextSummary(caseRecord, context);
            
        } catch (Exception e) {
            context.success = false;
            context.errorMessage = e.getMessage();
        }
        
        return context;
    }
    
    // ========== HELPER METHODS ==========
    
    private static String getFullName(String firstName, String lastName) {
        if (String.isBlank(firstName)) return lastName;
        if (String.isBlank(lastName)) return firstName;
        return firstName + ' ' + lastName;
    }
    
    private static String getCompanySize(Integer employeeCount) {
        if (employeeCount == null) return 'Unknown';
        if (employeeCount >= 10000) return 'Enterprise (10,000+)';
        if (employeeCount >= 1000) return 'Large (1,000-10,000)';
        if (employeeCount >= 100) return 'Medium (100-1,000)';
        if (employeeCount >= 10) return 'Small (10-100)';
        return 'Micro (<10)';
    }
    
    private static String getRevenueRange(Decimal revenue) {
        if (revenue == null) return 'Unknown';
        if (revenue >= 100000000) return '$100M+';
        if (revenue >= 10000000) return '$10M-$100M';
        if (revenue >= 1000000) return '$1M-$10M';
        if (revenue >= 100000) return '$100K-$1M';
        return 'Under $100K';
    }
    
    private static String getLocation(String city, String state, String country) {
        List<String> parts = new List<String>();
        if (String.isNotBlank(city)) parts.add(city);
        if (String.isNotBlank(state)) parts.add(state);
        if (String.isNotBlank(country)) parts.add(country);
        return String.join(parts, ', ');
    }
    
    private static Integer calculateLeadScore(Lead lead) {
        Integer score = 0;
        
        // Company size scoring
        if (lead.NumberOfEmployees != null) {
            if (lead.NumberOfEmployees >= 1000) score += 25;
            else if (lead.NumberOfEmployees >= 100) score += 15;
            else if (lead.NumberOfEmployees >= 10) score += 10;
        }
        
        // Revenue scoring
        if (lead.AnnualRevenue != null) {
            if (lead.AnnualRevenue >= 10000000) score += 25;
            else if (lead.AnnualRevenue >= 1000000) score += 15;
            else if (lead.AnnualRevenue >= 100000) score += 10;
        }
        
        // Contact completeness
        if (String.isNotBlank(lead.Email) && String.isNotBlank(lead.Phone)) score += 20;
        else if (String.isNotBlank(lead.Email) || String.isNotBlank(lead.Phone)) score += 10;
        
        // Industry
        if (String.isNotBlank(lead.Industry)) score += 15;
        
        // Lead source
        if (String.isNotBlank(lead.LeadSource)) score += 15;
        
        return score;
    }
    
    private static String getLeadGrade(Integer score) {
        if (score >= 80) return 'A (Hot)';
        if (score >= 60) return 'B (Warm)';
        if (score >= 40) return 'C (Lukewarm)';
        return 'D (Cold)';
    }
    
    private static String getQualificationSummary(Lead lead) {
        List<String> points = new List<String>();
        
        if (lead.NumberOfEmployees != null && lead.NumberOfEmployees >= 100) {
            points.add('Well-sized company');
        }
        
        if (lead.AnnualRevenue != null && lead.AnnualRevenue >= 1000000) {
            points.add('Strong revenue');
        }
        
        if (String.isNotBlank(lead.Email) && String.isNotBlank(lead.Phone)) {
            points.add('Complete contact info');
        }
        
        if (points.isEmpty()) {
            return 'Needs qualification';
        }
        
        return String.join(points, ', ');
    }
    
    private static Integer getSimilarLeadsCount(Lead lead) {
        if (String.isBlank(lead.Industry)) return 0;
        
        return [
            SELECT COUNT() 
            FROM Lead 
            WHERE Industry = :lead.Industry 
            AND Id != :lead.Id 
            AND CreatedDate = LAST_N_DAYS:90
        ];
    }
    
    private static String getIndustryTrends(String industry) {
        if (String.isBlank(industry)) return 'No industry data';
        
        Integer recentLeads = [
            SELECT COUNT() 
            FROM Lead 
            WHERE Industry = :industry 
            AND CreatedDate = LAST_N_DAYS:30
        ];
        
        if (recentLeads >= 50) return 'High activity in ' + industry;
        if (recentLeads >= 20) return 'Moderate activity in ' + industry;
        if (recentLeads >= 5) return 'Some activity in ' + industry;
        return 'Limited activity in ' + industry;
    }
    
    private static String buildContextSummary(Lead lead, PromptContext context) {
        String summary = 'Lead: ' + context.fullName + ' from ' + lead.Company + '. ';
        
        if (String.isNotBlank(lead.Title)) {
            summary += 'Title: ' + lead.Title + '. ';
        }
        
        if (String.isNotBlank(context.industry)) {
            summary += 'Industry: ' + context.industry + '. ';
        }
        
        summary += 'Company Size: ' + context.companySize + '. ';
        summary += 'Revenue Range: ' + context.revenueRange + '. ';
        summary += 'Lead Score: ' + context.leadScore + '/100 (' + context.leadGrade + '). ';
        summary += 'Status: ' + lead.Status + '. ';
        
        if (String.isNotBlank(lead.LeadSource)) {
            summary += 'Source: ' + lead.LeadSource + '. ';
        }
        
        summary += context.qualificationSummary + '.';
        
        return summary;
    }
    
    private static String assessRiskLevel(Opportunity opp) {
        Integer riskScore = 0;
        
        if (opp.Probability < 30) riskScore += 2;
        if (opp.CloseDate < Date.today().addDays(14)) riskScore += 2;
        if (opp.Amount != null && opp.Amount > 100000) riskScore += 1;
        
        if (riskScore >= 3) return 'High';
        if (riskScore >= 2) return 'Medium';
        return 'Low';
    }
    
    private static String assessUrgency(Date closeDate) {
        Integer daysToClose = Date.today().daysBetween(closeDate);
        
        if (daysToClose < 7) return 'Critical';
        if (daysToClose < 30) return 'High';
        if (daysToClose < 90) return 'Medium';
        return 'Low';
    }
    
    private static Integer getSimilarOpportunitiesCount(Opportunity opp) {
        if (opp.Account?.Industry == null) return 0;
        
        return [
            SELECT COUNT() 
            FROM Opportunity 
            WHERE Account.Industry = :opp.Account.Industry 
            AND Id != :opp.Id 
            AND CreatedDate = LAST_N_DAYS:90
        ];
    }
    
    private static String getOpportunityRecommendations(Opportunity opp) {
        List<String> recommendations = new List<String>();
        
        if (opp.Probability < 40) {
            recommendations.add('Strengthen value proposition');
        }
        
        if (opp.CloseDate < Date.today().addDays(30)) {
            recommendations.add('Engage key stakeholders');
        }
        
        if (String.isBlank(opp.NextStep)) {
            recommendations.add('Define clear next steps');
        }
        
        return recommendations.isEmpty() ? 'Continue current approach' : String.join(recommendations, '; ');
    }
    
    private static String buildOpportunityContextSummary(Opportunity opp, PromptContext context) {
        String summary = 'Opportunity: ' + opp.Name;
        
        if (context.accountName != null) {
            summary += ' for ' + context.accountName;
        }
        
        summary += '. ';
        
        if (opp.Amount != null) {
            summary += 'Amount: $' + String.valueOf(opp.Amount.format()) + '. ';
        }
        
        summary += 'Stage: ' + opp.StageName + '. ';
        summary += 'Probability: ' + opp.Probability + '%. ';
        summary += 'Days to Close: ' + context.daysToClose + '. ';
        summary += 'Risk Level: ' + context.riskLevel + '. ';
        summary += 'Urgency: ' + context.urgencyLevel + '. ';
        summary += 'Recommendations: ' + context.recommendations + '.';
        
        return summary;
    }
    
    private static String assessCaseUrgency(Case caseRecord) {
        if (caseRecord.IsEscalated) return 'Critical';
        if (caseRecord.Priority == 'High') return 'High';
        if (caseRecord.Priority == 'Medium') return 'Medium';
        return 'Low';
    }
    
    private static Integer getSimilarCasesCount(Case caseRecord) {
        if (String.isBlank(caseRecord.Type)) return 0;
        
        return [
            SELECT COUNT() 
            FROM Case 
            WHERE Type = :caseRecord.Type 
            AND Id != :caseRecord.Id 
            AND CreatedDate = LAST_N_DAYS:90
        ];
    }
    
    private static String suggestCaseResolution(Case caseRecord) {
        if (caseRecord.Type == 'Technical') {
            return 'Review system logs and configuration';
        } else if (caseRecord.Type == 'Billing') {
            return 'Check payment history and invoices';
        } else if (caseRecord.Type == 'General') {
            return 'Contact customer for clarification';
        }
        return 'Analyze case details and determine resolution';
    }
    
    private static String buildCaseContextSummary(Case caseRecord, PromptContext context) {
        String summary = 'Case ' + caseRecord.CaseNumber + ': ' + caseRecord.Subject + '. ';
        
        if (context.accountName != null) {
            summary += 'Account: ' + context.accountName + '. ';
        }
        
        if (context.contactName != null) {
            summary += 'Contact: ' + context.contactName + '. ';
        }
        
        summary += 'Priority: ' + caseRecord.Priority + '. ';
        summary += 'Status: ' + caseRecord.Status + '. ';
        summary += 'Type: ' + caseRecord.Type + '. ';
        summary += 'Urgency: ' + context.urgencyLevel + '. ';
        summary += 'Days Open: ' + context.daysSinceCreated + '. ';
        
        if (caseRecord.IsEscalated) {
            summary += 'ESCALATED. ';
        }
        
        summary += 'Suggested Resolution: ' + context.suggestedResolution + '.';
        
        return summary;
    }
    
    // ========== INPUT/OUTPUT CLASSES ==========
    
    /**
     * @description Input parameter for invocable method
     */
    public class PromptRequest {
        @InvocableVariable(label='Record ID' description='The record ID to get context for' required=true)
        public Id recordId;
    }
    
    /**
     * @description Output context for prompt builder
     */
    public class PromptContext {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean success = false;
        
        @InvocableVariable(label='Record ID' description='The record ID')
        public Id recordId;
        
        @InvocableVariable(label='Record Type' description='The type of record')
        public String recordType;
        
        @InvocableVariable(label='Error Message' description='Error message if operation failed')
        public String errorMessage;
        
        // Lead-specific fields
        @InvocableVariable(label='Full Name' description='Contact full name')
        public String fullName;
        
        @InvocableVariable(label='Company Name' description='Company name')
        public String companyName;
        
        @InvocableVariable(label='Industry' description='Industry')
        public String industry;
        
        @InvocableVariable(label='Title' description='Job title')
        public String title;
        
        @InvocableVariable(label='Email' description='Email address')
        public String email;
        
        @InvocableVariable(label='Phone' description='Phone number')
        public String phone;
        
        @InvocableVariable(label='Company Size' description='Company size category')
        public String companySize;
        
        @InvocableVariable(label='Revenue Range' description='Revenue range')
        public String revenueRange;
        
        @InvocableVariable(label='Location' description='Geographic location')
        public String location;
        
        @InvocableVariable(label='Lead Score' description='Calculated lead score')
        public Integer leadScore;
        
        @InvocableVariable(label='Lead Grade' description='Lead grade (A-D)')
        public String leadGrade;
        
        @InvocableVariable(label='Qualification Summary' description='Lead qualification summary')
        public String qualificationSummary;
        
        @InvocableVariable(label='Lead Status' description='Lead status')
        public String leadStatus;
        
        @InvocableVariable(label='Lead Source' description='Lead source')
        public String leadSource;
        
        @InvocableVariable(label='Similar Leads Count' description='Number of similar leads')
        public Integer similarLeadsCount;
        
        @InvocableVariable(label='Industry Trends' description='Industry trends')
        public String industryTrends;
        
        // Opportunity-specific fields
        @InvocableVariable(label='Opportunity Name' description='Opportunity name')
        public String opportunityName;
        
        @InvocableVariable(label='Account Name' description='Account name')
        public String accountName;
        
        @InvocableVariable(label='Amount' description='Opportunity amount')
        public Decimal amount;
        
        @InvocableVariable(label='Stage' description='Opportunity stage')
        public String stage;
        
        @InvocableVariable(label='Probability' description='Win probability')
        public Decimal probability;
        
        @InvocableVariable(label='Days to Close' description='Days until close date')
        public Integer daysToClose;
        
        @InvocableVariable(label='Risk Level' description='Risk assessment level')
        public String riskLevel;
        
        @InvocableVariable(label='Urgency Level' description='Urgency level')
        public String urgencyLevel;
        
        @InvocableVariable(label='Account Revenue' description='Account annual revenue')
        public Decimal accountRevenue;
        
        @InvocableVariable(label='Similar Opportunities Count' description='Number of similar opportunities')
        public Integer similarOpportunitiesCount;
        
        @InvocableVariable(label='Recommendations' description='AI recommendations')
        public String recommendations;
        
        // Case-specific fields
        @InvocableVariable(label='Case Number' description='Case number')
        public String caseNumber;
        
        @InvocableVariable(label='Subject' description='Case subject')
        public String subject;
        
        @InvocableVariable(label='Description' description='Case description')
        public String description;
        
        @InvocableVariable(label='Priority' description='Case priority')
        public String priority;
        
        @InvocableVariable(label='Status' description='Case status')
        public String status;
        
        @InvocableVariable(label='Type' description='Case type')
        public String type;
        
        @InvocableVariable(label='Contact Name' description='Contact name')
        public String contactName;
        
        @InvocableVariable(label='Is Escalated' description='Whether case is escalated')
        public Boolean isEscalated;
        
        @InvocableVariable(label='Similar Cases Count' description='Number of similar cases')
        public Integer similarCasesCount;
        
        @InvocableVariable(label='Suggested Resolution' description='Suggested resolution')
        public String suggestedResolution;
        
        // Common fields
        @InvocableVariable(label='Owner Name' description='Record owner name')
        public String ownerName;
        
        @InvocableVariable(label='Days Since Created' description='Days since record creation')
        public Integer daysSinceCreated;
        
        @InvocableVariable(label='Context Summary' description='Complete context summary for AI')
        public String contextSummary;
    }
}

