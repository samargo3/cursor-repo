#!/usr/bin/env python3
"""
Simple test script for Slack notifications.
"""
import os, sys
from datetime import datetime
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))
from pipeline.notifier import notify_status

if os.getenv('NOTIFY_ENABLED', 'true').lower() in ('0','false','no'):
    print('Notifications disabled; set NOTIFY_ENABLED=true in .env')
    raise SystemExit(0)

if not os.getenv('NOTIFY_SLACK_WEBHOOK_URL'):
    print('Slack webhook not configured; set NOTIFY_SLACK_WEBHOOK_URL in .env')
    raise SystemExit(1)

print('Sending success test...')
notify_status({
  'status': 'success',
  'timestamp': datetime.utcnow().isoformat()+'Z',
  'config_path': 'configs/weekly_opportunities.yaml',
  'exported_count': 1,
  'transformed_count': 1,
  'appended_rows': 123,
  'published_count': 0
})
print('Sending failure test...')
notify_status({
  'status': 'failure',
  'timestamp': datetime.utcnow().isoformat()+'Z',
  'config_path': 'configs/weekly_deal_contribution.yaml',
  'error': 'Simulated failure'
})
print('Done. Check Slack.')


