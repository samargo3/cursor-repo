# Cursor Repo

> Centralized configuration, documentation, and project management for Cursor IDE

**GitHub:** [https://github.com/samargo3/cursor-repo](https://github.com/samargo3/cursor-repo)

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

#### Salesforce
- `demo-igniters/` - Salesforce demo platform with Agentforce, Einstein, and integrations
- `Agentforce Contract Analysis/` - Salesforce project with contract analysis flows and prompts

#### Node.js / TypeScript
- `argo-energy-solutions/` - Energy monitoring and analytics platform with React frontend

#### Python
- `project-data-pipeline/` - Salesforce to Tableau data pipeline with automation
- `My Sandbox/` - Python experiments and prototyping (includes pizza charts)
- `Pizza Chart Project/` - FBRef scout report scraper and visualizer

### Adding New Projects
Use the setup script to create new projects with shared configurations:
```bash
./scripts/setup-new-project.sh salesforce project-name
```

Or manually move existing projects:
```bash
mv /path/to/your/project ~/cursor-repo/projects/
```

## 🔀 Splitting Projects Into Standalone Repos

Each project can be extracted into its own Git repository with **full commit history** preserved using `split-monorepo.sh`.

### Quick Start

```bash
# See all configured projects
./split-monorepo.sh --list

# Dry run (no changes)
./split-monorepo.sh --dry-run

# Extract a single project
./split-monorepo.sh demo-igniters

# Extract all projects at once
./split-monorepo.sh
```

### What It Does

1. Runs `git subtree split` to isolate each project's history into a temporary branch
2. Creates a new directory at `~/project-name` as a standalone git repo
3. Pulls the filtered history (project files land at the repo root, not under `projects/`)
4. Sets the `origin` remote to `https://github.com/samargo3/<project-slug>.git`

### After Extraction

For each project:
```bash
cd ~/demo-igniters
ls -la                 # project files at root, no projects/ prefix
git log --oneline -10  # full commit history
git remote -v          # origin → GitHub

# Create the GitHub repo (if it doesn't exist yet), then push:
gh repo create samargo3/demo-igniters --private
git push -u origin main
```

### Cleanup

Once all repos are pushed:
```bash
# Delete the temporary split/* branches from cursor-repo
./split-monorepo.sh --cleanup

# Remove projects/ from cursor-repo (optional — keep this repo as a config hub)
git rm -r projects/
git commit -m "Remove extracted projects — each is now a standalone repo"
```

---

**Last Updated:** January 30, 2026
**Location:** `/Users/sargo/cursor-repo/`
