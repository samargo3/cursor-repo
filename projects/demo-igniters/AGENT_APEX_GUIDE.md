# Salesforce Agent APEX Classes Guide

## Overview

This guide provides comprehensive documentation for the Salesforce Agent APEX classes designed to enable intelligent, productive actions for Salesforce Agents. These classes provide real business value through automated insights, recommendations, and actions.

## Architecture

### Base Framework
- **AgentActionController**: Base controller providing common functionality and response structures
- **AgentAction Interface**: Standardized interface for all Agent capabilities
- **AgentResponse**: Consistent response structure across all agents

### Agent Classes
1. **LeadQualificationAgent**: Intelligent lead scoring and qualification
2. **OpportunityInsightAgent**: Opportunity analysis and risk assessment  
3. **CustomerServiceAgent**: Case management and service insights

## Quick Start

### 1. Deploy Agent Classes
```bash
# Deploy all Agent classes
node scripts/deploy-agent-classes.js

# Deploy with specific test level
node scripts/deploy-agent-classes.js --test-level RunLocalTests --wait 15
```

### 2. Test the Classes
```bash
# Run test examples
sf apex run --file scripts/apex/agent-examples.apex

# Or use the test script
node scripts/test-agent-classes.js
```

## Agent Classes Documentation

### LeadQualificationAgent

**Purpose**: Automatically qualify leads based on multiple business criteria and provide actionable insights.

#### Methods

##### `qualifyLead(Id leadId)`
Qualifies a single lead and updates its rating.

**Parameters**:
- `leadId` (Id): The ID of the lead to qualify

**Returns**: `AgentResponse` with qualification results

**Example**:
```apex
AgentResponse response = LeadQualificationAgent.qualifyLead('00Q000000000001');
if (response.success) {
    System.debug('Lead qualified: ' + response.data);
}
```

##### `batchQualifyLeads(List<Id> leadIds)`
Qualifies multiple leads in batch.

**Parameters**:
- `leadIds` (List<Id>): List of lead IDs to qualify

**Returns**: `AgentResponse` with batch results

**Example**:
```apex
List<Id> leadIds = new List<Id>{'00Q000000000001', '00Q000000000002'};
AgentResponse response = LeadQualificationAgent.batchQualifyLeads(leadIds);
```

##### `getQualificationInsights(Id leadId)`
Gets detailed insights for a lead.

**Parameters**:
- `leadId` (Id): The ID of the lead

**Returns**: `AgentResponse` with insights

**Example**:
```apex
AgentResponse response = LeadQualificationAgent.getQualificationInsights('00Q000000000001');
```

#### Qualification Criteria

The agent scores leads based on:
- **Company Size** (0-25 points): Number of employees
- **Revenue** (0-25 points): Annual revenue potential
- **Contact Completeness** (0-20 points): Email and phone availability
- **Industry** (0-15 points): Industry identification
- **Lead Source** (0-15 points): Lead source tracking

**Scoring Grades**:
- **A (80+ points)**: Immediate follow-up - High priority
- **B (60-79 points)**: Schedule follow-up within 24 hours
- **C (40-59 points)**: Nurture campaign - Follow up in 1 week
- **D (<40 points)**: Qualify further or consider disqualifying

### OpportunityInsightAgent

**Purpose**: Analyze opportunities for risk assessment, insights, and actionable recommendations.

#### Methods

##### `analyzeOpportunity(Id opportunityId)`
Analyzes a single opportunity for insights.

**Parameters**:
- `opportunityId` (Id): The ID of the opportunity to analyze

**Returns**: `AgentResponse` with opportunity insights

**Example**:
```apex
AgentResponse response = OpportunityInsightAgent.analyzeOpportunity('006000000000001');
```

##### `analyzePipeline(Id ownerId)`
Analyzes the pipeline for overall insights.

**Parameters**:
- `ownerId` (Id, optional): Owner ID to filter by specific user

**Returns**: `AgentResponse` with pipeline insights

**Example**:
```apex
// Analyze all opportunities
AgentResponse response = OpportunityInsightAgent.analyzePipeline(null);

// Analyze opportunities for specific user
AgentResponse response = OpportunityInsightAgent.analyzePipeline('005000000000001');
```

##### `getAtRiskOpportunities(Id ownerId)`
Identifies opportunities at risk.

**Parameters**:
- `ownerId` (Id, optional): Owner ID to filter by specific user

**Returns**: `AgentResponse` with at-risk opportunities

**Example**:
```apex
AgentResponse response = OpportunityInsightAgent.getAtRiskOpportunities(null);
```

#### Risk Assessment

The agent identifies risks based on:
- **Probability**: Low win probability
- **Timeline**: Closing within 7/30 days
- **Value**: High-value opportunities
- **Stage**: Early stage opportunities

**Risk Levels**:
- **High**: 3+ risk factors - Immediate intervention required
- **Medium**: 2 risk factors - Schedule review meeting
- **Low**: 1 risk factor - Monitor and follow up
- **None**: No risk factors - Continue current approach

### CustomerServiceAgent

**Purpose**: Intelligent customer service and case management with automated insights and recommendations.

#### Methods

##### `analyzeCase(Id caseId)`
Analyzes a case for insights and recommendations.

**Parameters**:
- `caseId` (Id): The ID of the case to analyze

**Returns**: `AgentResponse` with case insights

**Example**:
```apex
AgentResponse response = CustomerServiceAgent.analyzeCase('500000000000001');
```

##### `getServiceMetrics(Id ownerId, Integer daysBack)`
Gets service metrics for a team or individual.

**Parameters**:
- `ownerId` (Id, optional): Owner ID to filter by specific user
- `daysBack` (Integer): Number of days to look back (default: 30)

**Returns**: `AgentResponse` with service metrics

**Example**:
```apex
// Get metrics for all users, last 30 days
AgentResponse response = CustomerServiceAgent.getServiceMetrics(null, 30);

// Get metrics for specific user, last 7 days
AgentResponse response = CustomerServiceAgent.getServiceMetrics('005000000000001', 7);
```

##### `getCasesNeedingAttention(Id ownerId)`
Gets cases requiring attention.

**Parameters**:
- `ownerId` (Id, optional): Owner ID to filter by specific user

**Returns**: `AgentResponse` with cases needing attention

**Example**:
```apex
AgentResponse response = CustomerServiceAgent.getCasesNeedingAttention(null);
```

##### `autoAssignCase(Id caseId)`
Auto-assigns a case to the best available agent.

**Parameters**:
- `caseId` (Id): The ID of the case to assign

**Returns**: `AgentResponse` with assignment result

**Example**:
```apex
AgentResponse response = CustomerServiceAgent.autoAssignCase('500000000000001');
```

#### Service Metrics

The agent tracks:
- **Total Cases**: Total number of cases
- **Open/Closed Cases**: Case status breakdown
- **Average Resolution Time**: Time to resolve cases
- **Customer Satisfaction**: Satisfaction score
- **Top Issues**: Most common issue types
- **Recommendations**: Actionable improvements

## Integration with Salesforce Agents

### Agent Configuration

To use these classes with Salesforce Agents, configure them in your Agent Builder:

1. **Create Agent Actions**:
   ```yaml
   actions:
     - name: "Lead Qualification"
       type: "apex"
       class: "LeadQualificationAgent"
       method: "qualifyLead"
       parameters:
         - name: "leadId"
           type: "Id"
           required: true
   ```

2. **Define Agent Capabilities**:
   ```yaml
   capabilities:
     - name: "Lead Management"
       description: "Qualify and score leads automatically"
       actions: ["Lead Qualification"]
     - name: "Opportunity Analysis"
       description: "Analyze opportunities for insights"
       actions: ["Opportunity Analysis"]
     - name: "Customer Service"
       description: "Manage cases and provide service insights"
       actions: ["Case Analysis"]
   ```

### Agent Prompts

Example prompts for Agents to use these classes:

**Lead Qualification Agent**:
```
"Qualify this lead and provide a score and recommendations"
"Analyze the lead's potential and suggest next steps"
"Score this lead based on our qualification criteria"
```

**Opportunity Insight Agent**:
```
"Analyze this opportunity for risks and insights"
"Identify opportunities that need attention"
"Provide pipeline insights and recommendations"
```

**Customer Service Agent**:
```
"Analyze this case and suggest resolution steps"
"Identify cases that need immediate attention"
"Provide service metrics and recommendations"
```

## Best Practices

### 1. Performance Optimization
- Use batch operations for multiple records
- Implement proper error handling
- Consider governor limits
- Use appropriate SOQL queries

### 2. Security
- Implement proper sharing rules
- Use with sharing classes
- Validate input parameters
- Handle sensitive data appropriately

### 3. Testing
- Write comprehensive test classes
- Test edge cases and error conditions
- Validate response structures
- Test with different data scenarios

### 4. Monitoring
- Log important operations
- Track performance metrics
- Monitor error rates
- Set up alerts for failures

## Troubleshooting

### Common Issues

1. **Permission Errors**:
   - Ensure proper object permissions
   - Check field-level security
   - Verify sharing rules

2. **Data Not Found**:
   - Validate record IDs
   - Check data availability
   - Verify query filters

3. **Performance Issues**:
   - Review SOQL queries
   - Check governor limits
   - Optimize batch sizes

### Debug Tips

1. **Enable Debug Logs**:
   ```bash
   sf apex log tail
   ```

2. **Test in Anonymous Apex**:
   ```apex
   // Test individual methods
   AgentResponse response = LeadQualificationAgent.qualifyLead('00Q000000000001');
   System.debug('Response: ' + response);
   ```

3. **Check Data**:
   ```bash
   sf data query --query "SELECT Id, Name FROM Lead LIMIT 5"
   ```

## Advanced Usage

### Custom Scoring Models

Extend the qualification logic:

```apex
// Custom scoring for specific industries
if (lead.Industry == 'Healthcare') {
    // Add healthcare-specific scoring
    score += calculateHealthcareScore(lead);
}
```

### Integration with External Systems

```apex
// Integrate with external scoring services
public static Decimal getExternalScore(Lead lead) {
    // Call external API
    return externalScoringService.getScore(lead);
}
```

### Automated Workflows

```apex
// Trigger automated actions based on scores
if (result.score >= 80) {
    // Create high-priority task
    createHighPriorityTask(lead.Id);
}
```

## Support and Resources

- **Documentation**: See individual class documentation
- **Examples**: Check `scripts/apex/agent-examples.apex`
- **Testing**: Use `scripts/test-agent-classes.js`
- **Deployment**: Use `scripts/deploy-agent-classes.js`

## Version History

- **v1.0**: Initial release with core Agent classes
- **v1.1**: Added batch operations and performance improvements
- **v1.2**: Enhanced error handling and logging

---

*This guide is maintained by the Solution Engineering Team. For questions or contributions, please contact the team.*
