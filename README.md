# openclaw

OpenClaw Gateway deployed on Hetzner via Docker + GitHub Actions CI/CD.

## Flow

```
Mac: git push → GitHub Actions → SSH → Hetzner VPS → docker compose up -d --build
```

## Server Setup (einmalig als root)

```bash
ssh root@DEINE-SERVER-IP
bash <(curl -fsSL https://raw.githubusercontent.com/cgallerhh/openclaw/main/setup-server.sh)
```

Das Skript:
- Installiert Docker
- Legt User `openclaw` an
- Generiert SSH-Key für GitHub Actions
- Klont dieses Repository
- Erstellt `.env` Datei

## GitHub Secrets einrichten

| Secret | Wert |
|---|---|
| `HETZNER_HOST` | IP-Adresse des Hetzner Servers |
| `HETZNER_SSH_KEY` | Private Key aus `setup-server.sh` Output |
| `ANTHROPIC_API_KEY` | Dein Anthropic API Key |

## Manueller Start

```bash
ssh openclaw@DEINE-SERVER-IP
cd ~/openclaw
cp .env.example .env   # API Key eintragen
docker compose up -d
docker compose logs -f
```

## Gateway

OpenClaw läuft auf `127.0.0.1:18789` (nur lokal, kein öffentlicher Zugriff ohne Nginx/TLS).
