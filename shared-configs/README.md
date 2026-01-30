# Shared Configurations

> Reusable configurations for all projects in cursor-repo

## 📁 Contents

### `cursor-rules/`
Cursor AI behavior rules that can be shared across projects:
- `salesforce-apex-standards.md` - Apex coding conventions
- `salesforce-lwc-best-practices.md` - Lightning Web Component patterns
- `salesforce-ui-ux-standards.md` - World-class UI/UX design system for LWC
- `salesforce-testing-requirements.md` - Testing standards
- `nodejs-standards.md` - Node.js best practices

### `vscode/`
VSCode/Cursor settings templates:
- `salesforce-settings.json` - Salesforce project settings
- `salesforce-extensions.json` - Recommended extensions
- `nodejs-settings.json` - Node.js project settings

### `linting/`
Code formatting and linting configurations:
- `.prettierrc.salesforce` - Prettier config for Salesforce
- `.eslintrc.salesforce.json` - ESLint config for Salesforce
- `.prettierrc.nodejs` - Prettier config for Node.js

### `templates/`
Project starter templates:
- `salesforce-standard/` - Standard Salesforce DX project
- `nodejs-api/` - Node.js API project

## 🔗 Using Shared Configs

### In New Projects

**Option 1: Symlink** (Recommended - stays in sync)
```bash
cd ~/cursor-repo/projects/my-project
mkdir -p .cursor/rules
ln -s ../../shared-configs/cursor-rules .cursor/rules/shared
```

**Option 2: Copy**
```bash
cp ~/cursor-repo/shared-configs/vscode/salesforce-settings.json .vscode/settings.json
```

### Updating Shared Configs

When you update files in `shared-configs/`, projects using symlinks automatically get the updates!

## 📝 Best Practices

1. **Keep it DRY** - Don't duplicate configs across projects
2. **Version Control** - Commit shared configs to git
3. **Document Changes** - Update this README when adding new configs
4. **Test Before Sharing** - Validate configs in one project before moving to shared

---

**Last Updated:** January 30, 2026
