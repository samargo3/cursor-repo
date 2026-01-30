# 🚀 Quick Flow Deployment Guide

This guide shows you how to quickly create and deploy flows to your Salesforce demo org using Salesforce CLI and automation scripts.

## ⚡ Quick Start

### 1. Create and Deploy Demo Flows (One Command)
```bash
npm run demo:setup
```
This creates demo flows, deploys them, and sets up Einstein lead scoring data.

### 2. Individual Flow Operations
```bash
# Create all demo flows
npm run flow:create

# Deploy all flows to your org
npm run flow:deploy

# List available flows
npm run flow:list

# Create specific flows
npm run flow:create-lead
npm run flow:create-notification
```

## 🛠️ Manual Flow Deployment

### Using Salesforce CLI Directly

#### Deploy a Single Flow
```bash
sf project deploy start --metadata Flow:YourFlowName --target-org your-org-alias
```

#### Deploy All Flows in Project
```bash
sf project deploy start --source-dir force-app/main/default/flows --target-org your-org-alias
```

#### Deploy with Options
```bash
# Deploy with verbose output
sf project deploy start --metadata Flow:YourFlowName --target-org your-org-alias --verbose

# Deploy and ignore warnings
sf project deploy start --metadata Flow:YourFlowName --target-org your-org-alias --ignore-warnings

# Deploy with test execution
sf project deploy start --metadata Flow:YourFlowName --target-org your-org-alias --test-level RunLocalTests
```

## 📁 Flow Metadata Structure

Flows are stored in your project as:
```
force-app/main/default/flows/
├── FlowName/
│   ├── FlowName.flow-meta.xml    # Flow metadata
│   └── FlowName.flow             # Flow definition (JSON)
```

## 🎯 Demo Flow Templates

### 1. Lead Assignment Flow
- **Purpose**: Automatically assign leads based on industry
- **Trigger**: When a lead is created or updated
- **Logic**: Technology leads → Tech team, others → Sales team

### 2. Notification Flow
- **Purpose**: Send notifications for high-value leads
- **Trigger**: When a lead is created
- **Logic**: Revenue > $1M → Send notification

## 🔧 Creating Custom Flows

### Method 1: Using the Script
```bash
# Create a new flow template
node scripts/create-demo-flow.js create-custom --name "MyCustomFlow" --type "record-triggered"
```

### Method 2: Manual Creation
1. Create the flow directory:
   ```bash
   mkdir -p force-app/main/default/flows/MyCustomFlow
   ```

2. Create the metadata file (`MyCustomFlow.flow-meta.xml`):
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <Flow xmlns="http://soap.sforce.com/2006/04/metadata">
       <apiVersion>64.0</apiVersion>
       <description>My custom flow</description>
       <environments>Default</environments>
       <interviewLabel>My Custom Flow {!$Flow.CurrentDateTime}</interviewLabel>
       <label>My Custom Flow</label>
       <processMetadataValues>
           <name>BuilderType</name>
           <value>
               <stringValue>LightningFlowBuilder</stringValue>
           </value>
       </processMetadataValues>
       <processType>AutoLaunchedFlow</processType>
       <start>
           <locationX>50</locationX>
           <locationY>0</locationY>
       </start>
   </Flow>
   ```

3. Create the flow definition (`MyCustomFlow.flow`):
   ```json
   {
     "flow": {
       "apiVersion": "64.0",
       "description": "My custom flow",
       "environments": "Default",
       "interviewLabel": "My Custom Flow {!$Flow.CurrentDateTime}",
       "label": "My Custom Flow",
       "processMetadataValues": [
         {
           "name": "BuilderType",
           "value": {
             "stringValue": "LightningFlowBuilder"
           }
         }
       ],
       "processType": "AutoLaunchedFlow",
       "start": {
         "locationX": 50,
         "locationY": 0
       }
     }
   }
   ```

## 🔄 Flow Types and Triggers

### Auto-Launched Flows
```json
"processType": "AutoLaunchedFlow"
```
- Triggered by system events
- No user interaction required
- Good for automation

### Record-Triggered Flows
```json
"processType": "AutoLaunchedFlow",
"recordTriggerType": "Create"
```
- Triggered by record changes
- Can run before or after save
- Access to record data

### Screen Flows
```json
"processType": "Flow"
```
- User interaction required
- Collect input from users
- Good for guided processes

## 🎨 Flow Components

### Decisions
```json
"decisions": [
  {
    "name": "MyDecision",
    "label": "My Decision",
    "locationX": 176,
    "locationY": 0,
    "defaultConnector": {
      "targetReference": "DefaultPath"
    },
    "rules": [
      {
        "name": "Condition1",
        "conditionLogic": "and",
        "conditions": [
          {
            "leftValueReference": "{!$Record.Field__c}",
            "operator": "EqualTo",
            "rightValue": {
              "stringValue": "Value"
            }
          }
        ],
        "connector": {
          "targetReference": "Path1"
        }
      }
    ]
  }
]
```

### Assignments
```json
"assignments": [
  {
    "name": "MyAssignment",
    "label": "My Assignment",
    "locationX": 302,
    "locationY": 0,
    "assignmentItems": [
      {
        "assignToReference": "{!$Record.Id}",
        "field": "Field__c",
        "operator": "Assign",
        "value": {
          "stringValue": "New Value"
        }
      }
    ]
  }
]
```

### Action Calls
```json
"actionCalls": [
  {
    "name": "MyAction",
    "label": "My Action",
    "locationX": 428,
    "locationY": 0,
    "inputParameters": [
      {
        "name": "param1",
        "value": {
          "stringValue": "Value"
        }
      }
    ],
    "storeOutputAutomatically": true
  }
]
```

## 🔍 Troubleshooting

### Common Issues

**"Flow not found"**
- Check the flow name in metadata
- Ensure flow directory exists
- Verify flow-meta.xml file

**"Deployment failed"**
- Check API version compatibility
- Verify org permissions
- Review flow syntax

**"Flow not activating"**
- Check trigger conditions
- Verify field references
- Ensure proper connectors

### Debug Commands
```bash
# Check flow status
sf data query --query "SELECT Id, Label, ProcessType, Status FROM Flow WHERE Label = 'YourFlowName'"

# View flow details
sf data query --query "SELECT Id, Label, ProcessType, Status, Description FROM Flow"

# Check deployment status
sf project deploy report --job-id <job-id>
```

## 🚀 Advanced Techniques

### 1. Bulk Flow Deployment
```bash
# Deploy multiple flows
sf project deploy start --metadata Flow:Flow1 Flow:Flow2 Flow:Flow3 --target-org your-org

# Deploy flows with wildcards
sf project deploy start --metadata "Flow:Demo*" --target-org your-org
```

### 2. Flow Templates
Create reusable flow templates:
```bash
# Create template from existing flow
sf project retrieve start --metadata Flow:TemplateFlow --target-org your-org

# Modify template and deploy
node scripts/create-demo-flow.js create-from-template --template TemplateFlow --name NewFlow
```

### 3. Flow Testing
```bash
# Deploy with test execution
sf project deploy start --metadata Flow:YourFlow --target-org your-org --test-level RunLocalTests

# Run specific tests
sf project deploy start --metadata Flow:YourFlow --target-org your-org --test-level RunSpecifiedTests --tests TestClass1 TestClass2
```

## 📊 Flow Analytics

### Monitor Flow Performance
```bash
# Query flow interview data
sf data query --query "SELECT Id, FlowId, FlowLabel, Status, StartTime, EndTime FROM FlowInterview WHERE FlowLabel = 'YourFlowName'"

# Check flow errors
sf data query --query "SELECT Id, FlowId, FlowLabel, ErrorMessage FROM FlowInterview WHERE Status = 'Failed'"
```

## 🎯 Best Practices

### 1. Naming Conventions
- Use descriptive names: `Lead_Assignment_Flow`
- Include environment: `Demo_Lead_Assignment_Flow`
- Version if needed: `Lead_Assignment_Flow_v2`

### 2. Organization
- Group related flows in subdirectories
- Use consistent metadata structure
- Document flow purposes

### 3. Testing
- Test flows in sandbox first
- Use realistic test data
- Verify all paths and conditions

### 4. Performance
- Keep flows simple and efficient
- Avoid nested loops
- Use bulk operations when possible

## 🔗 Integration with Your Demo Setup

### Complete Demo Environment
```bash
# Full demo setup with flows
npm run demo:setup

# This runs:
# 1. Create demo flows
# 2. Deploy flows to org
# 3. Generate and import lead data
# 4. Set up Einstein lead scoring
```

### Custom Demo Scenarios
```bash
# Healthcare demo
npm run flow:create && node scripts/create-demo-flow.js create-healthcare-flows

# Financial services demo
npm run flow:create && node scripts/create-demo-flow.js create-finance-flows

# Retail demo
npm run flow:create && node scripts/create-demo-flow.js create-retail-flows
```

## 📞 Support

For issues with:
- **Flow creation**: Check the script syntax and metadata structure
- **Flow deployment**: Verify org permissions and API version
- **Flow execution**: Review trigger conditions and field references
- **Integration**: Ensure proper data setup and Einstein configuration

Your flows are now ready to enhance your Salesforce demos with powerful automation! 🎉















