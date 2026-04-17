#!/bin/sh
set -e

cp /app/openclaw.config.json /root/.openclaw/openclaw.json

if [ -n "$TELEGRAM_API_KEY" ]; then
  openclaw channels add --channel telegram --token "$TELEGRAM_API_KEY" || \
    echo "Warning: Telegram channel setup failed"
fi

exec openclaw gateway --allow-unconfigured
