# SOQL Query Files

This directory contains SOQL query files that can be executed directly from the command line or through Node.js scripts.

## 📁 Available SOQL Files

### Basic Queries
- `leads-count.soql` - Count total leads
- `leads-sample.soql` - Sample of 10 leads with key fields
- `leads-by-status.soql` - Leads grouped by status
- `qualified-leads.soql` - Qualified leads only

### Specialized Queries
- `high-revenue-leads.soql` - Leads with revenue > $50M
- `tech-leads.soql` - Technology industry leads

## 🚀 How to Run

### Method 1: Direct CLI
```bash
# Run a SOQL file directly
sf data query --query "$(cat scripts/soql/leads-count.soql)"
```

### Method 2: Node.js Runner (Recommended)
```bash
# Run and display results
node scripts/run-soql.js leads-count

# Run and save to file
node scripts/run-soql-advanced.js leads-sample results.json
node scripts/run-soql-advanced.js qualified-leads qualified.csv
```

### Method 3: NPM Scripts
```bash
# Quick access via npm
npm run soql:count-file
npm run soql:sample-file
npm run soql:status-file
npm run soql:qualified-file
```

## 📊 Output Formats

The advanced runner supports multiple output formats:

- **JSON**: `results.json` - Structured data for processing
- **CSV**: `results.csv` - Spreadsheet-friendly format
- **Default**: Terminal display with table formatting

## 🔧 Creating New SOQL Files

1. Create a new `.soql` file in this directory
2. Write your SOQL query
3. Run with: `node scripts/run-soql.js your-file-name`

### Example:
```sql
-- scripts/soql/my-custom-query.soql
SELECT Id, Name, Industry 
FROM Lead 
WHERE Status = 'New' 
LIMIT 50
```

Then run:
```bash
node scripts/run-soql.js my-custom-query
```

## 💡 Tips

- Use `LIMIT` clauses to avoid large result sets
- Include `Id` field for record identification
- Use `ORDER BY` for consistent results
- Test queries in Salesforce Developer Console first

