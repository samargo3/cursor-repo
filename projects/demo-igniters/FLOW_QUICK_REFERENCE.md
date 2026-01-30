# ⚡ Flow Deployment Quick Reference

## 🚀 One-Command Setup
```bash
npm run demo:setup
```
*Creates flows, deploys them, and sets up Einstein data*

## 📋 Flow Management
```bash
# Create demo flows
npm run flow:create

# Deploy all flows
npm run flow:deploy

# List available flows
npm run flow:list

# Create specific flows
npm run flow:create-lead
npm run flow:create-notification
```

## 🔧 Direct CLI Commands
```bash
# Deploy single flow
sf project deploy start --metadata Flow:FlowName --target-org your-org

# Deploy all flows
sf project deploy start --source-dir force-app/main/default/flows --target-org your-org

# Deploy with options
sf project deploy start --metadata Flow:FlowName --target-org your-org --verbose --ignore-warnings
```

## 📁 Flow Structure
```
force-app/main/default/flows/
├── FlowName/
│   ├── FlowName.flow-meta.xml    # Metadata
│   └── FlowName.flow             # Definition (JSON)
```

## 🎯 Demo Flows Created
- **Demo_Lead_Assignment_Flow**: Auto-assign leads by industry
- **Demo_Notification_Flow**: Notify on high-value leads

## 🔍 Troubleshooting
```bash
# Check flow status
sf data query --query "SELECT Id, Label, Status FROM Flow WHERE Label LIKE 'Demo%'"

# View deployment status
sf project deploy report --job-id <job-id>
```

## ⚡ Pro Tips
- Use `--concise` for clean output
- Use `--ignore-warnings` for demo environments
- Test in sandbox first
- Use descriptive flow names















