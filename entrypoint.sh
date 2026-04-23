#!/bin/sh
set -e

# Google Workspace plugin credentials (Gmail, Calendar, Drive, ...)
if [ -n "$GOOGLE_CLIENT_ID" ] && [ -n "$GOOGLE_CLIENT_SECRET" ] && [ -n "$GOOGLE_REFRESH_TOKEN" ]; then
  mkdir -p /root/.openclaw/secrets
  chmod 700 /root/.openclaw/secrets
  cat > /root/.openclaw/secrets/google-oauth.json <<JSON
{
  "installed": {
    "client_id": "$GOOGLE_CLIENT_ID",
    "client_secret": "$GOOGLE_CLIENT_SECRET",
    "redirect_uris": ["http://localhost"]
  }
}
JSON
  cat > /root/.openclaw/secrets/google-tokens.json <<JSON
{
  "refresh_token": "$GOOGLE_REFRESH_TOKEN",
  "token_type": "Bearer",
  "scope": "https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/gmail.modify"
}
JSON
  chmod 600 /root/.openclaw/secrets/google-oauth.json /root/.openclaw/secrets/google-tokens.json
fi

node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('/app/openclaw.config.json', 'utf8'));

const model = process.env.OPENCLAW_MODEL;
if (model) {
  config.agents = config.agents || {};
  config.agents.defaults = config.agents.defaults || {};
  config.agents.defaults.model = config.agents.defaults.model || {};
  config.agents.defaults.model.primary = model;
}

const webSearchEnabled = process.env.OPENCLAW_WEB_SEARCH_ENABLED;
if (webSearchEnabled) {
  config.tools = config.tools || {};
  config.tools.web = config.tools.web || {};
  config.tools.web.search = config.tools.web.search || {};
  config.tools.web.search.enabled = webSearchEnabled === 'true';
}

const telegramToken = process.env.TELEGRAM_API_KEY;
if (telegramToken) {
  config.channels = config.channels || {};
  config.channels.telegram = { enabled: true, botToken: telegramToken };
}

fs.writeFileSync('/root/.openclaw/openclaw.json', JSON.stringify(config, null, 2));
"

# Write user context (location, timezone) for the agent system prompt
mkdir -p /root/.openclaw/workspace
cat > /root/.openclaw/workspace/user.md <<'MD'
# User Context

- Location: Hamburg, Germany
- Timezone: Europe/Berlin (CET/CEST)

When the user asks about weather, news, sports, or anything location-specific without specifying a place, default to Hamburg, Germany.
MD

exec openclaw gateway --allow-unconfigured
