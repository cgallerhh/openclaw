#!/bin/sh
set -e

# Write gogcli credentials if provided (needed for Gmail Pub/Sub watch)
if [ -n "$GOGCLI_CREDENTIALS_JSON" ]; then
  mkdir -p /root/.config/gogcli
  printf '%s' "$GOGCLI_CREDENTIALS_JSON" > /root/.config/gogcli/credentials.json
fi

node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('/app/openclaw.config.json', 'utf8'));

const telegramToken = process.env.TELEGRAM_API_KEY;
if (telegramToken) {
  config.channels = config.channels || {};
  config.channels.telegram = { enabled: true, botToken: telegramToken };
}

const gmailAccount  = process.env.GMAIL_ACCOUNT;
const gmailTopic    = process.env.GMAIL_TOPIC;
const gmailPushToken = process.env.GMAIL_PUSH_TOKEN;
const gmailHookToken = process.env.GMAIL_HOOK_TOKEN;
if (gmailAccount && gmailTopic && gmailPushToken && gmailHookToken) {
  config.hooks = config.hooks || {};
  config.hooks.token = gmailHookToken;
  config.hooks.gmail = {
    account: gmailAccount,
    topic: gmailTopic,
    subscription: process.env.GMAIL_SUBSCRIPTION || 'gog-gmail-watch-push',
    pushToken: gmailPushToken,
    includeBody: true,
    serve: { bind: '0.0.0.0', port: 8788, path: '/gmail-pubsub' }
  };
}

fs.writeFileSync('/root/.openclaw/openclaw.json', JSON.stringify(config, null, 2));
"

exec openclaw gateway --allow-unconfigured
