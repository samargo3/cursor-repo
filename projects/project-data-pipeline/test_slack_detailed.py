#!/usr/bin/env python3
"""
Detailed test with payload debug for Slack Workflow webhooks.
"""
import os, sys
from datetime import datetime
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))
from pipeline.notifier import notify_status

webhook = os.getenv('NOTIFY_SLACK_WEBHOOK_URL', '')
print('Webhook:', webhook[:60] + ('...' if webhook else ''))
print('Variable name:', os.getenv('NOTIFY_SLACK_VARIABLE_NAME','text'))

notify_status({
  'status': 'success',
  'timestamp': datetime.utcnow().isoformat()+'Z',
  'config_path': 'configs/weekly_activity.yaml',
  'exported_count': 2,
  'transformed_count': 2,
  'appended_rows': 200,
  'published_count': 0
})
print('Sent detailed test. If your Workflow shows Type: {}, update the message body to {{Message}} or {{text}} to match your .env variable name.')


