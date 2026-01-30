# Quick Start Guide

## 🎯 Open Your Cursor Repo

### Option 1: Terminal (Fastest)
```bash
cursor ~/cursor-repo
```

### Option 2: Workspace File (Best for Multi-Project Work)
```bash
cursor ~/cursor-repo/cursor-repo.code-workspace
```

### Option 3: From Cursor
File → Open Folder → Navigate to `/Users/sargo/cursor-repo`

---

## 🚀 Common Commands

### Create New Salesforce Project
```bash
cd ~/cursor-repo
./scripts/setup-new-project.sh salesforce project-name
```

### Open Demo Igniters
```bash
cursor ~/cursor-repo/projects/demo-igniters
```

### Sync with GitHub
```bash
cd ~/cursor-repo
git add .
git commit -m "Your changes"
git push
```

---

## 📂 Quick Navigation

| What | Path |
|------|------|
| **Shared Cursor Rules** | `shared-configs/cursor-rules/` |
| **VSCode Settings** | `shared-configs/vscode/` |
| **Documentation** | `documentation/` |
| **MCP Guides** | `documentation/mcps/` |
| **All Projects** | `projects/` |
| **Demo Igniters** | `projects/demo-igniters/` |
| **Scripts** | `scripts/` |

---

## 🎨 What's Configured

### ✅ User-Level (Works Everywhere)
- cursor-ide-browser
- cursor-browser-extension  
- user-github
- user-tableau
- create-rule skill
- create-skill skill
- update-cursor-settings skill

### ✅ Shared Configurations
- Apex coding standards
- LWC best practices
- VSCode settings templates
- ESLint/Prettier configs

### ✅ Projects
- demo-igniters (Salesforce demo platform)

---

## 📝 Next Steps

1. **Open in Cursor**: `cursor ~/cursor-repo`
2. **Explore the structure**: Check out `shared-configs/` and `documentation/`
3. **Push to GitHub**: 
   ```bash
   cd ~/cursor-repo
   gh repo create cursor-repo --private --source=. --push
   ```
4. **Create new project**: Use `./scripts/setup-new-project.sh`

---

## 💡 Pro Tips

- **Search Everything**: Open root folder to search across all projects
- **Use Workspace**: Open `.code-workspace` file for best experience
- **Symlinks Stay Synced**: Shared rules automatically update in all projects
- **Document As You Go**: Add to `documentation/` folder

---

**Full Guide:** See `SETUP_GUIDE.md`  
**Questions:** Add to `documentation/troubleshooting/common-issues.md`
