"""
Notification helpers for pipeline status events.

Supports:
- Slack Incoming Webhook (env: NOTIFY_SLACK_WEBHOOK_URL)
- SMTP email (env: SMTP_* and NOTIFY_EMAIL_TO/NOTIFY_EMAIL_FROM)

Usage:
    from .notifier import notify_status
    notify_status(summary_dict)
"""

import json
import os
import smtplib
import ssl
from email.message import EmailMessage
from typing import Dict, Any
from urllib import request


def _post_slack(webhook_url: str, message_text: str) -> None:
    # Allow customizing the JSON field name to match Slack Workflow Webhook variables.
    # Defaults to 'text' (Incoming Webhooks). For Workflow Builder, set NOTIFY_SLACK_VARIABLE_NAME, e.g., 'Message'.
    variable_name = os.getenv("NOTIFY_SLACK_VARIABLE_NAME", "text")
    payload = {variable_name: message_text}
    data = json.dumps(payload).encode("utf-8")
    req = request.Request(webhook_url, data=data, headers={"Content-Type": "application/json"})
    with request.urlopen(req, timeout=10) as _:
        pass


def _send_email(subject: str, body: str) -> None:
    smtp_host = os.getenv("SMTP_HOST")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USERNAME")
    smtp_pass = os.getenv("SMTP_PASSWORD")
    use_tls = os.getenv("SMTP_USE_TLS", "true").lower() in ("1", "true", "yes", "y")

    email_from = os.getenv("NOTIFY_EMAIL_FROM")
    email_to = os.getenv("NOTIFY_EMAIL_TO")

    if not (smtp_host and email_from and email_to):
        return

    msg = EmailMessage()
    msg["From"] = email_from
    msg["To"] = email_to
    msg["Subject"] = subject
    msg.set_content(body)

    if use_tls:
        context = ssl.create_default_context()
        with smtplib.SMTP(smtp_host, smtp_port, timeout=15) as server:
            server.starttls(context=context)
            if smtp_user and smtp_pass:
                server.login(smtp_user, smtp_pass)
            server.send_message(msg)
    else:
        with smtplib.SMTP(smtp_host, smtp_port, timeout=15) as server:
            if smtp_user and smtp_pass:
                server.login(smtp_user, smtp_pass)
            server.send_message(msg)


def notify_status(summary: Dict[str, Any]) -> None:
    """
    Send notifications based on the provided summary dict produced by the pipeline.

    Expected keys:
      - status: "success" | "failure"
      - timestamp, config_path, exported_count, transformed_count, appended_rows, published_count
      - error (optional on failure)
    """
    # Opt-out flag
    if os.getenv("NOTIFY_ENABLED", "true").lower() in ("0", "false", "no"):
        return

    status = summary.get("status", "unknown")
    ts = summary.get("timestamp", "")
    cfg = summary.get("config_path", "")
    exported = summary.get("exported_count", 0)
    transformed = summary.get("transformed_count", 0)
    appended = summary.get("appended_rows", 0)
    published = summary.get("published_count", 0)
    error_msg = summary.get("error")

    if status == "success":
        title = "✅ Pipeline Success"
        text = (
            f"{title}\n"
            f"Time: {ts}\n"
            f"Config: {cfg}\n"
            f"Exported: {exported} | Transformed: {transformed} | Appended: {appended} | Published: {published}"
        )
    else:
        title = "❌ Pipeline Failure"
        text = (
            f"{title}\n"
            f"Time: {ts}\n"
            f"Config: {cfg}\n"
            f"Error: {error_msg}"
        )

    # Slack
    slack_url = os.getenv("NOTIFY_SLACK_WEBHOOK_URL")
    if slack_url:
        try:
            _post_slack(slack_url, text)
        except Exception:
            pass

    # Email
    try:
        _send_email(subject=title, body=text)
    except Exception:
        pass


