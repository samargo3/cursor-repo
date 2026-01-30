#!/bin/bash
# Create new project with shared configs

PROJECT_TYPE=$1
PROJECT_NAME=$2

if [ -z "$PROJECT_TYPE" ] || [ -z "$PROJECT_NAME" ]; then
  echo "Usage: ./setup-new-project.sh <type> <name>"
  echo ""
  echo "Types:"
  echo "  salesforce  - Salesforce project with SFDX"
  echo "  nodejs      - Node.js project"
  echo "  python      - Python project"
  exit 1
fi

PROJECT_PATH="projects/$PROJECT_NAME"

if [ -d "$PROJECT_PATH" ]; then
  echo "❌ Error: Project '$PROJECT_NAME' already exists"
  exit 1
fi

echo "🚀 Creating $PROJECT_TYPE project: $PROJECT_NAME"

mkdir -p "$PROJECT_PATH"

# Create based on type
case "$PROJECT_TYPE" in
  salesforce)
    echo "📦 Generating Salesforce project..."
    cd "$PROJECT_PATH"
    sfdx project generate -n "$PROJECT_NAME"
    
    # Create .cursor/rules structure
    mkdir -p .cursor/rules
    cd .cursor/rules
    ln -s ../../../shared-configs/cursor-rules shared
    
    cd ../..
    
    # Copy VSCode settings
    mkdir -p .vscode
    cp ../../shared-configs/vscode/salesforce-settings.json .vscode/settings.json 2>/dev/null || true
    cp ../../shared-configs/vscode/salesforce-extensions.json .vscode/extensions.json 2>/dev/null || true
    
    echo "✅ Salesforce project created!"
    echo "📝 Next steps:"
    echo "   1. cd $PROJECT_PATH"
    echo "   2. sf org login web --alias $PROJECT_NAME"
    echo "   3. Create project-specific Cursor rules in .cursor/rules/"
    ;;
    
  nodejs)
    echo "📦 Creating Node.js project..."
    mkdir -p "$PROJECT_PATH"/{src,tests,.cursor/rules}
    cd "$PROJECT_PATH"
    npm init -y
    
    ln -s ../../shared-configs/cursor-rules .cursor/rules/shared
    
    echo "✅ Node.js project created!"
    ;;
    
  *)
    echo "❌ Unknown project type: $PROJECT_TYPE"
    exit 1
    ;;
esac

cd ../..
echo ""
echo "🎉 Project ready: $PROJECT_PATH"
echo "💡 Open in Cursor: cursor ~/cursor-repo/$PROJECT_PATH"
