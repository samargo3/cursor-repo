# Demo Igniters - Salesforce Demo Repository

> A comprehensive collection of Salesforce demo components, agents, flows, and integrations for showcasing enterprise capabilities.

[![Salesforce](https://img.shields.io/badge/Salesforce-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)](https://www.salesforce.com)
[![Lightning](https://img.shields.io/badge/Lightning-0176D3?style=for-the-badge&logo=salesforce&logoColor=white)](https://developer.salesforce.com/docs/component-library/overview/components)
[![Apex](https://img.shields.io/badge/Apex-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/samargo3/demo-igniters.git
cd demo-igniters

# Install dependencies
npm install

# Authenticate to your Salesforce org
sf org login web --alias my-demo-org

# Deploy metadata
sf project deploy start --target-org my-demo-org
```

---

## 📦 What's Included

### **🎯 Latest Feature: Proforma Resource Forecasting** ⭐ NEW

Complete resource planning and profitability analysis tool for opportunities.

- **Custom Objects**: Resource_Forecast__c with Master-Detail to Opportunity
- **LWC Component**: Professional inline-editable grid for resource management
- **Validation**: Stage gate preventing Closed Won without resource forecasting
- **Auto-Calculation**: Real-time profitability and margin calculations
- **Test Coverage**: 98.7% (exceeds 75% requirement)

📚 **Documentation**:
- [Complete Guide](PROFORMA_RESOURCE_FORECASTING_GUIDE.md)
- [Quick Reference](PROFORMA_QUICK_REFERENCE.md)
- [Architecture](PROFORMA_ARCHITECTURE.md)
- [Deployment Summary](PROFORMA_DEPLOYMENT_SUMMARY.md)
- [UI Improvements](PROFORMA_UI_IMPROVEMENTS.md)

---

### **🤖 Agentforce Demos**

#### Deal Desk Agent
AI-powered deal desk automation for contract analysis and approvals.
- [README](DEAL_DESK_AGENT_README.md)
- [Quick Reference](DEAL_DESK_AGENT_QUICK_REFERENCE.md)
- [Deployment Plan](DEAL_DESK_AGENT_DEPLOYMENT_PLAN.md)
- [Checklist](DEAL_DESK_AGENT_CHECKLIST.md)

#### Employee FAQ Agent
Conversational AI for employee questions and knowledge base.
- [Demo Guide](EMPLOYEE_FAQ_AGENT_DEMO_GUIDE.md)
- [Checklist](EMPLOYEE_FAQ_DEMO_CHECKLIST.md)
- [Agentforce FAQ](AGENTFORCE_FAQ_DEMO_README.md)

#### MSA Analysis Agent
Master Service Agreement analysis and insights.
- [Architecture](MSA_AGENT_ARCHITECTURE.md)
- [Quick Start](MSA_AGENT_QUICK_START.md)
- [Analysis Guide](MSA_ANALYSIS_AGENT_GUIDE.md)

#### Account & Contract Agents
- [Contract Analysis Guide](ACCOUNT_CONTRACT_ANALYSIS_GUIDE.md)
- [Contract Analysis Tutorial](ACCOUNT_CONTRACT_ANALYSIS_TUTORIAL.md)
- [Comparison Guide](ACCOUNT_CONTRACT_COMPARISON_GUIDE.md)
- [Account Files](ACCOUNT_FILES_README.md)

**Framework Documentation**:
- [Agent Framework Development](AGENT_FRAMEWORK_DEVELOPMENT_GUIDE.md)
- [Agent Apex Guide](AGENT_APEX_GUIDE.md)

---

### **💡 Einstein Features**

#### Einstein Lead Scoring
Predictive lead scoring with high-quality demo data.
- [Setup Guide](EINSTEIN_LEAD_SCORING_GUIDE.md)
- [Custom Leads Guide](CUSTOM_LEADS_GUIDE.md)

---

### **🔄 Flow Automation**

Declarative automation for common demo scenarios.
- [Deployment Guide](FLOW_DEPLOYMENT_GUIDE.md)
- [Quick Reference](FLOW_QUICK_REFERENCE.md)
- [Build Checklist](ACCOUNT_FLOW_BUILD_CHECKLIST.md)
- [Comparison](CONTRACT_FLOW_COMPARISON.md)

---

### **📊 Opportunity Management**

#### Opportunity Files & Insights
- [README](OPPORTUNITY_FILES_README.md)
- [Summary](OPPORTUNITY_FILES_SUMMARY.md)
- [Deployment](OPPORTUNITY_FILES_DEPLOYMENT.md)
- [Quick Reference](OPPORTUNITY_FILES_QUICK_REFERENCE.md)
- [Retriever Guide](OPPORTUNITY_FILES_RETRIEVER_GUIDE.md)
- [Optimization](OPPORTUNITY_OPTIMIZATION_SUMMARY.md)

---

### **📈 Reports & Analytics**

Custom reports and dashboards for demo scenarios.
- [Reports Guide](REPORTS_GUIDE.md)
- [Deployment Summary](REPORTS_DEPLOYMENT_SUMMARY.md)

---

### **🎨 Lightning Web Components**

#### Recommended Next Product
Account page component for product recommendations.
- [Documentation](RECOMMENDED_NEXT_PRODUCT.md)

#### Proforma Manager
Resource forecasting and profitability calculator.
- See Proforma documentation above

#### Jira Integration Button
External system integration demo component.
- [Guide](JIRA_ISSUE_BUTTON_GUIDE.md)

---

### **🔧 Integrations & Tooling**

#### MCP (Model Context Protocol) Servers
Connect AI assistants to Salesforce and GitHub.
- [MCP Setup](MCP_SETUP.md)
- [MCP Walkthrough](MCP_WALKTHROUGH.md)
- Salesforce MCP Server (SOQL, Apex, Metadata Deploy)
- GitHub MCP Server (Issues, PRs, Code Search)

#### GitHub Setup
- [GitHub Setup Guide](GITHUB_SETUP.md)

#### Prompt Builder
AI prompt templates and data providers.
- [Start Here](PROMPT_BUILDER_START_HERE.md)
- [README](PROMPT_BUILDER_README.md)
- [Quick Reference](PROMPT_BUILDER_QUICK_REFERENCE.md)
- [Index](PROMPT_BUILDER_INDEX.md)
- [Architecture](PROMPT_BUILDER_ARCHITECTURE.md)
- [Summary](PROMPT_BUILDER_SUMMARY.md)
- [Data Provider Guide](PROMPT_BUILDER_DATA_PROVIDER_GUIDE.md)

---

### **📝 Demo Scripts & Guides**

#### Client-Specific Demos
- [New Mont Capital Demo Script](../New_Mont_Capital_Demo_Script.md) (788 lines)
- [New Mont Capital Business Case](../New_Mont_Capital_Business_Case_Summary.md)
- [New Mont Capital Cheat Sheet](../New_Mont_Capital_Demo_Day_Cheat_Sheet.md)
- [Starburst Demo Checklist](STARBURST_DEMO_CHECKLIST.md)
- [Starburst README](STARBURST_README.md)
- [Starburst Setup](starburst-demo-setup.md)

#### General Demo Guides
- [Demo Playbook](DEMO_PLAYBOOK.md) - End-to-end demo setup
- [Quick Start Demo Hub](QUICK_START_DEMO_HUB.md)
- [Sales Demo Hub Guide](SALES_DEMO_HUB_GUIDE.md)
- [Product Demo Guide](PRODUCT_DEMO_GUIDE.md)
- [Demo Admin Panel Guide](DEMO_ADMIN_PANEL_GUIDE.md)

#### Use Case Documentation
- [Use Case Checklist](USE_CASE_CHECKLIST.md)
- [Cursor Salesforce Use Cases](CURSOR_SALESFORCE_USE_CASES.md)

---

## 🛠️ Development

### **Prerequisites**
- Node.js 18+
- Salesforce CLI (`sf`)
- Authenticated Salesforce org
- Git

### **Project Structure**

```
demo-igniters/
├── force-app/main/default/       # Salesforce metadata
│   ├── classes/                  # Apex classes
│   ├── triggers/                 # Apex triggers
│   ├── lwc/                      # Lightning Web Components
│   ├── objects/                  # Custom objects & fields
│   ├── flows/                    # Flow definitions
│   └── ...
├── scripts/                      # Node.js scripts
│   ├── import-leads-bulk.js
│   ├── generate-products.js
│   ├── create-demo-flow.js
│   └── ...
├── data/                         # Sample data & CSVs
├── mcp/                          # MCP server implementations
│   └── salesforce-mcp-server.js
├── specs/                        # Agent specifications
└── docs/                         # Additional documentation
```

### **Useful NPM Scripts**

```bash
# Lead generation
npm run leads:quick              # Quick lead generation
npm run leads:tech               # Tech industry leads
npm run leads:healthcare         # Healthcare leads

# Product generation
npm run products:quick           # Quick product generation
npm run products:tech            # Tech products

# Flows
npm run flow:create              # Create demo flows
npm run flow:deploy              # Deploy flows

# SOQL queries
npm run soql:count               # Count leads
npm run soql:qualified           # Get qualified leads

# MCP Server
npm run mcp:start                # Start Salesforce MCP server

# Demo setup
npm run demo:setup               # Complete demo setup
npm run demo:seed                # Seed demo data
```

---

## 📚 Documentation Index

### **By Feature Area**

#### **Agents & AI**
- [Agent Framework Development](AGENT_FRAMEWORK_DEVELOPMENT_GUIDE.md)
- [Agent Apex Guide](AGENT_APEX_GUIDE.md)
- [Deal Desk Agent](DEAL_DESK_AGENT_README.md)
- [Employee FAQ Agent](EMPLOYEE_FAQ_AGENT_DEMO_GUIDE.md)
- [MSA Analysis Agent](MSA_AGENT_ARCHITECTURE.md)

#### **Sales & Revenue**
- [Proforma Resource Forecasting](PROFORMA_RESOURCE_FORECASTING_GUIDE.md)
- [Opportunity Files](OPPORTUNITY_FILES_README.md)
- [Einstein Lead Scoring](EINSTEIN_LEAD_SCORING_GUIDE.md)
- [Recommended Next Product](RECOMMENDED_NEXT_PRODUCT.md)

#### **Automation**
- [Flow Deployment](FLOW_DEPLOYMENT_GUIDE.md)
- [Contract Analysis](ACCOUNT_CONTRACT_ANALYSIS_GUIDE.md)

#### **Integration & Tools**
- [MCP Setup](MCP_SETUP.md)
- [GitHub Setup](GITHUB_SETUP.md)
- [Jira Integration](JIRA_ISSUE_BUTTON_GUIDE.md)

#### **Demo Execution**
- [Demo Playbook](DEMO_PLAYBOOK.md)
- [Quick Start Demo Hub](QUICK_START_DEMO_HUB.md)
- [New Mont Capital Script](../New_Mont_Capital_Demo_Script.md)

---

## 🧪 Testing

### **Run Apex Tests**

```bash
# Run all tests
sf apex run test --test-level RunLocalTests --target-org my-demo-org

# Run specific test class
sf apex run test --tests ProformaManagerControllerTest --target-org my-demo-org

# With code coverage
sf apex run test --test-level RunLocalTests --code-coverage --target-org my-demo-org
```

### **Test Coverage**

| Component | Coverage | Status |
|-----------|----------|--------|
| ProformaManagerController | 96% | ✅ |
| OpportunityResourceValidationHandler | 100% | ✅ |
| OpportunityFileRetriever | 95%+ | ✅ |
| PromptBuilderDataProvider | 95%+ | ✅ |

---

## 🚀 Deployment

### **Deploy to Scratch Org**

```bash
# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias my-scratch

# Deploy metadata
sf project deploy start --target-org my-scratch

# Assign permissions
npm run demo:permissions

# Seed data
npm run demo:seed
```

### **Deploy to Sandbox/Production**

```bash
# Deploy specific metadata
sf project deploy start --metadata CustomObject:Resource_Forecast__c --target-org my-sandbox

# Deploy with tests
sf project deploy start --test-level RunLocalTests --target-org my-sandbox

# Validate deployment (no actual deployment)
sf project deploy start --test-level RunLocalTests --target-org my-prod --dry-run
```

---

## 🎓 Learning Resources

### **Salesforce Documentation**
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Lightning Web Components](https://developer.salesforce.com/docs/component-library/overview/components)
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
- [Agentforce Documentation](https://help.salesforce.com/s/articleView?id=sf.agentforce.htm)

### **Related Resources**
- [Agentforce Tips & Tricks](https://dylandersen.notion.site/agentforce-tips-and-tricks)

---

## 🤝 Contributing

This is a demo repository. For questions or improvements, create an issue or contact the maintainer.

---

## 📞 Support

For technical questions or demo setup assistance:
- Review the documentation guides
- Check the troubleshooting sections in specific guides
- Consult the [Demo Playbook](DEMO_PLAYBOOK.md)

---

## 📅 Recent Updates

### January 15, 2026
- ✅ Added Proforma Resource Forecasting feature
- ✅ Fixed GitHub MCP server configuration
- ✅ Updated Salesforce MCP server to SDK v1.x
- ✅ Comprehensive documentation updates
- ✅ UI improvements and bug fixes

---

## 📄 License

This is a demo repository for Salesforce demonstrations and training purposes.

---

**Built with ❤️ for Salesforce Demos**
