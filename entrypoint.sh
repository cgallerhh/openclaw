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

# Write Google OAuth credentials if provided
if [ -n "$GOOGLE_CLIENT_ID" ] && [ -n "$GOOGLE_CLIENT_SECRET" ] && [ -n "$GOOGLE_REFRESH_TOKEN" ]; then
  mkdir -p /root/.openclaw
  cat > /root/.openclaw/google-credentials.json <<GCREDS
{
  "client_id": "$GOOGLE_CLIENT_ID",
  "client_secret": "$GOOGLE_CLIENT_SECRET",
  "refresh_token": "$GOOGLE_REFRESH_TOKEN",
  "token_uri": "https://oauth2.googleapis.com/token"
}
GCREDS
fi

# Write user context (location, timezone) for the agent system prompt
mkdir -p /root/.openclaw/workspace
cat > /root/.openclaw/workspace/user.md <<'MD'
# User Context

- Location: Hamburg, Germany
- Timezone: Europe/Berlin (CET/CEST)

When the user asks about weather, news, sports, or anything location-specific without specifying a place, default to Hamburg, Germany.
MD

exec openclaw gateway --allow-unconfigured
