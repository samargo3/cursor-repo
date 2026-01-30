# GitHub Setup Guide

This guide will help you sync your Salesforce project with GitHub.

## 🚀 Quick Setup

### Option 1: Automated Setup (Recommended)
```bash
npm run setup:github
```
This will guide you through the entire process interactively.

### Option 2: Manual Setup

#### Step 1: Create GitHub Repository
1. Go to [GitHub New Repository](https://github.com/new)
2. Choose a repository name (e.g., `salesforce-einstein-leads`)
3. Make it public or private as preferred
4. **Important**: Don't initialize with README, .gitignore, or license (we already have these)
5. Click "Create repository"

#### Step 2: Connect and Push
```bash
# Add the remote repository
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Rename branch to main (if needed)
git branch -M main

# Push your code
git push -u origin main
```

## 📋 What's Included

Your repository will contain:

- ✅ **Salesforce Project Structure**
  - Force-app components
  - Apex classes and triggers
  - Lightning Web Components
  - Custom metadata

- ✅ **Lead Generation Scripts**
  - `scripts/generate-leads.js` - Creates 1000 realistic leads
  - `scripts/deploy-leads.js` - Deploys to Salesforce
  - `scripts/execute-import.apex` - Apex import script

- ✅ **Documentation**
  - `DEPLOYMENT_GUIDE.md` - Comprehensive setup guide
  - `scripts/README.md` - Script documentation
  - `GITHUB_SETUP.md` - This guide

- ✅ **Configuration**
  - `.gitignore` - Properly configured for Salesforce
  - `package.json` - NPM scripts for easy execution
  - `sfdx-project.json` - Salesforce DX project config

## 🔐 Authentication

### Option A: HTTPS (Password)
- You'll be prompted for your GitHub username and password
- If you have 2FA enabled, use a Personal Access Token instead of password

### Option B: SSH Keys (Recommended)
1. Generate SSH key: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Add to SSH agent: `ssh-add ~/.ssh/id_ed25519`
3. Add to GitHub: Copy public key to GitHub Settings → SSH Keys
4. Use SSH URL: `git remote add origin git@github.com:USERNAME/REPO.git`

## 🛠️ GitHub CLI (Optional)

For easier repository management, install GitHub CLI:
```bash
# macOS
brew install gh

# Then authenticate
gh auth login
```

## 📈 Next Steps After GitHub Setup

1. **Share with your team**
   - Clone the repository on other machines
   - Set up branch protection rules
   - Configure team access

2. **Set up CI/CD**
   - GitHub Actions for automated testing
   - Automated deployment to Salesforce
   - Code quality checks

3. **Version Control Best Practices**
   - Create feature branches for new development
   - Use pull requests for code review
   - Keep main branch stable

## 🎯 Repository Structure

```
demo-igniters/
├── force-app/                    # Salesforce components
├── scripts/                      # Lead generation scripts
│   ├── generate-leads.js        # Generate 1000 leads
│   ├── deploy-leads.js          # Deploy to Salesforce
│   └── setup-github.sh          # GitHub setup script
├── data/                         # Sample data files
├── config/                       # Salesforce configuration
├── specs/                        # Agent specifications
├── DEPLOYMENT_GUIDE.md          # Comprehensive guide
├── GITHUB_SETUP.md              # This guide
└── package.json                  # NPM scripts
```

## 🚨 Important Notes

- **No sensitive data**: The `.gitignore` excludes Salesforce credentials and cache files
- **Fictional data**: Generated leads are fictional and safe for demo purposes
- **Public repository**: Consider making private if containing sensitive business logic

## 📞 Support

If you encounter issues:
1. Check your GitHub credentials
2. Ensure you have proper permissions for the repository
3. Verify your Git configuration: `git config --list` 