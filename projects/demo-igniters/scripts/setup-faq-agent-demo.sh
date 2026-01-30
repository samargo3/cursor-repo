#!/bin/bash
# Setup script for Employee FAQ Agent Demo
# This script helps you prepare your Salesforce org for an effective Agentforce demo

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
ORG_ALIAS="${1:-agentforce-demo}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Employee FAQ Agent Demo Setup                          ║${NC}"
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo ""

# Function to print section headers
print_section() {
    echo ""
    echo -e "${GREEN}▶ $1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if Salesforce CLI is installed
print_section "Checking Prerequisites"
if ! command -v sf &> /dev/null; then
    print_error "Salesforce CLI not found. Please install it first:"
    echo "  npm install -g @salesforce/cli"
    exit 1
fi
print_success "Salesforce CLI found"

# Check if org is authenticated
if ! sf org display --target-org "$ORG_ALIAS" &> /dev/null; then
    print_error "Org '$ORG_ALIAS' not found or not authenticated"
    echo ""
    echo "Please authenticate first:"
    echo "  sf org login web --alias $ORG_ALIAS"
    exit 1
fi
print_success "Org '$ORG_ALIAS' is authenticated"

# Check if Agentforce is enabled
print_section "Checking Agentforce Setup"
AGENT_CHECK=$(sf data query --query "SELECT Id FROM AgentWork LIMIT 1" --target-org "$ORG_ALIAS" 2>&1 || echo "FAILED")
if [[ "$AGENT_CHECK" == *"FAILED"* ]] || [[ "$AGENT_CHECK" == *"sObject type 'AgentWork'"* ]]; then
    print_warning "Agentforce may not be enabled in this org"
    echo "  Please ensure Agentforce is provisioned"
    echo "  Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_success "Agentforce appears to be enabled"
fi

# Create Knowledge Articles
print_section "Setting Up Knowledge Base"
echo "Creating sample knowledge articles for FAQ agent..."

# Check if Knowledge is enabled
KNOWLEDGE_CHECK=$(sf data query --query "SELECT Id FROM Knowledge__kav LIMIT 1" --target-org "$ORG_ALIAS" 2>&1 || echo "FAILED")
if [[ "$KNOWLEDGE_CHECK" == *"FAILED"* ]]; then
    print_warning "Salesforce Knowledge may not be enabled"
    echo "  Enable Knowledge in Setup → Feature Settings → Knowledge"
    echo ""
    echo "Skip knowledge article creation? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_success "Salesforce Knowledge is enabled"
    
    # Note: Actual article creation would require Apex or manual setup
    echo "  📝 Create knowledge articles manually using:"
    echo "     templates/employee-faq-knowledge-articles.md"
    echo ""
    echo "  Minimum recommended: 15 articles across"
    echo "    - HR & Benefits (5)"
    echo "    - IT Support (5)"
    echo "    - Expense & Finance (3)"
    echo "    - Facilities (2)"
fi

# Create sample cases
print_section "Creating Sample Cases"
echo "Generating sample employee inquiry cases..."

# Create a few sample cases
sf data create record --sobject Case --values \
    "Subject='How do I request time off?' \
     Status='New' \
     Origin='Web' \
     Type='Question' \
     Priority='Low' \
     Description='I need to request vacation days next month. What is the process?'" \
    --target-org "$ORG_ALIAS" &> /dev/null && print_success "Created PTO inquiry case" || print_warning "Could not create case"

sf data create record --sobject Case --values \
    "Subject='Password reset help' \
     Status='New' \
     Origin='Web' \
     Type='Problem' \
     Priority='Medium' \
     Description='I cannot log into VPN from home. How do I reset my password?'" \
    --target-org "$ORG_ALIAS" &> /dev/null && print_success "Created password reset case" || print_warning "Could not create case"

sf data create record --sobject Case --values \
    "Subject='Expense report question' \
     Status='New' \
     Origin='Email' \
     Type='Question' \
     Priority='Low' \
     Description='How do I submit my expense report from last weeks business trip?'" \
    --target-org "$ORG_ALIAS" &> /dev/null && print_success "Created expense inquiry case" || print_warning "Could not create case"

# Check current demo data
print_section "Checking Demo Data"

CASE_COUNT=$(sf data query --query "SELECT COUNT() FROM Case" --target-org "$ORG_ALIAS" --json | grep -o '"value":[0-9]*' | grep -o '[0-9]*' || echo "0")
print_success "Found $CASE_COUNT cases in org"

ACCOUNT_COUNT=$(sf data query --query "SELECT COUNT() FROM Account" --target-org "$ORG_ALIAS" --json | grep -o '"value":[0-9]*' | grep -o '[0-9]*' || echo "0")
print_success "Found $ACCOUNT_COUNT accounts in org"

# Setup permissions
print_section "Configuring Permissions"

# Get current user
CURRENT_USER=$(sf org display --target-org "$ORG_ALIAS" --json | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
print_success "Current user: $CURRENT_USER"

# Note: You would typically assign permission sets here
echo "  Ensure these permissions for demo user:"
echo "    - Service Cloud User"
echo "    - Knowledge User"
echo "    - Agentforce User"
echo "    - Case Management"
echo ""

# Deploy any custom components if they exist
print_section "Deploying Custom Components"

if [ -d "$PROJECT_ROOT/force-app/main/default/classes" ]; then
    echo "Found Apex classes to deploy..."
    # Uncomment to actually deploy
    # sf project deploy start --source-dir "$PROJECT_ROOT/force-app/main/default/classes" \
    #     --target-org "$ORG_ALIAS" --wait 10
    print_warning "Skipping deployment (uncomment in script to enable)"
else
    print_warning "No custom Apex classes found"
fi

# Summary and next steps
print_section "Setup Complete! 🎉"
echo ""
echo "Your org is ready for demo. Next steps:"
echo ""
echo "1. Configure Agent in Setup:"
echo "   Setup → Agentforce → Agents → New"
echo "   - Name: Employee FAQ Assistant"
echo "   - Type: Service Agent"
echo "   - Topics: Use specs/employeeFaqAgentSpec.yaml"
echo ""
echo "2. Create Knowledge Articles:"
echo "   - Use templates/employee-faq-knowledge-articles.md"
echo "   - Minimum 15 articles recommended"
echo ""
echo "3. Test Agent:"
echo "   - Try demo scenarios from EMPLOYEE_FAQ_AGENT_DEMO_GUIDE.md"
echo "   - Verify responses are accurate"
echo ""
echo "4. Review Demo Checklist:"
echo "   - EMPLOYEE_FAQ_DEMO_CHECKLIST.md"
echo ""
echo "5. Open your org:"
echo -e "   ${BLUE}sf org open --target-org $ORG_ALIAS${NC}"
echo ""
echo "Demo Resources:"
echo "  📖 Full Guide: EMPLOYEE_FAQ_AGENT_DEMO_GUIDE.md"
echo "  ✅ Quick Checklist: EMPLOYEE_FAQ_DEMO_CHECKLIST.md"
echo "  📝 Agent Spec: specs/employeeFaqAgentSpec.yaml"
echo "  📚 Knowledge Templates: templates/employee-faq-knowledge-articles.md"
echo ""
print_success "Ready to deliver an amazing demo!"
echo ""







