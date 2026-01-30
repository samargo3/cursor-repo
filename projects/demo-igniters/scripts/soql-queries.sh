#!/bin/bash

# Quick SOQL Queries for Salesforce Demo Org
# Usage: ./scripts/soql-queries.sh [query_name]

echo "🚀 Salesforce SOQL Query Runner"
echo "================================"

case "$1" in
    "leads-count")
        echo "📊 Total Leads Count:"
        sf data query --query "SELECT COUNT() FROM Lead"
        ;;
    "leads-sample")
        echo "📋 Sample Leads (10 records):"
        sf data query --query "SELECT Id, FirstName, LastName, Company, Email, Status FROM Lead LIMIT 10"
        ;;
    "leads-by-status")
        echo "📈 Leads by Status:"
        sf data query --query "SELECT Status, COUNT(Id) FROM Lead GROUP BY Status ORDER BY COUNT(Id) DESC"
        ;;
    "leads-by-industry")
        echo "🏭 Leads by Industry:"
        sf data query --query "SELECT Industry, COUNT(Id) FROM Lead WHERE Industry != null GROUP BY Industry ORDER BY COUNT(Id) DESC LIMIT 10"
        ;;
    "leads-by-source")
        echo "📱 Leads by Source:"
        sf data query --query "SELECT LeadSource, COUNT(Id) FROM Lead WHERE LeadSource != null GROUP BY LeadSource ORDER BY COUNT(Id) DESC LIMIT 10"
        ;;
    "recent-leads")
        echo "🆕 Recent Leads (last 5):"
        sf data query --query "SELECT Id, FirstName, LastName, Company, CreatedDate FROM Lead ORDER BY CreatedDate DESC LIMIT 5"
        ;;
    "qualified-leads")
        echo "✅ Qualified Leads:"
        sf data query --query "SELECT Id, FirstName, LastName, Company, Email FROM Lead WHERE Status IN ('Qualified', 'Sales Qualified Lead', 'Marketing Qualified Lead') LIMIT 10"
        ;;
    "high-revenue")
        echo "💰 High Revenue Leads (>$50M):"
        sf data query --query "SELECT Id, FirstName, LastName, Company, AnnualRevenue FROM Lead WHERE AnnualRevenue > 50000 ORDER BY AnnualRevenue DESC LIMIT 10"
        ;;
    "tech-leads")
        echo "💻 Technology Industry Leads:"
        sf data query --query "SELECT Id, FirstName, LastName, Company, Title FROM Lead WHERE Industry = 'Technology' LIMIT 10"
        ;;
    "custom")
        if [ -n "$2" ]; then
            echo "🔍 Custom Query: $2"
            sf data query --query "$2"
        else
            echo "❌ Please provide a SOQL query as the second argument"
            echo "Example: ./scripts/soql-queries.sh custom 'SELECT Id, Name FROM Account LIMIT 5'"
        fi
        ;;
    *)
        echo "Available queries:"
        echo "  leads-count      - Total number of leads"
        echo "  leads-sample     - Sample of 10 leads"
        echo "  leads-by-status  - Leads grouped by status"
        echo "  leads-by-industry - Leads grouped by industry"
        echo "  leads-by-source  - Leads grouped by source"
        echo "  recent-leads     - Most recent leads"
        echo "  qualified-leads  - Qualified leads only"
        echo "  high-revenue     - High revenue leads"
        echo "  tech-leads       - Technology industry leads"
        echo "  custom <query>   - Run custom SOQL query"
        echo ""
        echo "Examples:"
        echo "  ./scripts/soql-queries.sh leads-count"
        echo "  ./scripts/soql-queries.sh custom 'SELECT Id, Name FROM Account LIMIT 5'"
        ;;
esac

