#!/usr/bin/env bash
# install-tools.sh - Install system and custom tools for Kali Linux

set -euo pipefail

echo "[+] Updating apt repositories..."
sudo apt-get update

echo "[+] Installing standard developer utilities..."
sudo apt-get install -y \
  stow \
  git \
  tmux \
  fzf \
  ripgrep \
  zoxide \
  starship \
  keyd \
  eza \
  bat \
  xclip \
  curl \
  wget \
  neovim \
  alacritty \
  build-essential

# --- Install Sesh (Tmux Session Manager) ---
if ! command -v sesh &>/dev/null; then
  echo "[+] Installing sesh (Tmux session manager)..."
  # Fetch latest sesh release info and download
  SESH_VERSION=$(curl -s "https://api.github.com/repos/joshmedeski/sesh/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  echo "Found sesh version: v$SESH_VERSION"
  curl -sLo /tmp/sesh.tar.gz "https://github.com/joshmedeski/sesh/releases/download/v${SESH_VERSION}/sesh_${SESH_VERSION}_linux_amd64.tar.gz"
  tar -xzf /tmp/sesh.tar.gz -C /tmp
  sudo mv /tmp/sesh /usr/local/bin/sesh
  sudo chmod +x /usr/local/bin/sesh
  rm -f /tmp/sesh.tar.gz
  echo "[+] Sesh installed to /usr/local/bin/sesh"
else
  echo "[*] Sesh is already installed"
fi

# --- Install Obsidian ---
if ! command -v obsidian &>/dev/null; then
  echo "[+] Downloading and installing Obsidian (.deb)..."
  wget -O /tmp/obsidian.deb "https://releases.obsidian.md/download/resources/linux/deb"
  sudo apt-get install -y /tmp/obsidian.deb
  rm -f /tmp/obsidian.deb
  echo "[+] Obsidian installed"
else
  echo "[*] Obsidian is already installed"
fi

# --- Install Mise (Runtime manager) ---
if ! command -v mise &>/dev/null; then
  echo "[+] Installing mise (runtime manager)..."
  curl https://mise.jdx.dev/install.sh | sh
  echo "[+] Mise installed"
else
  echo "[*] Mise is already installed"
fi

echo "[+] System tools installation completed successfully!"
