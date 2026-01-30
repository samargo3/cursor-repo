# 🚀 Salesforce DX MCP Walkthrough

The Salesforce DX MCP (Model Context Protocol) is a powerful bridge that connects Cursor with your Salesforce org, allowing you to interact with Salesforce data and metadata directly from your chat interface. Here's your complete walkthrough:

## 🏗️ **What is MCP?**

MCP is a protocol that allows AI assistants (like me) to securely interact with external systems. In your case, it connects Cursor to Salesforce, giving you direct access to:
- **SOQL Queries** - Query your Salesforce data
- **Apex Execution** - Run anonymous Apex code
- **Metadata Deployment** - Deploy your code changes
- **Data Import** - Import CSV data
- **Flow Management** - Manage Salesforce Flows
- **Script Execution** - Run your custom scripts

## 🔧 **Setup Process**

### **Step 1: Prerequisites Check**
```bash
# Check Node version (need 18+)
node --version

# Check Salesforce CLI
sf --version

# Authenticate to your org
sf org login web
```

### **Step 2: Install Dependencies**
```bash
# Install MCP dependencies
npm install
```

### **Step 3: Configure Environment**
```bash
# Set your target org (optional)
export SFDX_DEFAULTUSERNAME=your-scratch-alias

# Enable Apex execution (sandbox only)
export SANDBOX_OK=1
```

### **Step 4: Start MCP Server**
```bash
# Start the MCP server
npm run mcp:start
```

### **Step 5: Configure Cursor**
Add this to your Cursor MCP settings (Settings → MCP):

```json
{
  "mcpServers": {
    "salesforce": {
      "command": "npm",
      "args": ["run", "mcp:start"],
      "env": {
        "SFDX_DEFAULTUSERNAME": "your-scratch-alias"
      }
    }
  }
}
```

## 🛠️ **Available Tools**

### **1. SOQL Query (`soql.query`)**
Query your Salesforce data directly:

**Example Usage:**
```
"Run SOQL to list 10 Leads with Status=Open via salesforce.soql.query"
```

**What it does:**
- Executes SOQL queries
- Returns JSON by default, CSV with `csv=true`
- Read-only operations only
- Respects org permissions

**Example Queries:**
```sql
-- Get recent leads
SELECT Id, Name, Company, Status, CreatedDate FROM Lead ORDER BY CreatedDate DESC LIMIT 10

-- Get opportunities by stage
SELECT Id, Name, StageName, Amount, CloseDate FROM Opportunity WHERE IsClosed = false

-- Get cases needing attention
SELECT Id, CaseNumber, Subject, Priority, Status FROM Case WHERE IsClosed = false AND Priority = 'High'
```

### **2. Apex Execution (`apex.execute`)**
Run anonymous Apex code:

**Example Usage:**
```
"Execute Apex to create test data via salesforce.apex.execute"
```

**What it does:**
- Runs anonymous Apex code
- Only enabled when `SANDBOX_OK=1`
- Perfect for testing and data manipulation
- Great for running your Agent examples

**Example Apex:**
```apex
// Create test leads
List<Lead> leads = new List<Lead>();
for(Integer i = 0; i < 5; i++) {
    leads.add(new Lead(
        FirstName = 'Test',
        LastName = 'Lead ' + i,
        Company = 'Test Company ' + i,
        Email = 'test' + i + '@example.com'
    ));
}
insert leads;
System.debug('Created ' + leads.size() + ' leads');
```

### **3. Metadata Deployment (`metadata.deploy`)**
Deploy your code changes:

**Example Usage:**
```
"Deploy metadata via salesforce.metadata.deploy with testLevel=NoTestRun"
```

**What it does:**
- Deploys from `force-app/` directory
- Supports different test levels
- Uses `sf project deploy start`
- Perfect for deploying your Agent classes

**Test Levels:**
- `NoTestRun` - No tests (fastest)
- `RunLocalTests` - Run local tests only
- `RunAllTestsInOrg` - Run all tests in org

### **4. Data Import (`data.import.csv`)**
Import CSV data using your existing scripts:

**Example Usage:**
```
"Import leads from data/leads.csv using mode bulk via salesforce.data.import.csv"
```

**What it does:**
- Uses your existing import scripts
- Supports different import modes
- Files must be in `data/` directory
- Leverages your bulk API scripts

**Import Modes:**
- `bulk` - Uses bulk API for large datasets
- `simple` - Simple insert for small datasets  
- `batch` - Batch processing for medium datasets

### **5. Flow Management (`flow.manage`)**
Manage Salesforce Flows:

**Example Usage:**
```
"List flows via salesforce.flow.manage with action=list"
```

**Available Actions:**
- `list` - List existing flows
- `create-all` - Create all demo flows
- `deploy-all` - Deploy all flows
- `create-lead-assignment` - Create lead assignment flow
- `create-notification` - Create notification flow

### **6. Script Execution (`scripts.run`)**
Run your custom scripts:

**Example Usage:**
```
"Run quick products via salesforce.scripts.run name=quick-products"
```

**Available Scripts:**
- `quick-leads` - Generate quick lead data
- `quick-products` - Generate product data
- `generate-products` - Full product generation
- `soql-file` - Run SOQL from file

## 🎯 **Real-World Usage Examples**

### **Example 1: Deploy Your Agent Classes**
```
"Deploy the Agent APEX classes via salesforce.metadata.deploy with testLevel=NoTestRun"
```

### **Example 2: Test the Agent Classes**
```
"Execute Apex to test the Agent classes via salesforce.apex.execute"
```
*Then provide the Apex code from `scripts/apex/agent-examples.apex`*

### **Example 3: Query Lead Data**
```
"Run SOQL to get leads with their qualification scores via salesforce.soql.query"
```
*Query: `SELECT Id, Name, Company, Rating, AnnualRevenue, NumberOfEmployees FROM Lead WHERE Rating != null LIMIT 10`*

### **Example 4: Import Demo Data**
```
"Import leads from data/leads.csv using mode bulk via salesforce.data.import.csv"
```

### **Example 5: Create Demo Flows**
```
"Create all demo flows via salesforce.flow.manage with action=create-all"
```

## 🔒 **Security & Best Practices**

### **Security Features:**
- **Read-only SOQL** - No data modification via queries
- **Sandbox-only Apex** - Requires `SANDBOX_OK=1` environment variable
- **File restrictions** - CSV imports restricted to `data/` directory
- **Script whitelisting** - Only approved scripts can be executed

### **Best Practices:**
1. **Use Sandbox** - Always test in sandbox first
2. **Check Permissions** - Ensure your user has necessary permissions
3. **Monitor Limits** - Be aware of API and governor limits
4. **Backup Data** - Always backup before bulk operations
5. **Test Incrementally** - Test small changes before large deployments

## 🚨 **Troubleshooting**

### **Common Issues:**

**1. "Not authenticated to Salesforce org"**
```bash
# Re-authenticate
sf org login web
```

**2. "Apex execution disabled"**
```bash
# Enable for sandbox
export SANDBOX_OK=1
```

**3. "File not found"**
```bash
# Check file exists in data/ directory
ls data/
```

**4. "Permission denied"**
```bash
# Check user permissions in Salesforce
sf org display
```

## 🎉 **Advanced Usage**

### **Combining Tools:**
```
"First, query for leads, then deploy the Agent classes, then test them with Apex"
```

### **Data Pipeline:**
```
"Import leads, then qualify them using the Agent classes, then analyze the results"
```

### **Development Workflow:**
```
"Deploy changes, run tests, query results, and verify everything works"
```

## 💡 **Pro Tips**

1. **Use CSV for large data** - More efficient than individual records
2. **Test with small datasets first** - Validate before bulk operations
3. **Use SOQL to verify results** - Always check your data after operations
4. **Combine tools strategically** - Chain operations for complex workflows
5. **Monitor performance** - Watch for governor limits and timeouts

## 📚 **Related Documentation**

- [MCP Setup Guide](MCP_SETUP.md) - Basic setup instructions
- [Agent APEX Guide](AGENT_APEX_GUIDE.md) - Agent classes documentation
- [Cursor Salesforce Use Cases](CURSOR_SALESFORCE_USE_CASES.md) - Development workflows

## 🔗 **Useful Commands Reference**

### **MCP Server Management**
```bash
# Start MCP server
npm run mcp:start

# Check server status
ps aux | grep mcp

# Stop server
pkill -f "mcp:start"
```

### **Salesforce CLI Commands**
```bash
# List orgs
sf org list

# Display current org
sf org display

# Open org in browser
sf org open

# Run anonymous Apex
sf apex run --file scripts/apex/agent-examples.apex
```

### **Environment Variables**
```bash
# Set target org
export SFDX_DEFAULTUSERNAME=your-org-alias

# Enable Apex execution (sandbox only)
export SANDBOX_OK=1

# Set API version
export SFDX_API_VERSION=64.0
```

---

*This walkthrough is maintained by the Solution Engineering Team. For questions or contributions, please contact the team.*
