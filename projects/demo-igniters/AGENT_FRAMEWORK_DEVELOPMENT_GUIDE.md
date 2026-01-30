# Salesforce Agent Framework Development Guide

## Overview

This guide documents the complete development process for creating and deploying Salesforce Agent APEX classes and Lightning Web Components (LWCs) that enable intelligent, productive actions for Salesforce Agents. This framework was developed to make building and demoing Agents in Salesforce easier and more valuable for organizations.

## Table of Contents

1. [Framework Architecture](#framework-architecture)
2. [Development Process](#development-process)
3. [Agent APEX Classes](#agent-apex-classes)
4. [Lightning Web Components](#lightning-web-components)
5. [Deployment and Testing](#deployment-and-testing)
6. [MCP Integration](#mcp-integration)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)
9. [Use Cases and Examples](#use-cases-and-examples)

---

## Framework Architecture

### Core Components

The Agent Framework consists of three main components:

1. **AgentActionController** - Base controller providing common functionality
2. **Agent Classes** - Specific implementations for different business scenarios
3. **Lightning Web Components** - User interface components for Agent interactions

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Salesforce Agent Framework               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   LWC Layer     │    │  Apex Layer     │                │
│  │                 │    │                 │                │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                │
│  │ │leadQualif-  │ │    │ │LeadQualif-  │ │                │
│  │ │ication      │ │    │ │icationAgent │ │                │
│  │ └─────────────┘ │    │ └─────────────┘ │                │
│  │                 │    │                 │                │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                │
│  │ │enhancedEin- │ │    │ │Opportunity- │ │                │
│  │ │steinScoring │ │    │ │InsightAgent │ │                │
│  │ └─────────────┘ │    │ └─────────────┘ │                │
│  │                 │    │                 │                │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                │
│  │ │enhancedProd-│ │    │ │Customer-    │ │                │
│  │ │uctRecommen- │ │    │ │ServiceAgent │ │                │
│  │ │dation       │ │    │ └─────────────┘ │                │
│  │ └─────────────┘ │    │                 │                │
│  └─────────────────┘    │ ┌─────────────┐ │                │
│                         │ │AgentAction- │ │                │
│                         │ │Controller   │ │                │
│                         │ │(Base Class) │ │                │
│                         │ └─────────────┘ │                │
│                         └─────────────────┘                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Key Design Principles

1. **Standardization**: All Agent classes follow the same interface and response structure
2. **Extensibility**: Easy to add new Agent capabilities by extending the base framework
3. **Reusability**: Components can be used across different Salesforce objects
4. **Maintainability**: Clear separation of concerns and consistent patterns

---

## Development Process

### Phase 1: Planning and Requirements

#### 1.1 Identify Use Cases

**Common valuable use cases for Salesforce Agents:**

1. **Lead Qualification Agent**
   - Automatically score and qualify leads
   - Provide actionable insights and recommendations
   - Update lead records with scores and next actions

2. **Opportunity Insight Agent**
   - Analyze opportunities for risk assessment
   - Identify at-risk opportunities
   - Provide pipeline insights and recommendations

3. **Customer Service Agent**
   - Analyze cases for resolution insights
   - Auto-assign cases to appropriate agents
   - Provide service metrics and recommendations

4. **Product Recommendation Agent**
   - Recommend products based on customer data
   - Enable product comparison and selection
   - Integrate with opportunity management

#### 1.2 Define Success Criteria

For each use case, define:
- Business objectives
- Key performance indicators
- User acceptance criteria
- Technical requirements

### Phase 2: Technical Design

#### 2.1 Agent Class Design

**Base Controller Structure:**
```apex
public virtual with sharing class AgentActionController {
    public class AgentResponse {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Object data { get; set; }
        @AuraEnabled public List<String> errors { get; set; }
    }

    public interface AgentAction {
        AgentResponse execute(Map<String, Object> parameters);
        String getActionName();
        String getDescription();
        List<String> getRequiredParameters();
    }
}
```

#### 2.2 LWC Component Design

**Standard Component Structure:**
```javascript
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AgentComponent extends LightningElement {
    @api recordId;
    @track result;
    @track isLoading = false;

    // Component implementation
}
```

### Phase 3: Implementation

#### 3.1 Create Agent Apex Classes

**Step 1: Create Base Controller**
```bash
# Create the base controller
touch force-app/main/default/classes/AgentActionController.cls
touch force-app/main/default/classes/AgentActionController.cls-meta.xml
```

**Step 2: Implement Specific Agent Classes**
```bash
# Create specific agent implementations
touch force-app/main/default/classes/LeadQualificationAgent.cls
touch force-app/main/default/classes/LeadQualificationAgent.cls-meta.xml
```

**Step 3: Add @AuraEnabled Methods**
```apex
@AuraEnabled(cacheable=false)
public static AgentResponse qualifyLead(Id leadId) {
    // Implementation
}
```

#### 3.2 Create Lightning Web Components

**Step 1: Create Component Structure**
```bash
# Create LWC directory structure
mkdir -p force-app/main/default/lwc/leadQualification
touch force-app/main/default/lwc/leadQualification/leadQualification.js
touch force-app/main/default/lwc/leadQualification/leadQualification.html
touch force-app/main/default/lwc/leadQualification/leadQualification.css
touch force-app/main/default/lwc/leadQualification/leadQualification.js-meta.xml
```

**Step 2: Implement Component Logic**
```javascript
// Import Apex method
import qualifyLead from '@salesforce/apex/LeadQualificationAgent.qualifyLead';

// Call Apex method
qualifyLead({ leadId: this.recordId })
    .then(response => {
        if (response.success) {
            this.result = response;
            // Handle success
        } else {
            // Handle error
        }
    });
```

### Phase 4: Testing and Validation

#### 4.1 Unit Testing

**Create Test Classes:**
```bash
touch force-app/main/default/classes/LeadQualificationAgentTest.cls
touch force-app/main/default/classes/LeadQualificationAgentTest.cls-meta.xml
```

**Test Implementation:**
```apex
@isTest
public class LeadQualificationAgentTest {
    @testSetup
    static void setupTestData() {
        // Create test data
    }

    @isTest
    static void testQualifyLead() {
        // Test implementation
    }
}
```

#### 4.2 Integration Testing

**Test LWC Components:**
```javascript
// Test component behavior
import { createElement } from 'lwc';
import LeadQualification from 'c/leadQualification';

describe('Lead Qualification Component', () => {
    it('should qualify lead successfully', () => {
        // Test implementation
    });
});
```

### Phase 5: Deployment

#### 5.1 Automated Deployment

**Create Deployment Script:**
```javascript
// scripts/deploy-agent-classes.js
const { execSync } = require('child_process');

async function deployAgentClasses() {
    try {
        console.log('Deploying Agent classes...');
        
        // Deploy Apex classes
        execSync('sf project deploy start --source-dir force-app/main/default/classes --test-level NoTestRun --wait 10', 
            { stdio: 'inherit' });
        
        // Deploy LWCs
        execSync('sf project deploy start --source-dir force-app/main/default/lwc --test-level NoTestRun --wait 10', 
            { stdio: 'inherit' });
        
        console.log('Deployment completed successfully');
    } catch (error) {
        console.error('Deployment failed:', error.message);
        process.exit(1);
    }
}

deployAgentClasses();
```

#### 5.2 Manual Deployment

**Deploy Individual Components:**
```bash
# Deploy specific LWC
sf project deploy start --source-dir force-app/main/default/lwc/leadQualification --test-level NoTestRun --wait 10

# Deploy specific Apex class
sf project deploy start --source-dir force-app/main/default/classes/LeadQualificationAgent.cls --test-level NoTestRun --wait 10
```

---

## Agent APEX Classes

### AgentActionController

**Purpose**: Base controller providing common functionality and response structures for all Agent classes.

**Key Features**:
- Standardized `AgentResponse` structure
- `AgentAction` interface for consistent implementation
- Utility methods for parameter validation and response creation
- Virtual class design for extensibility

**Usage**:
```apex
public class MyCustomAgent extends AgentActionController implements AgentAction {
    public AgentResponse execute(Map<String, Object> parameters) {
        // Implementation
        return createSuccessResponse("Operation completed", resultData);
    }
}
```

### LeadQualificationAgent

**Purpose**: Automatically qualify leads based on multiple business criteria and provide actionable insights.

**Key Methods**:
- `qualifyLead(Id leadId)` - Qualify a single lead
- `batchQualifyLeads(List<Id> leadIds)` - Qualify multiple leads
- `getQualificationInsights(Id leadId)` - Get detailed insights

**Scoring Criteria**:
- Company Size (0-25 points)
- Revenue (0-25 points)
- Contact Completeness (0-20 points)
- Industry (0-15 points)
- Lead Source (0-15 points)

**Grade Scale**:
- A (80+ points): Immediate follow-up
- B (60-79 points): Follow-up within 24 hours
- C (40-59 points): Nurture campaign
- D (<40 points): Further qualification needed

### OpportunityInsightAgent

**Purpose**: Analyze opportunities for risk assessment, insights, and actionable recommendations.

**Key Methods**:
- `analyzeOpportunity(Id opportunityId)` - Analyze single opportunity
- `analyzePipeline(Id ownerId)` - Analyze pipeline
- `getAtRiskOpportunities(Id ownerId)` - Identify at-risk opportunities

**Risk Assessment Factors**:
- Probability (Low win probability)
- Timeline (Closing within 7/30 days)
- Value (High-value opportunities)
- Stage (Early stage opportunities)

### CustomerServiceAgent

**Purpose**: Intelligent customer service and case management with automated insights and recommendations.

**Key Methods**:
- `analyzeCase(Id caseId)` - Analyze case for insights
- `getServiceMetrics(Id ownerId, Integer daysBack)` - Get service metrics
- `getCasesNeedingAttention(Id ownerId)` - Get cases needing attention
- `autoAssignCase(Id caseId)` - Auto-assign case to best agent

---

## Lightning Web Components

### leadQualification

**Purpose**: User interface for lead qualification with AI scoring and insights.

**Key Features**:
- Lead information display with grid layout
- AI qualification button with loading states
- Score and grade visualization
- Collapsible detailed analysis
- Data completeness calculation
- Toast notifications for user feedback

**Implementation Highlights**:
```javascript
// Dynamic button labels
get buttonLabel() {
    return this.showDetails ? 'Hide Details' : 'Show Details';
}

// Data completeness calculation
get dataCompleteness() {
    return this.calculateDataCompleteness();
}

// Score-based CSS classes
get scoreClass() {
    if (!this.qualificationResult || !this.qualificationResult.data) return '';
    const score = this.qualificationResult.data.score;
    if (score >= 80) return 'score-high';
    if (score >= 50) return 'score-medium';
    return 'score-low';
}
```

### enhancedEinsteinScoring

**Purpose**: Enhanced Einstein scoring component with comprehensive analytics and insights.

**Key Features**:
- Einstein score retrieval and display
- Trend analysis with icons
- Confidence level indicators
- Key factors and recommended actions
- Collapsible detailed analysis
- Professional styling and animations

### enhancedProductRecommendation

**Purpose**: Multi-product recommendation component with comparison capabilities.

**Key Features**:
- Multiple product recommendations
- Product selection with checkboxes
- Product comparison modal
- Navigation to product detail pages
- Price formatting and display
- Responsive grid layout

---

## Deployment and Testing

### Automated Deployment Scripts

#### deploy-agent-classes.js

**Purpose**: Automated deployment of all Agent framework components.

**Usage**:
```bash
# Deploy all components
node scripts/deploy-agent-classes.js

# Deploy with specific test level
node scripts/deploy-agent-classes.js --test-level RunLocalTests --wait 15
```

**Features**:
- Deploys Apex classes and LWCs
- Configurable test levels
- Error handling and rollback
- Progress tracking and logging

#### test-agent-classes.js

**Purpose**: Automated testing of Agent classes with example scenarios.

**Usage**:
```bash
# Run all tests
node scripts/test-agent-classes.js

# Run specific test
node scripts/test-agent-classes.js --test leadQualification
```

### Manual Testing

#### Anonymous Apex Testing

**Test Individual Methods**:
```apex
// Test lead qualification
AgentResponse response = LeadQualificationAgent.qualifyLead('00Q000000000001');
System.debug('Response: ' + response);

// Test opportunity analysis
AgentResponse oppResponse = OpportunityInsightAgent.analyzeOpportunity('006000000000001');
System.debug('Opportunity Analysis: ' + oppResponse);
```

#### LWC Component Testing

**Test Component Behavior**:
```javascript
// Test in browser console
const component = document.querySelector('c-lead-qualification');
component.handleQualifyLead();
```

### Deployment Validation

#### Post-Deployment Checks

1. **Verify Apex Classes**:
   ```bash
   sf data query --query "SELECT Id, Name FROM ApexClass WHERE Name LIKE '%Agent%'"
   ```

2. **Verify LWCs**:
   ```bash
   sf data query --query "SELECT Id, DeveloperName FROM LightningComponentBundle WHERE DeveloperName LIKE '%Agent%'"
   ```

3. **Test Functionality**:
   - Navigate to Lead record page
   - Add LWC component
   - Test qualification functionality
   - Verify score and grade display

---

## MCP Integration

### Model Context Protocol Setup

**Purpose**: Enable Cursor to interact with Salesforce orgs through MCP server.

#### MCP Server Configuration

**File**: `mcp/salesforce-mcp-server.js`

**Key Features**:
- SOQL query execution
- Apex code execution (sandbox only)
- Metadata deployment
- Data import/export
- Flow management
- Script execution

**Available Tools**:
- `soql.query` - Execute SOQL queries
- `apex.execute` - Execute anonymous Apex
- `metadata.deploy` - Deploy metadata
- `data.import.csv` - Import CSV data
- `flow.manage` - Manage flows
- `scripts.run` - Execute scripts

#### MCP Client Configuration

**File**: `~/.cursor/mcp.json`

```json
{
  "mcpServers": {
    "salesforce": {
      "command": "node",
      "args": ["/Users/sargo/Documents/demo-igniters/demo-igniters/mcp/salesforce-mcp-server.js"],
      "env": {
        "SFDX_DEFAULTUSERNAME": "your-org-username",
        "SANDBOX_OK": "1"
      }
    }
  }
}
```

#### Usage Examples

**Query Leads**:
```bash
# Via MCP server
sf data query --query "SELECT Id, Name, Company, Status FROM Lead LIMIT 10"
```

**Execute Apex**:
```bash
# Via MCP server
sf apex run --file scripts/apex/agent-examples.apex
```

**Deploy Metadata**:
```bash
# Via MCP server
sf project deploy start --source-dir force-app/main/default/classes --test-level NoTestRun
```

---

## Best Practices

### Development Best Practices

#### 1. Code Organization

**File Structure**:
```
force-app/main/default/
├── classes/
│   ├── AgentActionController.cls
│   ├── LeadQualificationAgent.cls
│   ├── OpportunityInsightAgent.cls
│   └── CustomerServiceAgent.cls
├── lwc/
│   ├── leadQualification/
│   ├── enhancedEinsteinScoring/
│   └── enhancedProductRecommendation/
└── objects/
    └── Lead/
        └── fields/
            ├── Qualification_Score__c.field-meta.xml
            └── Next_Action__c.field-meta.xml
```

#### 2. Naming Conventions

**Apex Classes**:
- Use descriptive names ending with "Agent"
- Follow PascalCase convention
- Include purpose in name (e.g., `LeadQualificationAgent`)

**Lightning Web Components**:
- Use camelCase for component names
- Include functionality in name (e.g., `leadQualification`)
- Use descriptive CSS class names

**Custom Fields**:
- Use descriptive names with proper suffixes
- Follow Salesforce naming conventions
- Include object context (e.g., `Lead.Qualification_Score__c`)

#### 3. Error Handling

**Apex Error Handling**:
```apex
public static AgentResponse qualifyLead(Id leadId) {
    try {
        // Validation
        if (leadId == null) {
            return createErrorResponse('Lead ID is required', new List<String>{'INVALID_INPUT'});
        }

        // Business logic
        Lead lead = [SELECT Id, Name, Company FROM Lead WHERE Id = :leadId];
        
        // Process qualification
        QualificationResult result = processQualification(lead);
        
        return createSuccessResponse('Lead qualified successfully', result);
    } catch (Exception e) {
        return createErrorResponse('Error qualifying lead: ' + e.getMessage(), new List<String>{e.getMessage()});
    }
}
```

**LWC Error Handling**:
```javascript
handleQualifyLead() {
    this.isLoading = true;
    
    qualifyLead({ leadId: this.recordId })
        .then(response => {
            if (response.success) {
                this.qualificationResult = response;
                this.showResults = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Lead qualified successfully',
                        variant: 'success'
                    })
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: response.message,
                        variant: 'error'
                    })
                );
            }
        })
        .catch(error => {
            console.error('Error:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'An unexpected error occurred',
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.isLoading = false;
        });
}
```

#### 4. Performance Optimization

**SOQL Optimization**:
```apex
// Use selective queries
List<Lead> leads = [SELECT Id, Name, Company, Email, Phone 
                   FROM Lead 
                   WHERE Status = 'New' 
                   AND CreatedDate = TODAY 
                   LIMIT 200];

// Use aggregate queries when possible
List<AggregateResult> results = [SELECT COUNT(Id) total, Status 
                                FROM Lead 
                                GROUP BY Status];
```

**Bulk Operations**:
```apex
// Process records in batches
public static AgentResponse batchQualifyLeads(List<Id> leadIds) {
    List<Lead> leads = [SELECT Id, Name, Company FROM Lead WHERE Id IN :leadIds];
    List<Lead> leadsToUpdate = new List<Lead>();
    
    for (Lead lead : leads) {
        QualificationResult result = processQualification(lead);
        lead.Qualification_Score__c = result.score;
        lead.Next_Action__c = result.nextAction;
        leadsToUpdate.add(lead);
    }
    
    update leadsToUpdate;
    return createSuccessResponse('Batch qualification completed', leadsToUpdate.size());
}
```

#### 5. Security Considerations

**Sharing and Security**:
```apex
// Use with sharing
public with sharing class LeadQualificationAgent extends AgentActionController {
    // Implementation
}

// Validate input parameters
public static AgentResponse qualifyLead(Id leadId) {
    // Validate leadId format
    if (!String.valueOf(leadId).startsWith('00Q')) {
        return createErrorResponse('Invalid Lead ID format', new List<String>{'INVALID_LEAD_ID'});
    }
    
    // Check object permissions
    if (!Schema.sObjectType.Lead.isAccessible()) {
        return createErrorResponse('Insufficient permissions', new List<String>{'INSUFFICIENT_PERMISSIONS'});
    }
}
```

**Field-Level Security**:
```javascript
// Check field accessibility in LWC
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

// Use field references for security
import LEAD_NAME_FIELD from '@salesforce/schema/Lead.Name';
import LEAD_COMPANY_FIELD from '@salesforce/schema/Lead.Company';
```

### Testing Best Practices

#### 1. Test Coverage

**Apex Test Classes**:
```apex
@isTest
public class LeadQualificationAgentTest {
    @testSetup
    static void setupTestData() {
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead' + i,
                Company = 'Test Company' + i,
                Email = 'test' + i + '@example.com',
                Phone = '555-000' + i,
                Industry = 'Technology',
                AnnualRevenue = 1000000,
                NumberOfEmployees = 100,
                LeadSource = 'Web',
                Status = 'New'
            ));
        }
        insert testLeads;
    }

    @isTest
    static void testQualifyLead_Success() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        
        Test.startTest();
        AgentResponse response = LeadQualificationAgent.qualifyLead(testLead.Id);
        Test.stopTest();
        
        System.assert(response.success, 'Qualification should succeed');
        System.assertNotEquals(null, response.data, 'Response data should not be null');
    }

    @isTest
    static void testQualifyLead_InvalidId() {
        Test.startTest();
        AgentResponse response = LeadQualificationAgent.qualifyLead(null);
        Test.stopTest();
        
        System.assert(!response.success, 'Qualification should fail');
        System.assert(response.errors.size() > 0, 'Should have error messages');
    }
}
```

#### 2. Integration Testing

**LWC Component Testing**:
```javascript
// Test component behavior
import { createElement } from 'lwc';
import LeadQualification from 'c/leadQualification';
import qualifyLead from '@salesforce/apex/LeadQualificationAgent.qualifyLead';

// Mock Apex method
jest.mock('@salesforce/apex/LeadQualificationAgent.qualifyLead', () => {
    return { default: jest.fn() };
});

describe('Lead Qualification Component', () => {
    it('should qualify lead successfully', async () => {
        const mockResponse = {
            success: true,
            data: { score: 85, grade: 'A' },
            message: 'Lead qualified successfully'
        };
        
        qualifyLead.mockResolvedValue(mockResponse);
        
        const element = createElement('c-lead-qualification', {
            is: LeadQualification
        });
        element.recordId = '00Q000000000001';
        document.body.appendChild(element);
        
        // Test component behavior
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();
        
        await Promise.resolve();
        
        expect(qualifyLead).toHaveBeenCalledWith({ leadId: '00Q000000000001' });
    });
});
```

### Deployment Best Practices

#### 1. Environment Management

**Environment Configuration**:
```bash
# Set default org
sf config set target-org your-org-username

# Verify org connection
sf org display

# List available orgs
sf org list
```

**Deployment Validation**:
```bash
# Validate deployment
sf project deploy validate --source-dir force-app/main/default/classes

# Deploy with validation
sf project deploy start --source-dir force-app/main/default/classes --test-level NoTestRun --wait 10
```

#### 2. Rollback Strategy

**Backup Before Deployment**:
```bash
# Retrieve current metadata
sf project retrieve start --source-dir force-app/main/default/classes

# Create backup
cp -r force-app/main/default/classes force-app/main/default/classes.backup
```

**Rollback Procedure**:
```bash
# Restore from backup
rm -rf force-app/main/default/classes
mv force-app/main/default/classes.backup force-app/main/default/classes

# Redeploy
sf project deploy start --source-dir force-app/main/default/classes --test-level NoTestRun
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Deployment Issues

**Issue**: Apex compilation errors
```
Error: Non-virtual and non-abstract type cannot be extended: AgentActionController
```

**Solution**: Make base class virtual
```apex
public virtual with sharing class AgentActionController {
    // Implementation
}
```

**Issue**: Permission errors
```
Error: Insufficient privileges to access object Lead
```

**Solution**: Check object permissions and sharing rules
```bash
# Check object permissions
sf data query --query "SELECT Id, Name FROM Lead LIMIT 1"

# Verify user permissions
sf org display --target-org your-org
```

#### 2. LWC Issues

**Issue**: Component not displaying
```
Error: Component not found or not accessible
```

**Solution**: Check component metadata and permissions
```xml
<!-- leadQualification.js-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__RecordPage</target>
        <target>lightning__AppPage</target>
        <target>lightning__HomePage</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>Lead</object>
            </objects>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

**Issue**: Apex method not found
```
Error: Method 'qualifyLead' not found
```

**Solution**: Check method signature and @AuraEnabled annotation
```apex
@AuraEnabled(cacheable=false)
public static AgentResponse qualifyLead(Id leadId) {
    // Implementation
}
```

#### 3. MCP Server Issues

**Issue**: MCP server not starting
```
Error: Cannot find module '@modelcontextprotocol/sdk'
```

**Solution**: Reinstall MCP SDK
```bash
cd /Users/sargo/Documents/demo-igniters/demo-igniters
npm install @modelcontextprotocol/sdk
```

**Issue**: SOQL query errors
```
Error: sObject type 'Lead' is not supported
```

**Solution**: Check object name and permissions
```bash
# List available objects
sf data query --query "SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName LIKE '%Lead%'"

# Test simple query
sf data query --query "SELECT Id FROM Lead LIMIT 1"
```

### Debugging Strategies

#### 1. Enable Debug Logs

**Salesforce Debug Logs**:
```bash
# Tail debug logs
sf apex log tail

# Get specific log
sf apex log get --log-id 07L000000000001
```

**LWC Console Logging**:
```javascript
// Add console logging
console.log('Component initialized');
console.log('Record ID:', this.recordId);
console.log('Response:', response);
```

#### 2. Test in Anonymous Apex

**Test Individual Methods**:
```apex
// Test in Developer Console
AgentResponse response = LeadQualificationAgent.qualifyLead('00Q000000000001');
System.debug('Response: ' + JSON.serialize(response));
```

#### 3. Component Inspection

**Browser Developer Tools**:
```javascript
// Inspect component in browser
const component = document.querySelector('c-lead-qualification');
console.log('Component:', component);
console.log('Record ID:', component.recordId);
```

---

## Use Cases and Examples

### Use Case 1: Lead Qualification Demo

**Scenario**: Sales team needs to quickly qualify incoming leads and prioritize follow-up actions.

**Implementation**:
1. Deploy `LeadQualificationAgent` and `leadQualification` LWC
2. Add component to Lead record pages
3. Configure scoring criteria based on business requirements
4. Train users on interpretation of scores and grades

**Demo Script**:
1. Navigate to Lead record page
2. Show lead information display
3. Click "Qualify Lead with AI" button
4. Explain scoring criteria and grade interpretation
5. Show detailed analysis and recommendations
6. Demonstrate follow-up actions based on score

### Use Case 2: Opportunity Risk Assessment

**Scenario**: Sales managers need to identify at-risk opportunities and take proactive measures.

**Implementation**:
1. Deploy `OpportunityInsightAgent`
2. Create custom LWC for opportunity analysis
3. Configure risk assessment criteria
4. Set up automated alerts for high-risk opportunities

**Demo Script**:
1. Navigate to Opportunity record page
2. Show opportunity analysis component
3. Explain risk factors and scoring
4. Demonstrate risk mitigation recommendations
5. Show pipeline-level insights

### Use Case 3: Customer Service Optimization

**Scenario**: Service team needs to improve case resolution times and customer satisfaction.

**Implementation**:
1. Deploy `CustomerServiceAgent`
2. Create service dashboard LWC
3. Configure service metrics and KPIs
4. Implement auto-assignment logic

**Demo Script**:
1. Navigate to Case record page
2. Show case analysis and insights
3. Demonstrate auto-assignment functionality
4. Explain service metrics and trends
5. Show improvement recommendations

### Use Case 4: Product Recommendation Engine

**Scenario**: Sales team needs intelligent product recommendations to increase deal size and close rates.

**Implementation**:
1. Deploy `enhancedProductRecommendation` LWC
2. Configure recommendation algorithms
3. Set up product comparison features
4. Integrate with opportunity management

**Demo Script**:
1. Navigate to Account or Opportunity record page
2. Show product recommendation component
3. Explain recommendation logic
4. Demonstrate product comparison
5. Show integration with opportunity workflow

---

## Conclusion

The Salesforce Agent Framework provides a comprehensive foundation for building intelligent, productive Agents in Salesforce. Key takeaways:

1. **Standardization**: Consistent patterns and interfaces enable rapid development
2. **Extensibility**: Easy to add new Agent capabilities by following established patterns
3. **User Experience**: Rich LWC components provide intuitive interfaces for Agent interactions
4. **Automation**: Deployment and testing scripts streamline the development process
5. **Integration**: MCP server enables seamless integration with development tools

### Next Steps

1. **Expand Agent Capabilities**: Add new Agent classes for additional use cases
2. **Enhance UI Components**: Create more sophisticated LWC components
3. **Improve Automation**: Add more deployment and testing automation
4. **Documentation**: Maintain and update documentation as the framework evolves
5. **Training**: Train other Solution Engineers on framework usage and best practices

### Resources

- **Documentation**: See individual class and component documentation
- **Examples**: Check `scripts/apex/agent-examples.apex` for usage examples
- **Testing**: Use `scripts/test-agent-classes.js` for automated testing
- **Deployment**: Use `scripts/deploy-agent-classes.js` for automated deployment

---

*This guide is maintained by the Solution Engineering Team. For questions or contributions, please contact the team.*
