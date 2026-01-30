#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class DemoFlowGenerator {
    constructor() {
        this.flowsDir = 'force-app/main/default/flows';
        this.ensureFlowsDirectory();
    }

    ensureFlowsDirectory() {
        if (!fs.existsSync(this.flowsDir)) {
            fs.mkdirSync(this.flowsDir, { recursive: true });
        }
    }

    generateLeadAssignmentFlow() {
        const flowName = 'Demo_Lead_Assignment_Flow';
        const flowMeta = `<?xml version="1.0" encoding="UTF-8"?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <description>Demo flow for automatic lead assignment based on industry</description>
    <environments>Default</environments>
    <interviewLabel>Demo Lead Assignment Flow {!$Flow.CurrentDateTime}</interviewLabel>
    <label>Demo Lead Assignment Flow</label>
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
        <connector>
            <targetReference>Lead_Assignment_Decision</targetReference>
        </connector>
    </start>
    <variables>
        <name>LeadOwner</name>
        <dataType>String</dataType>
        <isCollection>false</isCollection>
        <isInput>false</isInput>
        <isOutput>false</isOutput>
    </variables>
</Flow>`;

        const flowDefinition = {
            "flow": {
                "apiVersion": "64.0",
                "description": "Demo flow for automatic lead assignment based on industry",
                "environments": "Default",
                "interviewLabel": "Demo Lead Assignment Flow {!$Flow.CurrentDateTime}",
                "label": "Demo Lead Assignment Flow",
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
                    "locationY": 0,
                    "connector": {
                        "targetReference": "Lead_Assignment_Decision"
                    }
                },
                "variables": [
                    {
                        "name": "LeadOwner",
                        "dataType": "String",
                        "isCollection": false,
                        "isInput": false,
                        "isOutput": false
                    }
                ],
                "decisions": [
                    {
                        "name": "Lead_Assignment_Decision",
                        "label": "Lead Assignment Decision",
                        "locationX": 176,
                        "locationY": 0,
                        "defaultConnector": {
                            "targetReference": "Assign_To_Sales_Team"
                        },
                        "defaultConnectorLabel": "Default",
                        "rules": [
                            {
                                "name": "Technology_Leads",
                                "conditionLogic": "and",
                                "conditions": [
                                    {
                                        "leftValueReference": "{!$Record.Industry}",
                                        "operator": "EqualTo",
                                        "rightValue": {
                                            "stringValue": "Technology"
                                        }
                                    }
                                ],
                                "connector": {
                                    "targetReference": "Assign_To_Tech_Team"
                                },
                                "label": "Technology Leads"
                            }
                        ]
                    }
                ],
                "assignments": [
                    {
                        "name": "Assign_To_Tech_Team",
                        "label": "Assign to Tech Team",
                        "locationX": 302,
                        "locationY": -50,
                        "assignmentItems": [
                            {
                                "assignToReference": "{!$Record.Id}",
                                "field": "OwnerId",
                                "operator": "Assign"
                            }
                        ],
                        "connector": {
                            "targetReference": "Success_Message"
                        }
                    },
                    {
                        "name": "Assign_To_Sales_Team",
                        "label": "Assign to Sales Team",
                        "locationX": 302,
                        "locationY": 50,
                        "assignmentItems": [
                            {
                                "assignToReference": "{!$Record.Id}",
                                "field": "OwnerId",
                                "operator": "Assign"
                            }
                        ],
                        "connector": {
                            "targetReference": "Success_Message"
                        }
                    }
                ],
                "actionCalls": [
                    {
                        "name": "Success_Message",
                        "label": "Success Message",
                        "locationX": 428,
                        "locationY": 0,
                        "inputParameters": [
                            {
                                "name": "message",
                                "value": {
                                    "stringValue": "Lead assigned successfully!"
                                }
                            }
                        ],
                        "storeOutputAutomatically": true
                    }
                ]
            }
        };

        this.saveFlow(flowName, flowMeta, flowDefinition);
        return flowName;
    }

    generateNotificationFlow() {
        const flowName = 'Demo_Notification_Flow';
        const flowMeta = `<?xml version="1.0" encoding="UTF-8"?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <description>Demo flow for sending notifications on high-value leads</description>
    <environments>Default</environments>
    <interviewLabel>Demo Notification Flow {!$Flow.CurrentDateTime}</interviewLabel>
    <label>Demo Notification Flow</label>
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
        <connector>
            <targetReference>Check_Lead_Value</targetReference>
        </connector>
    </start>
</Flow>`;

        const flowDefinition = {
            "flow": {
                "apiVersion": "64.0",
                "description": "Demo flow for sending notifications on high-value leads",
                "environments": "Default",
                "interviewLabel": "Demo Notification Flow {!$Flow.CurrentDateTime}",
                "label": "Demo Notification Flow",
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
                    "locationY": 0,
                    "connector": {
                        "targetReference": "Check_Lead_Value"
                    }
                },
                "decisions": [
                    {
                        "name": "Check_Lead_Value",
                        "label": "Check Lead Value",
                        "locationX": 176,
                        "locationY": 0,
                        "defaultConnector": {
                            "targetReference": "End"
                        },
                        "defaultConnectorLabel": "Low Value",
                        "rules": [
                            {
                                "name": "High_Value_Lead",
                                "conditionLogic": "and",
                                "conditions": [
                                    {
                                        "leftValueReference": "{!$Record.AnnualRevenue}",
                                        "operator": "GreaterThan",
                                        "rightValue": {
                                            "numberValue": 1000000
                                        }
                                    }
                                ],
                                "connector": {
                                    "targetReference": "Send_Notification"
                                },
                                "label": "High Value Lead"
                            }
                        ]
                    }
                ],
                "actionCalls": [
                    {
                        "name": "Send_Notification",
                        "label": "Send Notification",
                        "locationX": 302,
                        "locationY": 0,
                        "inputParameters": [
                            {
                                "name": "title",
                                "value": {
                                    "stringValue": "High Value Lead Alert"
                                }
                            },
                            {
                                "name": "body",
                                "value": {
                                    "stringValue": "New high-value lead: {!$Record.Company}"
                                }
                            }
                        ],
                        "storeOutputAutomatically": true,
                        "connector": {
                            "targetReference": "End"
                        }
                    }
                ]
            }
        };

        this.saveFlow(flowName, flowMeta, flowDefinition);
        return flowName;
    }

    saveFlow(flowName, flowMeta, flowDefinition) {
        const flowDir = path.join(this.flowsDir, flowName);
        if (!fs.existsSync(flowDir)) {
            fs.mkdirSync(flowDir, { recursive: true });
        }

        fs.writeFileSync(path.join(flowDir, `${flowName}.flow-meta.xml`), flowMeta);
        fs.writeFileSync(path.join(flowDir, `${flowName}.flow`), JSON.stringify(flowDefinition, null, 2));
        
        console.log(`✅ Created flow: ${flowName}`);
    }

    deployFlow(flowName, targetOrg = 'sargo@demo.com') {
        try {
            console.log(`🚀 Deploying flow: ${flowName}`);
            const command = `sf project deploy start --metadata Flow:${flowName} --target-org ${targetOrg} --concise`;
            const result = execSync(command, { encoding: 'utf8' });
            console.log(`✅ Successfully deployed: ${flowName}`);
            return true;
        } catch (error) {
            console.error(`❌ Failed to deploy ${flowName}:`, error.message);
            return false;
        }
    }

    deployAllFlows(targetOrg = 'sargo@demo.com') {
        try {
            console.log('🚀 Deploying all flows...');
            const command = `sf project deploy start --source-dir ${this.flowsDir} --target-org ${targetOrg} --concise`;
            const result = execSync(command, { encoding: 'utf8' });
            console.log('✅ Successfully deployed all flows');
            return true;
        } catch (error) {
            console.error('❌ Failed to deploy flows:', error.message);
            return false;
        }
    }

    listFlows() {
        if (!fs.existsSync(this.flowsDir)) {
            console.log('No flows directory found');
            return [];
        }

        const flows = fs.readdirSync(this.flowsDir, { withFileTypes: true })
            .filter(dirent => dirent.isDirectory())
            .map(dirent => dirent.name);

        console.log('📋 Available flows:');
        flows.forEach(flow => console.log(`  - ${flow}`));
        return flows;
    }
}

// CLI Interface
const args = process.argv.slice(2);
const generator = new DemoFlowGenerator();

if (args.length === 0) {
    console.log(`
🎯 Demo Flow Generator

Usage:
  node create-demo-flow.js <command> [options]

Commands:
  create-lead-assignment    Create lead assignment flow
  create-notification       Create notification flow
  create-all               Create all demo flows
  deploy <flowName>        Deploy specific flow
  deploy-all               Deploy all flows
  list                     List available flows

Examples:
  node create-demo-flow.js create-all
  node create-demo-flow.js deploy Demo_Lead_Assignment_Flow
  node create-demo-flow.js deploy-all
  node create-demo-flow.js list
`);
    process.exit(0);
}

const command = args[0];

switch (command) {
    case 'create-lead-assignment':
        generator.generateLeadAssignmentFlow();
        break;
    case 'create-notification':
        generator.generateNotificationFlow();
        break;
    case 'create-all':
        generator.generateLeadAssignmentFlow();
        generator.generateNotificationFlow();
        break;
    case 'deploy':
        if (args[1]) {
            generator.deployFlow(args[1], args[2]);
        } else {
            console.log('❌ Please specify a flow name to deploy');
        }
        break;
    case 'deploy-all':
        generator.deployAllFlows(args[1]);
        break;
    case 'list':
        generator.listFlows();
        break;
    default:
        console.log(`❌ Unknown command: ${command}`);
        process.exit(1);
}















