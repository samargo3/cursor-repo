# Cursor Repo Setup Guide

## ✅ Setup Complete!

Your cursor-repo is ready at: `/Users/sargo/cursor-repo/`

## 🚀 How to Access

### Open Entire Repository
```bash
cursor ~/cursor-repo
```

### Open Specific Project
```bash
cursor ~/cursor-repo/projects/demo-igniters
```

### Open from Cursor
1. File → Open Folder
2. Navigate to `/Users/sargo/cursor-repo`
3. Click Open

## 📂 What's Inside

```
cursor-repo/
├── README.md                    # Overview and quick start
├── SETUP_GUIDE.md              # This file
├── .gitignore                  # Git ignore patterns
│
├── shared-configs/             # Reusable configurations
│   ├── cursor-rules/           # AI behavior rules
│   │   ├── salesforce-apex-standards.md
│   │   └── salesforce-lwc-best-practices.md
│   └── vscode/                 # Editor settings
│       ├── salesforce-settings.json
│       └── salesforce-extensions.json
│
├── documentation/              # Knowledge base
│   ├── mcps/                   # MCP server docs
│   ├── workflows/              # How-to guides
│   ├── skills/                 # Skills documentation
│   └── troubleshooting/        # Common issues
│
├── projects/                   # Your projects
│   └── demo-igniters/          # Salesforce demo platform
│
├── scripts/                    # Automation
│   └── setup-new-project.sh    # Create new projects
│
└── archive/                    # Completed projects
```

## 🎯 Creating New Projects

### Salesforce Project
```bash
cd ~/cursor-repo
./scripts/setup-new-project.sh salesforce new-project-name
```

This will:
- Generate SFDX project structure
- Link shared Cursor rules
- Copy VSCode settings
- Set up proper configuration

### Node.js Project
```bash
cd ~/cursor-repo
./scripts/setup-new-project.sh nodejs my-api
```

## 📚 Using Shared Configurations

All projects can access shared configurations through symlinks:

```
projects/my-project/.cursor/rules/shared/
  → points to shared-configs/cursor-rules/
```

When you update `shared-configs/`, all projects automatically get the updates!

## 🔄 Syncing with GitHub

### Create GitHub Repository
```bash
cd ~/cursor-repo
gh repo create cursor-repo --private --source=. --push
```

Or create manually:
1. Go to GitHub.com
2. Create new repository named "cursor-repo"
3. Follow instructions to push existing repository

### Push Changes
```bash
cd ~/cursor-repo
git add .
git commit -m "Your commit message"
git push
```

### Pull Changes
```bash
cd ~/cursor-repo
git pull
```

## ⚙️ MCPs Available

These work automatically in all projects:
- ✅ cursor-ide-browser (frontend testing)
- ✅ cursor-browser-extension (webapp testing)
- ✅ user-github (GitHub integration)
- ✅ user-tableau (Tableau integration)

Custom Salesforce MCP in demo-igniters:
```bash
cd ~/cursor-repo/projects/demo-igniters
npm run mcp:start
```

## 🎨 Cursor Skills Available

- ✅ create-rule
- ✅ create-skill
- ✅ update-cursor-settings

## 📝 Best Practices

### Adding New Cursor Rules
1. Create rule in `shared-configs/cursor-rules/`
2. Projects with symlinks automatically see it
3. Document the rule's purpose in comments

### Organizing Projects
- **Active work** → `projects/`
- **Completed** → `archive/`
- Each project should have its own README

### Documentation
- Add workflow guides to `documentation/workflows/`
- Document MCPs in `documentation/mcps/`
- Keep troubleshooting notes in `documentation/troubleshooting/`

## 🚨 Important Notes

### Demo Igniters Git Repository
The `projects/demo-igniters/` folder has its own Git repository. This is fine, but be aware:
- Changes in demo-igniters won't automatically commit to cursor-repo
- You can remove the nested .git if you want to manage it all together:
  ```bash
  rm -rf ~/cursor-repo/projects/demo-igniters/.git
  ```

### .gitignore
The root `.gitignore` excludes:
- `node_modules/`
- `.sfdx/`
- `.env` files
- Build outputs

Add project-specific ignores in each project's `.gitignore`

## 🎓 Next Steps

1. ✅ Open cursor-repo in Cursor: `cursor ~/cursor-repo`
2. ⬜ Create GitHub repository and push
3. ⬜ Explore shared configurations
4. ⬜ Add project-specific documentation
5. ⬜ Create your first new project

## 💡 Tips

### Quick Navigation
Add alias to your shell config (~/.zshrc):
```bash
alias cursor-repo="cursor ~/cursor-repo"
alias cr-demo="cursor ~/cursor-repo/projects/demo-igniters"
```

Then just type: `cursor-repo` to open!

### Multi-Root Workspace
Create `cursor-repo.code-workspace` to open multiple projects at once (see main README for example)

### Search Across Projects
When you open the entire cursor-repo folder, you can search across all projects simultaneously!

---

**Questions?** Add to `documentation/troubleshooting/common-issues.md`

**Happy coding!** 🎉
