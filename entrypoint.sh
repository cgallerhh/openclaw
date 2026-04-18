#!/bin/sh
set -e

# Write himalaya config for Gmail if credentials are provided
if [ -n "$GMAIL_USER" ] && [ -n "$GMAIL_APP_PASSWORD" ]; then
  mkdir -p /root/.config/himalaya
  cat > /root/.config/himalaya/config.toml <<TOML
[accounts.gmail]
email = "$GMAIL_USER"
display-name = "OpenClaw"
default = true

backend.type = "imap"
backend.host = "imap.gmail.com"
backend.port = 993
backend.encryption.type = "tls"
backend.login = "$GMAIL_USER"
backend.auth.type = "password"
backend.auth.raw = "$GMAIL_APP_PASSWORD"

message.send.backend.type = "smtp"
message.send.backend.host = "smtp.gmail.com"
message.send.backend.port = 587
message.send.backend.encryption.type = "start-tls"
message.send.backend.login = "$GMAIL_USER"
message.send.backend.auth.type = "password"
message.send.backend.auth.raw = "$GMAIL_APP_PASSWORD"
TOML
fi

node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('/app/openclaw.config.json', 'utf8'));

const telegramToken = process.env.TELEGRAM_API_KEY;
if (telegramToken) {
  config.channels = config.channels || {};
  config.channels.telegram = { enabled: true, botToken: telegramToken };
}

fs.writeFileSync('/root/.openclaw/openclaw.json', JSON.stringify(config, null, 2));
"

exec openclaw gateway --allow-unconfigured
