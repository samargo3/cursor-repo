#!/bin/bash
# Setup automation for Salesforce to Tableau pipeline
# This script creates launchd plist files for automated scheduling

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLIST_DIR="$HOME/Library/LaunchAgents"

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$PLIST_DIR"

echo "🚀 Setting up automation for Salesforce to Tableau pipeline..."
echo "Project directory: $PROJECT_DIR"

# Function to create plist file
create_plist() {
    local name=$1
    local schedule=$2
    local description=$3
    
    cat > "$PLIST_DIR/com.salesforce.pipeline.$name.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.salesforce.pipeline.$name</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$PROJECT_DIR/scripts/run_pipeline.sh</string>
        <string>$name</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        $schedule
    </dict>
    <key>StandardOutPath</key>
    <string>$PROJECT_DIR/logs/automation_$name.log</string>
    <key>StandardErrorPath</key>
    <string>$PROJECT_DIR/logs/automation_$name_error.log</string>
    <key>RunAtLoad</key>
    <false/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF
    
    echo "✅ Created plist for $name"
}

# Create runner script
cat > "$PROJECT_DIR/scripts/run_pipeline.sh" << 'EOF'
#!/bin/bash
# Automated pipeline runner script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Load environment
source .venv/bin/activate

# Get Salesforce tokens
export SF_ACCESS_TOKEN=$(sf org display --json | jq -r '.result.accessToken')
export SF_INSTANCE_URL=$(sf org display --json | jq -r '.result.instanceUrl')

# Run specific pipeline
case "$1" in
    "weekly")
        echo "$(date): Running weekly pipeline for all reports..."
        python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml
        python -m src.pipeline.cli run --config configs/weekly_deal_contribution.yaml
        python -m src.pipeline.cli run --config configs/weekly_activity.yaml
        ;;
    "opportunities")
        echo "$(date): Running opportunities pipeline..."
        python -m src.pipeline.cli run --config configs/weekly_opportunities.yaml
        ;;
    "deal_contribution")
        echo "$(date): Running deal contribution pipeline..."
        python -m src.pipeline.cli run --config configs/weekly_deal_contribution.yaml
        ;;
    "activity")
        echo "$(date): Running activity pipeline..."
        python -m src.pipeline.cli run --config configs/weekly_activity.yaml
        ;;
    *)
        echo "Usage: $0 {weekly|opportunities|deal_contribution|activity}"
        exit 1
        ;;
esac

echo "$(date): Pipeline run completed"
EOF

chmod +x "$PROJECT_DIR/scripts/run_pipeline.sh"

echo ""
echo "📋 Available scheduling options:"
echo ""

# Option 1: Weekly (Monday 6 AM)
create_plist "weekly" \
    "<key>Weekday</key>
    <integer>1</integer>
    <key>Hour</key>
    <integer>6</integer>
    <key>Minute</key>
    <integer>0</integer>" \
    "Weekly pipeline run (Monday 6 AM)"

# Option 2: Daily (6 AM)
create_plist "daily" \
    "<key>Hour</key>
    <integer>6</integer>
    <key>Minute</key>
    <integer>0</integer>" \
    "Daily pipeline run (6 AM)"

# Option 3: Business Days (Monday-Friday 7 AM)
create_plist "business_daily" \
    "<key>Weekday</key>
    <integer>1</integer>
    <key>Hour</key>
    <integer>7</integer>
    <key>Minute</key>
    <integer>0</integer>" \
    "Business daily pipeline run (Monday-Friday 7 AM)"

# Option 4: Twice Daily (6 AM and 6 PM)
create_plist "twice_daily_6am" \
    "<key>Hour</key>
    <integer>6</integer>
    <key>Minute</key>
    <integer>0</integer>" \
    "Twice daily pipeline run (6 AM)"

create_plist "twice_daily_6pm" \
    "<key>Hour</key>
    <integer>18</integer>
    <key>Minute</key>
    <integer>0</integer>" \
    "Twice daily pipeline run (6 PM)"

echo ""
echo "🎯 To activate a schedule, choose one and run:"
echo ""
echo "# Weekly (Monday 6 AM) - RECOMMENDED"
echo "launchctl load ~/Library/LaunchAgents/com.salesforce.pipeline.weekly.plist"
echo ""
echo "# Daily (6 AM)"
echo "launchctl load ~/Library/LaunchAgents/com.salesforce.pipeline.daily.plist"
echo ""
echo "# Business Days Only (Monday-Friday 7 AM)"
echo "launchctl load ~/Library/LaunchAgents/com.salesforce.pipeline.business_daily.plist"
echo ""
echo "# Twice Daily (6 AM and 6 PM)"
echo "launchctl load ~/Library/LaunchAgents/com.salesforce.pipeline.twice_daily_6am.plist"
echo "launchctl load ~/Library/LaunchAgents/com.salesforce.pipeline.twice_daily_6pm.plist"
echo ""
echo "🔍 To check status:"
echo "launchctl list | grep salesforce"
echo ""
echo "🛑 To stop automation:"
echo "launchctl unload ~/Library/LaunchAgents/com.salesforce.pipeline.weekly.plist"
echo ""
echo "📝 Logs will be written to:"
echo "$PROJECT_DIR/logs/automation_*.log"
