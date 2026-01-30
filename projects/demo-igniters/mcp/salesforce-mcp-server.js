#!/usr/bin/env node
"use strict";

const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require("@modelcontextprotocol/sdk/types.js");
const { execa } = require("execa");
const { customAlphabet } = require("nanoid");
const fs = require("fs");
const path = require("path");

const generateId = customAlphabet("23456789ABCDEFGHJKLMNPQRSTUVWXYZ", 8);

function resolveOrgFlag() {
  // Prefer SF_TARGET_ORG, fallback to SFDX_DEFAULTUSERNAME
  const targetOrg = process.env.SF_TARGET_ORG || process.env.SFDX_DEFAULTUSERNAME;
  return targetOrg ? ["-o", targetOrg] : [];
}

async function runSf(args) {
  try {
    const { stdout } = await execa("sf", args, { stdout: "pipe", stderr: "pipe" });
    return stdout;
  } catch (error) {
    throw new Error(`SF CLI Error: ${error.message}`);
  }
}

function createSalesforceTools() {
  return [
    {
      name: "soql_query",
      description: "Run a SOQL query in the default org. Read-only.",
      inputSchema: {
        type: "object",
        properties: {
          soql: {
            type: "string",
            description: "SOQL query string",
          },
          csv: {
            type: "boolean",
            description: "Return CSV instead of JSON",
          },
        },
        required: ["soql"],
      },
    },
    {
      name: "apex_execute",
      description: "Execute anonymous Apex in sandbox only. Requires SANDBOX_OK=1 env.",
      inputSchema: {
        type: "object",
        properties: {
          apex: {
            type: "string",
            description: "Anonymous Apex code",
          },
        },
        required: ["apex"],
      },
    },
    {
      name: "metadata_deploy",
      description: "Deploy local metadata from force-app/ to the org.",
      inputSchema: {
        type: "object",
        properties: {
          testLevel: {
            type: "string",
            enum: ["NoTestRun", "RunLocalTests", "RunAllTestsInOrg"],
            description: "Test level for deployment",
          },
        },
      },
    },
    {
      name: "data_import_csv",
      description: "Import CSV leads from data/ using existing project scripts.",
      inputSchema: {
        type: "object",
        properties: {
          file: {
            type: "string",
            description: "CSV path under data/, e.g., data/leads.csv",
          },
          mode: {
            type: "string",
            enum: ["bulk", "simple", "batch"],
            description: "Which importer to use: bulk, simple, or batch",
          },
        },
        required: ["file", "mode"],
      },
    },
    {
      name: "flow_manage",
      description: "Manage demo flows via existing script create/deploy/list.",
      inputSchema: {
        type: "object",
        properties: {
          action: {
            type: "string",
            enum: ["list", "create-all", "deploy-all", "create-lead-assignment", "create-notification"],
            description: "Flow operation to perform",
          },
        },
        required: ["action"],
      },
    },
    {
      name: "scripts_run",
      description: "Run a whitelisted project script with optional args.",
      inputSchema: {
        type: "object",
        properties: {
          name: {
            type: "string",
            enum: ["quick-leads", "quick-products", "generate-products", "soql-file"],
            description: "Script identifier",
          },
          args: {
            type: "array",
            items: { type: "string" },
            description: "Additional args for the script",
          },
        },
        required: ["name"],
      },
    },
  ];
}

async function handleToolCall(name, args) {
  const id = generateId();

  try {
    switch (name) {
      case "soql_query": {
        const sfArgs = ["data", "query", "--query", args.soql, "--json", ...resolveOrgFlag()];
        const raw = await runSf(sfArgs);
        
        if (args.csv) {
          const csvArgs = ["data", "query", "--query", args.soql, "--result-format", "csv", ...resolveOrgFlag()];
          const csvOut = await runSf(csvArgs);
          return { id, result: csvOut, format: "csv" };
        }
        
        const parsed = JSON.parse(raw);
        return { id, result: parsed, format: "json" };
      }

      case "apex_execute": {
        if (process.env.SANDBOX_OK !== "1") {
          throw new Error("apex_execute disabled. Set SANDBOX_OK=1 to enable.");
        }
        const apexArgs = ["apex", "run", ...resolveOrgFlag()];
        const { stdout } = await execa("sf", apexArgs, {
          input: args.apex,
          stdout: "pipe",
          stderr: "pipe",
        });
        return { id, output: stdout };
      }

      case "metadata_deploy": {
        const deployArgs = [
          "project",
          "deploy",
          "start",
          "--source-dir",
          "force-app",
          ...(args.testLevel ? ["--test-level", args.testLevel] : []),
          "--json",
          ...resolveOrgFlag(),
        ];
        const output = await runSf(deployArgs);
        return { id, output: JSON.parse(output) };
      }

      case "data_import_csv": {
        const dataDir = path.resolve(process.cwd(), "data");
        const resolved = path.resolve(process.cwd(), args.file);
        
        if (!resolved.startsWith(dataDir)) {
          throw new Error("File must be within data/ directory");
        }
        if (!fs.existsSync(resolved)) {
          throw new Error(`File not found: ${args.file}`);
        }
        
        const scriptMap = {
          bulk: ["node", ["scripts/import-leads-bulk.js", resolved]],
          simple: ["node", ["scripts/import-leads-simple.js", resolved]],
          batch: ["node", ["scripts/batch-import-leads.js", resolved]],
        };
        
        const [cmd, scriptArgs] = scriptMap[args.mode];
        const { stdout } = await execa(cmd, scriptArgs, { stdout: "pipe", stderr: "pipe" });
        return { id, output: stdout };
      }

      case "flow_manage": {
        const actionArgMap = {
          list: "list",
          "create-all": "create-all",
          "deploy-all": "deploy-all",
          "create-lead-assignment": "create-lead-assignment",
          "create-notification": "create-notification",
        };
        
        const arg = actionArgMap[args.action];
        const { stdout } = await execa("node", ["scripts/create-demo-flow.js", arg], {
          stdout: "pipe",
          stderr: "pipe",
        });
        return { id, output: stdout };
      }

      case "scripts_run": {
        const scriptMap = {
          "quick-leads": ["node", ["scripts/quick-leads.js"]],
          "quick-products": ["node", ["scripts/quick-products.js"]],
          "generate-products": ["node", ["scripts/generate-products.js"]],
          "soql-file": ["node", ["scripts/run-soql.js"]],
        };
        
        const entry = scriptMap[args.name];
        if (!entry) throw new Error("Script not allowed");
        
        const [cmd, baseArgs] = entry;
        const finalArgs = Array.isArray(args.args) && args.args.length ? baseArgs.concat(args.args) : baseArgs;
        const { stdout } = await execa(cmd, finalArgs, { stdout: "pipe", stderr: "pipe" });
        return { id, output: stdout };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      id,
      error: error.message,
      isError: true,
    };
  }
}

async function main() {
  const server = new Server(
    {
      name: "salesforce-mcp-server",
      version: "0.1.0",
    },
    {
      capabilities: {
        tools: {},
      },
    }
  );

  server.setRequestHandler(ListToolsRequestSchema, async () => {
    return {
      tools: createSalesforceTools(),
    };
  });

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const result = await handleToolCall(request.params.name, request.params.arguments || {});
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  });

  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
