#!/bin/bash
# Setup business days automation for 2:00 PM EST
# This creates a launchd plist for Monday-Friday at 2:00 PM

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLIST_DIR="$HOME/Library/LaunchAgents"

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$PLIST_DIR"

echo "🚀 Setting up business days automation (Monday-Friday 2:00 PM EST)..."
echo "Project directory: $PROJECT_DIR"

# Create runner script if it doesn't exist
if [ ! -f "$PROJECT_DIR/scripts/run_pipeline.sh" ]; then
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
    "business_daily")
        echo "$(date): Running business daily pipeline for all reports..."
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
        echo "Usage: $0 {weekly|business_daily|opportunities|deal_contribution|activity}"
        exit 1
        ;;
esac

echo "$(date): Pipeline run completed"
EOF
    
    chmod +x "$PROJECT_DIR/scripts/run_pipeline.sh"
    echo "✅ Created runner script"
fi

# Create plist for business days at 2:00 PM EST (Monday-Friday)
cat > "$PLIST_DIR/com.salesforce.pipeline.business_daily_2pm.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.salesforce.pipeline.business_daily_2pm</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$PROJECT_DIR/scripts/run_pipeline.sh</string>
        <string>business_daily</string>
    </array>
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>14</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>14</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>3</integer>
            <key>Hour</key>
            <integer>14</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>4</integer>
            <key>Hour</key>
            <integer>14</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>5</integer>
            <key>Hour</key>
            <integer>14</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
    </array>
    <key>StandardOutPath</key>
    <string>$PROJECT_DIR/logs/automation_business_daily_2pm.log</string>
    <key>StandardErrorPath</key>
    <string>$PROJECT_DIR/logs/automation_business_daily_2pm_error.log</string>
    <key>RunAtLoad</key>
    <false/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

echo "✅ Created plist for business days automation (Monday-Friday 2:00 PM EST)"
echo ""
echo "🎯 To activate this schedule:"
echo "launchctl load ~/Library/LaunchAgents/com.salesforce.pipeline.business_daily_2pm.plist"
echo ""
echo "🔍 To check status:"
echo "launchctl list | grep salesforce"
echo ""
echo "🛑 To stop automation:"
echo "launchctl unload ~/Library/LaunchAgents/com.salesforce.pipeline.business_daily_2pm.plist"
echo ""
echo "📝 Logs will be written to:"
echo "$PROJECT_DIR/logs/automation_business_daily_2pm.log"
echo ""
echo "📅 Schedule: Monday-Friday at 2:00 PM EST"
echo "⏰ Next run: $(date -v+1d '+%A at 2:00 PM')"
