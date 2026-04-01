#!/bin/bash
# OpenClaw Hetzner Server Setup Script
# Run once as root: bash setup-server.sh

set -e

echo "=== OpenClaw Server Setup ==="

# 1. Install Docker
echo "[1/5] Installing Docker..."
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

# 2. Create deploy user
echo "[2/5] Creating deploy user 'openclaw'..."
if ! id -u openclaw &>/dev/null; then
  adduser --disabled-password --gecos "" openclaw
fi
usermod -aG docker openclaw

# 3. Set up SSH key for GitHub Actions
echo "[3/5] Setting up SSH key for GitHub Actions..."
su - openclaw -c "
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  ssh-keygen -t ed25519 -C 'github-actions-deploy' -f ~/.ssh/github_actions -N '' -q
  cat ~/.ssh/github_actions.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
"

# 4. Clone the repository
echo "[4/5] Cloning openclaw repository..."
su - openclaw -c "
  git clone https://github.com/cgallerhh/openclaw.git ~/openclaw
"

# 5. Create .env file
echo "[5/5] Creating .env file (you must fill in ANTHROPIC_API_KEY)..."
su - openclaw -c "
  echo 'ANTHROPIC_API_KEY=sk-ant-REPLACE_ME' > ~/openclaw/.env
  chmod 600 ~/openclaw/.env
"

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Next steps:"
echo "  1. Fill in your Anthropic API key:"
echo "     nano /home/openclaw/openclaw/.env"
echo ""
echo "  2. Copy the PRIVATE key below to GitHub Secrets as HETZNER_SSH_KEY:"
echo ""
cat /home/openclaw/.ssh/github_actions
echo ""
echo "  3. Add your server IP to GitHub Secrets as HETZNER_HOST"
echo ""
echo "  4. Start OpenClaw:"
echo "     su - openclaw -c 'cd ~/openclaw && docker compose up -d'"
