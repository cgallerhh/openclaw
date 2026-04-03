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
ANTHROPIC_API_KEY=sk-ant-...
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
| `ANTHROPIC_API_KEY` | Anthropic API Key |
| `TELEGRAM_API_KEY` | Telegram Bot Token (@penclaw_ChG_BOT) |
| `TELEGRAM_CHAT_ID` | Deine Telegram User ID |

## Docker Befehle

```bash
docker compose ps          # Status
docker compose logs -f     # Live-Logs
docker compose restart     # Neustart
docker compose up -d --build  # Nach Code-Änderungen
```

## Gateway

Läuft auf `ws://127.0.0.1:18789` mit `claude-opus-4-6`.

## Bot

Telegram: @penclaw_ChG_BOT
Morgen-Briefing: täglich 6:30 Uhr (Hamburger Zeit) mit Wetter, Kalender, Tagesschau.
# Test Fr.  3 Apr. 2026 20:32:00 CEST
