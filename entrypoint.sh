#!/bin/sh
set -e

cp /app/openclaw.config.json /root/.openclaw/config.json

# Start gateway in background, wait for it, then configure Telegram
openclaw gateway --allow-unconfigured &
GATEWAY_PID=$!

if [ -n "$TELEGRAM_API_KEY" ]; then
  sleep 5
  openclaw channels add --channel telegram --token "$TELEGRAM_API_KEY" \
    || echo "Warning: Telegram channel setup failed"
fi

wait $GATEWAY_PID
