## Salesforce MCP Server Setup

### Prerequisites
- Node 18+
- Salesforce CLI (`sf`) or legacy `sfdx`
- Authenticated org (`sf org login web` or `sfdx force:auth:web:login`)

### Install deps
```bash
npm install
```

### Run the server
```bash
# optional: pick target org
export SFDX_DEFAULTUSERNAME=<your-username-or-alias>

# to allow apex anonymous (sandbox only), explicitly opt-in
export SANDBOX_OK=1  # omit for prod/scratch if you want to block

npm run mcp:start
```

The server exposes tools:
- `soql.query`: Run SOQL; returns JSON by default, CSV with `csv=true`.
- `apex.execute`: Execute anonymous Apex (blocked unless `SANDBOX_OK=1`).
- `metadata.deploy`: Deploy `force-app/` using `sf project deploy start`.
 - `data.import.csv`: Import CSV using repo scripts. Inputs: `{ file, mode }` where `file` is under `data/` and `mode` is one of `bulk`, `simple`, `batch`.
 - `flow.manage`: Manage demo flows via script. Inputs: `{ action }` where `action` is one of `list`, `create-all`, `deploy-all`, `create-lead-assignment`, `create-notification`.
 - `scripts.run`: Run whitelisted scripts. Inputs: `{ name, args? }` where `name` is one of `quick-leads`, `quick-products`, `generate-products`, `soql-file`.

### Configure Cursor as MCP client
Add to Cursor MCP config (Settings → MCP):
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

Then, in a chat, invoke tools like:
- "Run SOQL to list 10 Leads with Status=Open via salesforce.soql.query"
- "Deploy metadata via salesforce.metadata.deploy with testLevel=NoTestRun"
 - "Import leads from data/leads.csv using mode bulk via salesforce.data.import.csv"
 - "List flows via salesforce.flow.manage with action=list"
 - "Run quick products via salesforce.scripts.run name=quick-products"

### Notes
- Prefer `sf` CLI; the server falls back to `sfdx` if `sf` is unavailable.
- Ensure you’re in a sandbox when enabling `SANDBOX_OK=1`.

