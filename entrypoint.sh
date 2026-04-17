#!/bin/sh
set -e

node -e "
const config = JSON.parse(require('fs').readFileSync('/app/openclaw.config.json', 'utf8'));
const token = process.env.TELEGRAM_API_KEY;
if (token) {
  config.channels = config.channels || {};
  config.channels.telegram = { enabled: true, botToken: token };
}
require('fs').writeFileSync('/root/.openclaw/openclaw.json', JSON.stringify(config, null, 2));
"

exec openclaw gateway --allow-unconfigured
