#!/bin/bash

# Setup script for MSA Analysis Agent Demo
# This script helps you quickly set up a demo environment for the Contract Analysis Agent

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions for pretty printing
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Check if org alias is provided
if [ -z "$1" ]; then
    print_error "Please provide an org alias"
    echo "Usage: ./scripts/setup-msa-agent.sh <org-alias>"
    echo "Example: ./scripts/setup-msa-agent.sh demo-org"
    exit 1
fi

ORG_ALIAS=$1

print_header "MSA Analysis Agent Setup"
echo "Target Org: $ORG_ALIAS"
echo ""

# Verify org connection
print_step "Verifying org connection..."
if sf org display --target-org "$ORG_ALIAS" > /dev/null 2>&1; then
    print_success "Connected to org: $ORG_ALIAS"
else
    print_error "Cannot connect to org: $ORG_ALIAS"
    echo "Please authenticate first: sf org login web --alias $ORG_ALIAS"
    exit 1
fi

# Deploy Apex classes
print_step "Deploying Contract Analysis Agent Apex classes..."
sf project deploy start \
    --source-dir force-app/main/default/classes/ContractAnalysisAgent.cls \
    --target-org "$ORG_ALIAS" \
    --wait 10

if [ $? -eq 0 ]; then
    print_success "Apex classes deployed successfully"
else
    print_warning "Apex deployment had issues (may need manual verification)"
fi

# Run tests
print_step "Running Apex tests..."
sf apex run test \
    --class-names ContractAnalysisAgentTest \
    --result-format human \
    --target-org "$ORG_ALIAS" \
    --wait 10

if [ $? -eq 0 ]; then
    print_success "Tests passed"
else
    print_warning "Some tests may have failed (check details above)"
fi

# Create sample Accounts
print_step "Creating sample Accounts..."

ACCOUNTS=(
    "TechCorp International"
    "DataFlow Systems"
    "CloudVision Inc"
    "AnalyticsPro Ltd"
    "Enterprise Data Co"
)

for account_name in "${ACCOUNTS[@]}"; do
    sf data create record \
        --sobject Account \
        --values "Name='$account_name'" \
        --target-org "$ORG_ALIAS" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Created: $account_name"
    else
        print_warning "Account may already exist: $account_name"
    fi
done

# Create sample Opportunities
print_step "Creating sample Opportunities..."

# Get Account IDs
TECHCORP_ID=$(sf data query --query "SELECT Id FROM Account WHERE Name='TechCorp International' LIMIT 1" --target-org "$ORG_ALIAS" --json | grep -o '"Id":"[^"]*"' | head -1 | cut -d'"' -f4)
DATAFLOW_ID=$(sf data query --query "SELECT Id FROM Account WHERE Name='DataFlow Systems' LIMIT 1" --target-org "$ORG_ALIAS" --json | grep -o '"Id":"[^"]*"' | head -1 | cut -d'"' -f4)
CLOUDVISION_ID=$(sf data query --query "SELECT Id FROM Account WHERE Name='CloudVision Inc' LIMIT 1" --target-org "$ORG_ALIAS" --json | grep -o '"Id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -n "$TECHCORP_ID" ]; then
    sf data create record \
        --sobject Opportunity \
        --values "Name='TechCorp MSA Deal' AccountId='$TECHCORP_ID' StageName='Negotiation/Review' CloseDate='2025-12-31' Amount=450000" \
        --target-org "$ORG_ALIAS" > /dev/null 2>&1
    print_success "Created Opportunity: TechCorp MSA Deal"
fi

if [ -n "$DATAFLOW_ID" ]; then
    sf data create record \
        --sobject Opportunity \
        --values "Name='DataFlow Enterprise License' AccountId='$DATAFLOW_ID' StageName='Proposal/Price Quote' CloseDate='2025-11-30' Amount=300000" \
        --target-org "$ORG_ALIAS" > /dev/null 2>&1
    print_success "Created Opportunity: DataFlow Enterprise License"
fi

if [ -n "$CLOUDVISION_ID" ]; then
    sf data create record \
        --sobject Opportunity \
        --values "Name='CloudVision Platform Deal' AccountId='$CLOUDVISION_ID' StageName='Negotiation/Review' CloseDate='2025-12-15' Amount=250000" \
        --target-org "$ORG_ALIAS" > /dev/null 2>&1
    print_success "Created Opportunity: CloudVision Platform Deal"
fi

# Summary
print_header "Setup Complete!"

echo "Next Steps:"
echo ""
echo "1. Create Contract PDFs:"
echo "   - Use templates from: templates/starburst-contract-samples.md"
echo "   - Create PDFs for TechCorp, DataFlow, CloudVision, etc."
echo ""
echo "2. Upload PDFs to Opportunities:"
echo "   - Navigate to each Opportunity in Salesforce"
echo "   - Go to Files tab → Upload Files"
echo "   - Attach the corresponding MSA PDF"
echo ""
echo "3. Configure Data Cloud 360 (if using RAG):"
echo "   - Setup → Data Cloud → Data Sources"
echo "   - Create data source for Salesforce Files"
echo "   - Enable RAG indexing for PDF content"
echo ""
echo "4. Create Agentforce Agent:"
echo "   - Setup → Agentforce → Agents → New"
echo "   - Use configuration from: MSA_ANALYSIS_AGENT_GUIDE.md"
echo "   - Add 5 topics: Term Inquiry, Summarization, Verification, Trends, Templates"
echo ""
echo "5. Test the Agent:"
echo "   - Open an Opportunity with uploaded contract"
echo "   - Use embedded agent chat"
echo "   - Try: 'What are the payment terms for this contract?'"
echo ""
echo "Documentation:"
echo "  📖 Full Guide: MSA_ANALYSIS_AGENT_GUIDE.md"
echo "  📝 Agent Spec: specs/starburstDealDeskAgentSpec.yaml"
echo "  📚 Contract Samples: templates/starburst-contract-samples.md"
echo "  ✅ Checklist: STARBURST_DEMO_CHECKLIST.md"
echo ""
echo "Open your org:"
echo -e "  ${BLUE}sf org open --target-org $ORG_ALIAS${NC}"
echo ""

print_success "Setup script completed!"
echo ""

