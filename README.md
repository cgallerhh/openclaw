# openclaw

OpenClaw Gateway auf Hetzner, deployed via Docker + GitHub Actions CI/CD.

## Flow

```
Mac: git push → GitHub Actions → SSH → Hetzner VPS → docker compose up -d --build
```

## Einmaliges Server-Setup

```bash
ssh root@89.167.14.159
git clone https://github.com/cgallerhh/openclaw.git /home/user/openclaw
cd /home/user/openclaw
git checkout main
```

`.env` anlegen:
```bash
nano .env
```
```
OPENAI_API_KEY=sk-...
TELEGRAM_API_KEY=<bot-token von @penclaw_ChG_BOT>
TELEGRAM_CHAT_ID=<deine-telegram-id>
```

Starten:
```bash
docker compose up -d --build
```

Telegram-Bot verbinden:
```bash
docker exec -it openclaw-openclaw-1 sh -c 'openclaw channels add --channel telegram --token "$TELEGRAM_API_KEY"'
```

## GitHub Secrets

| Secret | Wert |
|---|---|
| `HETZNER_HOST` | `89.167.14.159` |
| `HETZNER_SSH_KEY` | Private Key (`/root/.ssh/github_actions`) |
| `OPENAI_API_KEY` | OpenAI API Key |
| `TELEGRAM_API_KEY` | Telegram Bot Token (@penclaw_ChG_BOT) |
| `TELEGRAM_CHAT_ID` | Deine Telegram User ID |

## MCP-Integration (Claude Code / Claude Desktop)

Der `mcp-bridge` Service läuft auf `http://127.0.0.1:3000` und stellt openclaw als MCP-Server bereit.

**Claude Code** (`.claude/mcp.json` oder via `claude mcp add`):
```json
{
  "mcpServers": {
    "openclaw": {
      "type": "sse",
      "url": "http://127.0.0.1:3000/sse"
    }
  }
}
```

**Claude Desktop** (`claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "openclaw": {
      "type": "sse",
      "url": "http://127.0.0.1:3000/sse"
    }
  }
}
```

> Der MCP-Bridge-Port ist nur lokal erreichbar (`127.0.0.1:3000`). Für Remotezugriff SSH-Tunnel nutzen: `ssh -L 3000:127.0.0.1:3000 root@89.167.14.159`

## Docker Befehle

```bash
docker compose ps          # Status
docker compose logs -f     # Live-Logs
docker compose restart     # Neustart
docker compose up -d --build  # Nach Code-Änderungen
```

## Gateway

Läuft auf `ws://127.0.0.1:18789` mit `gpt-4o-mini`.

## Bot

Telegram: @penclaw_ChG_BOT
Morgen-Briefing: täglich 6:30 Uhr (Hamburger Zeit) mit Wetter, Kalender, Tagesschau.
# Test Fr.  3 Apr. 2026 20:32:00 CEST
