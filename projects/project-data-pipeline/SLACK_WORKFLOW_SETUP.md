# 🔧 Slack Workflow Setup Guide

If you use a Slack Workflow webhook (URL contains `/triggers/`), configure your workflow to read the posted fields.

## Expected Payload
Our notifier sends a single field named according to `.env` `NOTIFY_SLACK_VARIABLE_NAME` (default `text`). For Workflows, set it to `Message` or `text` and reference that in the message step.

Example values to use in "Send a message":
```
{{Message}}
```
Or
```
{{text}}
```

## Steps
1. Open https://api.slack.com/apps → your app → Workflows
2. Select your Workflow (Webhook Trigger)
3. In "Send a message" step, set the message body to `{{Message}}` (or the variable name you chose)
4. Save → Publish → Test

## Alternative
Switch to an Incoming Webhook (`/services/` URL) which always uses the `text` property and requires no Workflow mapping.


