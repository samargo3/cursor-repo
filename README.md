# Cursor Repo

> Centralized configuration, documentation, and project management for Cursor IDE

## 🎯 Purpose

This repository contains:
- **Shared configurations** for Cursor rules, VSCode settings, linting
- **Documentation** for MCPs, workflows, and best practices
- **Multiple projects** (Salesforce demos, client work, experiments)
- **Templates** for quickly starting new projects

## 📂 Structure

- `shared-configs/` - Reusable Cursor rules and settings
- `documentation/` - Guides, workflows, MCP docs
- `projects/` - Individual projects (Salesforce, Node.js, etc.)
- `scripts/` - Automation scripts
- `archive/` - Completed projects

## 🚀 Quick Start

### Open Entire Workspace
```bash
cursor ~/cursor-repo
```

### Open Individual Project
```bash
cursor ~/cursor-repo/projects/demo-igniters
```

### Create New Project
```bash
cd ~/cursor-repo
./scripts/setup-new-project.sh salesforce my-new-demo
```

## 📚 Documentation

See `documentation/` folder for:
- MCP setup guides
- Salesforce workflows
- Agentforce configuration
- Einstein setup
- Troubleshooting

## ⚙️ MCPs Configured (User-Level)

These work across all projects automatically:
- ✅ cursor-ide-browser
- ✅ cursor-browser-extension
- ✅ user-github
- ✅ user-tableau
- ✅ Custom Salesforce MCP

## 🎨 Skills Available (User-Level)

- ✅ create-rule
- ✅ create-skill
- ✅ update-cursor-settings

## 🔧 Projects

### Active Projects
- `demo-igniters/` - Salesforce demo platform with Agentforce, Einstein, and integrations

### Adding New Projects
Use the setup script to create new projects with shared configurations:
```bash
./scripts/setup-new-project.sh salesforce project-name
```

---

**Last Updated:** January 30, 2026
**Location:** `/Users/sargo/cursor-repo/`
