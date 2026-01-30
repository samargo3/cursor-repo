# Configured MCPs

> Model Context Protocol servers available in Cursor

## ✅ User-Level MCPs (Work Across All Projects)

These are configured at the user level and work automatically in every project:

### 1. cursor-ide-browser
**Purpose:** Browser automation for frontend testing  
**Use cases:**
- Testing web apps
- Visual regression testing
- Frontend development

### 2. cursor-browser-extension
**Purpose:** Additional browser capabilities  
**Use cases:**
- Webapp testing
- Browser automation

### 3. user-github
**Purpose:** GitHub integration  
**Use cases:**
- Creating issues
- Managing PRs
- Code search

### 4. user-tableau
**Purpose:** Tableau integration  
**Use cases:**
- Data visualization
- Dashboard creation

### 5. Custom Salesforce MCP (Project-Specific)
**Location:** `projects/demo-igniters/mcp/salesforce-mcp-server.js`

**Tools:**
- `soql_query` - Run SOQL queries
- `apex_execute` - Execute Apex code (sandbox only)
- `metadata_deploy` - Deploy metadata
- `data_import_csv` - Import CSV data
- `flow_manage` - Manage flows
- `scripts_run` - Run project scripts

**Usage:**
```bash
cd ~/cursor-repo/projects/demo-igniters
npm run mcp:start
```

## 📝 Adding New MCPs

MCPs are configured at the user level in Cursor settings.

To add a new MCP:
1. Install the MCP server
2. Configure in Cursor settings
3. Document here for reference

---

**Last Updated:** January 30, 2026
