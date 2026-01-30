# 🔔 Slack Notifications Setup Guide

This guide helps you set up Slack notifications for the automated data pipeline.

## 📋 Step 1: Create a Slack App
1. Go to https://api.slack.com/apps
2. Create New App → From scratch
3. Name: Data Pipeline Notifications → Choose your workspace → Create

## 🔗 Step 2: Choose Webhook Type

### Option A: Incoming Webhooks (Simple & Reliable)
1. In the app, open "Incoming Webhooks"
2. Toggle ON
3. Add New Webhook to Workspace → choose channel
4. Copy URL (starts with `https://hooks.slack.com/services/...`)

### Option B: Workflow Webhook (If you use Slack Workflows)
Use a Workflow webhook URL (starts with `https://hooks.slack.com/triggers/...`).
- Set `.env` NOTIFY_SLACK_VARIABLE_NAME to your workflow variable name (e.g., `Message` or `text`).
- In your workflow’s Send Message body, use `{{Message}}` or `{{text}}` to display the content.

## ⚙️ Step 3: Configure .env
```
NOTIFY_ENABLED=true
NOTIFY_SLACK_WEBHOOK_URL=YOUR_WEBHOOK_URL
# For Workflow webhooks, match your field name exactly (Message or text)
NOTIFY_SLACK_VARIABLE_NAME=Message
```

## 🧪 Step 4: Test Notifications
```
python3 test_slack_notification.py
```

Or run a pipeline:
```
./scripts/run_pipeline.sh daily_all
```

## 🛠️ Troubleshooting
- Seeing `Type: {}` in Slack? Your workflow step likely isn’t referencing the right field. Use `{{Message}}` (or set `NOTIFY_SLACK_VARIABLE_NAME=text` and use `{{text}}`).
- Prefer simpler setup? Use an Incoming Webhook.


