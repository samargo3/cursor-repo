#!/bin/bash

# GitHub Setup Script for Salesforce Project
# This script helps you create a GitHub repository and push your code

echo "🚀 Setting up GitHub repository for your Salesforce project..."
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Git repository not initialized. Please run 'git init' first."
    exit 1
fi

# Check if we have commits
if ! git log --oneline -1 > /dev/null 2>&1; then
    echo "❌ No commits found. Please commit your changes first."
    exit 1
fi

echo "✅ Git repository is ready!"
echo ""

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📋 Current branch: $CURRENT_BRANCH"
echo ""

echo "📝 Next steps to sync with GitHub:"
echo ""
echo "1. Create a new repository on GitHub:"
echo "   - Go to https://github.com/new"
echo "   - Choose a repository name (e.g., 'salesforce-einstein-leads')"
echo "   - Make it public or private as preferred"
echo "   - DON'T initialize with README, .gitignore, or license (we already have these)"
echo "   - Click 'Create repository'"
echo ""
echo "2. After creating the repository, GitHub will show you commands like:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Run those commands to push your code:"
echo ""

# Ask user for repository details
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your repository name: " REPO_NAME

if [ -n "$GITHUB_USERNAME" ] && [ -n "$REPO_NAME" ]; then
    echo ""
    echo "🔗 Setting up remote repository..."
    
    # Add remote origin
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    
    # Rename branch to main if needed
    if [ "$CURRENT_BRANCH" != "main" ]; then
        git branch -M main
        echo "✅ Renamed branch to 'main'"
    fi
    
    # Push to GitHub
    echo "📤 Pushing code to GitHub..."
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 Success! Your project is now on GitHub:"
        echo "   https://github.com/$GITHUB_USERNAME/$REPO_NAME"
        echo ""
        echo "📋 Repository includes:"
        echo "   ✅ Salesforce project structure"
        echo "   ✅ Lead generation scripts for Einstein Lead Scoring"
        echo "   ✅ Comprehensive documentation"
        echo "   ✅ Deployment guides"
        echo ""
        echo "🔗 You can now:"
        echo "   - Share the repository with your team"
        echo "   - Clone it on other machines"
        echo "   - Use GitHub for version control"
        echo "   - Set up CI/CD pipelines"
    else
        echo "❌ Failed to push to GitHub. Please check your credentials and try again."
    fi
else
    echo ""
    echo "📝 Manual setup instructions:"
    echo ""
    echo "1. Create repository on GitHub: https://github.com/new"
    echo "2. Run these commands:"
    echo "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
fi

echo ""
echo "💡 Tips:"
echo "   - Make sure you're logged into GitHub in your terminal"
echo "   - If you haven't set up SSH keys, you'll need to enter your GitHub password"
echo "   - Consider using GitHub CLI for easier repository management: brew install gh" 