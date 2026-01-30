/**
 * ContractAnalysisAgent
 * 
 * Invocable Apex class for Agentforce to analyze contract documents
 * attached to Opportunities and extract key terms for risk assessment.
 * 
 * Use Case: MSA Analysis Agent
 * Features:
 * - Extract payment terms from contract documents
 * - Assess contract risk level
 * - Identify non-standard clauses
 * - Provide recommendations
 */
public with sharing class ContractAnalysisAgent {
    
    /**
     * Analyze Contract Risk
     * Main invocable method called by Agentforce Agent
     */
    @InvocableMethod(
        label='Analyze Contract Risk' 
        description='Extracts contract terms and calculates risk score'
        category='Contract Analysis'
    )
    public static List<ContractAnalysisResult> analyzeContract(
        List<ContractAnalysisRequest> requests
    ) {
        List<ContractAnalysisResult> results = new List<ContractAnalysisResult>();
        
        for (ContractAnalysisRequest request : requests) {
            try {
                ContractAnalysisResult result = analyzeContractDocument(request);
                results.add(result);
            } catch (Exception e) {
                // Return error result
                ContractAnalysisResult errorResult = new ContractAnalysisResult();
                errorResult.success = false;
                errorResult.errorMessage = 'Error analyzing contract: ' + e.getMessage();
                results.add(errorResult);
            }
        }
        
        return results;
    }
    
    /**
     * Analyze a single contract document
     */
    private static ContractAnalysisResult analyzeContractDocument(
        ContractAnalysisRequest request
    ) {
        ContractAnalysisResult result = new ContractAnalysisResult();
        result.success = true;
        result.opportunityId = request.opportunityId;
        
        // Fetch all documents linked to this Opportunity
        List<ContentDocumentLink> docLinks = [
            SELECT 
                ContentDocument.Id,
                ContentDocument.Title,
                ContentDocument.FileExtension,
                ContentDocument.ContentSize,
                ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :request.opportunityId
            AND ContentDocument.FileExtension IN ('pdf', 'docx')
            ORDER BY ContentDocument.CreatedDate DESC
        ];
        
        if (docLinks.isEmpty()) {
            result.success = false;
            result.errorMessage = 'No contract documents found on this Opportunity';
            return result;
        }
        
        result.documentsFound = docLinks.size();
        List<String> documentNames = new List<String>();
        for (ContentDocumentLink link : docLinks) {
            documentNames.add(link.ContentDocument.Title);
        }
        result.documentNames = documentNames;
        
        // Analyze key contract terms
        // In a real implementation, you would use Data Cloud RAG here
        // This is a simplified example showing the structure
        result.paymentTerms = extractPaymentTerms(docLinks);
        result.uptime = extractUptimeRequirement(docLinks);
        result.rolloverPercent = extractRolloverTerms(docLinks);
        result.liabilityCap = extractLiabilityCap(docLinks);
        
        // Calculate risk score
        RiskAssessment risk = calculateRisk(result);
        result.riskLevel = risk.level;
        result.riskScore = risk.score;
        result.riskFactors = risk.factors;
        result.recommendations = generateRecommendations(risk);
        
        // Generate summary
        result.summary = generateSummary(result);
        
        return result;
    }
    
    /**
     * Extract payment terms from documents
     * In production, this would use Data Cloud RAG semantic search
     */
    private static String extractPaymentTerms(List<ContentDocumentLink> docs) {
        // Placeholder: In production, use Data Cloud RAG to search for:
        // "payment", "net", "due", "invoice" clauses
        
        // For demo, check Opportunity fields or return default
        return 'Net 30'; // Would be extracted from actual document
    }
    
    /**
     * Extract uptime/SLA requirement
     */
    private static Decimal extractUptimeRequirement(List<ContentDocumentLink> docs) {
        // Placeholder: Search for "uptime", "availability", "SLA" clauses
        return 99.9; // Would be extracted from actual document
    }
    
    /**
     * Extract rollover terms
     */
    private static Decimal extractRolloverTerms(List<ContentDocumentLink> docs) {
        // Placeholder: Search for "rollover", "unused capacity" clauses
        return 10.0; // Would be extracted from actual document
    }
    
    /**
     * Extract limitation of liability cap
     */
    private static Decimal extractLiabilityCap(List<ContentDocumentLink> docs) {
        // Placeholder: Search for "limitation of liability", "aggregate liability"
        return 500000; // Would be extracted from actual document
    }
    
    /**
     * Calculate risk score based on contract terms
     */
    private static RiskAssessment calculateRisk(ContractAnalysisResult analysis) {
        RiskAssessment risk = new RiskAssessment();
        risk.score = 0;
        risk.factors = new List<String>();
        
        // Check payment terms
        if (analysis.paymentTerms != 'Net 30') {
            if (analysis.paymentTerms.contains('60')) {
                risk.score += 3;
                risk.factors.add('Non-standard payment terms: ' + analysis.paymentTerms);
            } else if (analysis.paymentTerms.contains('45')) {
                risk.score += 2;
                risk.factors.add('Slightly extended payment terms: ' + analysis.paymentTerms);
            } else if (analysis.paymentTerms.contains('90')) {
                risk.score += 5;
                risk.factors.add('CRITICAL: Net 90 payment terms unacceptable');
            }
        }
        
        // Check uptime SLA
        if (analysis.uptime > 99.9) {
            risk.score += 5;
            risk.factors.add('CRITICAL: Uptime requirement ' + 
                           analysis.uptime + '% may be impossible to meet');
        }
        
        // Check rollover terms
        if (analysis.rolloverPercent > 10) {
            risk.score += 2;
            risk.factors.add('Rollover terms ' + analysis.rolloverPercent + 
                           '% exceed standard 10%');
        }
        if (analysis.rolloverPercent > 15) {
            risk.score += 3;
            risk.factors.add('CRITICAL: Rollover terms ' + analysis.rolloverPercent + 
                           '% are excessive');
        }
        
        // Check liability cap
        if (analysis.liabilityCap > 1000000) {
            risk.score += 2;
            risk.factors.add('High liability cap: $' + 
                           analysis.liabilityCap.format());
        }
        
        // Determine risk level
        if (risk.score >= 10) {
            risk.level = 'Critical';
        } else if (risk.score >= 7) {
            risk.level = 'High';
        } else if (risk.score >= 3) {
            risk.level = 'Medium';
        } else {
            risk.level = 'Low';
        }
        
        return risk;
    }
    
    /**
     * Generate recommendations based on risk assessment
     */
    private static List<String> generateRecommendations(RiskAssessment risk) {
        List<String> recommendations = new List<String>();
        
        if (risk.level == 'Critical') {
            recommendations.add('URGENT: Legal review required before proceeding');
            recommendations.add('Do not sign until critical terms are renegotiated');
        }
        
        if (risk.level == 'High') {
            recommendations.add('Senior approval required');
            recommendations.add('Schedule negotiation to address non-standard terms');
        }
        
        for (String factor : risk.factors) {
            if (factor.contains('payment')) {
                recommendations.add('Negotiate payment terms back to Net 30');
            }
            if (factor.contains('Uptime')) {
                recommendations.add('Reduce uptime SLA to 99.9% or add service credit caps');
            }
            if (factor.contains('Rollover')) {
                recommendations.add('Reduce rollover provision to ≤10%');
            }
            if (factor.contains('liability')) {
                recommendations.add('Negotiate liability cap to 12-month fee maximum');
            }
        }
        
        if (recommendations.isEmpty()) {
            recommendations.add('Contract terms are acceptable, proceed with standard approval');
        }
        
        return recommendations;
    }
    
    /**
     * Generate human-readable summary
     */
    private static String generateSummary(ContractAnalysisResult analysis) {
        String summary = 'CONTRACT ANALYSIS SUMMARY\n\n';
        summary += 'Documents Analyzed: ' + analysis.documentsFound + '\n';
        summary += '- ' + String.join(analysis.documentNames, '\n- ') + '\n\n';
        
        summary += 'KEY TERMS:\n';
        summary += '• Payment: ' + analysis.paymentTerms + '\n';
        summary += '• Uptime SLA: ' + analysis.uptime + '%\n';
        summary += '• Rollover: ' + analysis.rolloverPercent + '%\n';
        summary += '• Liability Cap: $' + analysis.liabilityCap.format() + '\n\n';
        
        summary += 'RISK ASSESSMENT: ' + analysis.riskLevel.toUpperCase() + 
                  ' (Score: ' + analysis.riskScore + ')\n\n';
        
        if (!analysis.riskFactors.isEmpty()) {
            summary += 'RISK FACTORS:\n';
            for (String factor : analysis.riskFactors) {
                summary += '⚠️ ' + factor + '\n';
            }
            summary += '\n';
        }
        
        summary += 'RECOMMENDATIONS:\n';
        for (String rec : analysis.recommendations) {
            summary += '→ ' + rec + '\n';
        }
        
        return summary;
    }
    
    // ========================================================================
    // INNER CLASSES
    // ========================================================================
    
    /**
     * Input request for contract analysis
     */
    public class ContractAnalysisRequest {
        @InvocableVariable(
            label='Opportunity ID' 
            description='ID of the Opportunity with contract documents'
            required=true
        )
        public Id opportunityId;
    }
    
    /**
     * Result of contract analysis
     */
    public class ContractAnalysisResult {
        @InvocableVariable
        public Boolean success;
        
        @InvocableVariable
        public String errorMessage;
        
        @InvocableVariable
        public Id opportunityId;
        
        @InvocableVariable
        public Integer documentsFound;
        
        @InvocableVariable
        public List<String> documentNames;
        
        @InvocableVariable
        public String paymentTerms;
        
        @InvocableVariable
        public Decimal uptime;
        
        @InvocableVariable
        public Decimal rolloverPercent;
        
        @InvocableVariable
        public Decimal liabilityCap;
        
        @InvocableVariable
        public String riskLevel;
        
        @InvocableVariable
        public Integer riskScore;
        
        @InvocableVariable
        public List<String> riskFactors;
        
        @InvocableVariable
        public List<String> recommendations;
        
        @InvocableVariable
        public String summary;
    }
    
    /**
     * Internal risk assessment wrapper
     */
    private class RiskAssessment {
        public String level;
        public Integer score;
        public List<String> factors;
        
        public RiskAssessment() {
            this.level = 'Low';
            this.score = 0;
            this.factors = new List<String>();
        }
    }
}

