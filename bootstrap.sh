#!/usr/bin/env bash
# bootstrap.sh - Bootstrapper for Kali Linux dotfiles

set -euo pipefail

# Always run from repo root
cd "$(dirname "$(realpath "$0")")"

echo "[+] Starting bootstrap process..."

# 1. Run tools installation
chmod +x install-tools.sh
./install-tools.sh

# 2. Configure XFCE keybindings
chmod +x setup-xfce-keybinds.sh
./setup-xfce-keybinds.sh

# 3. Clean up conflicting config paths to prevent Stow conflicts
remove_if_real() {
  local path="$1"
  if [ -L "$path" ]; then
    echo "  - Removing existing symlink $path..."
    rm -rf "$path"
  elif [ -e "$path" ]; then
    echo "  - Backing up existing $path..."
    local backup_path="${path}.bak.$(date +%s)"
    mv "$path" "$backup_path" 2>/dev/null || rm -rf "$path"
  fi
}

echo "[+] Preparing directories for Stow..."
remove_if_real "$HOME/.config/alacritty"
remove_if_real "$HOME/.config/fish"
remove_if_real "$HOME/.config/nvim"
remove_if_real "$HOME/.config/starship.toml"
remove_if_real "$HOME/.config/tmux"
remove_if_real "$HOME/.config/i3"

if [ -e "/etc/keyd" ] && [ ! -L "/etc/keyd" ]; then
  echo "  - Backing up existing /etc/keyd..."
  sudo mv "/etc/keyd" "/etc/keyd.bak.$(date +%s)" 2>/dev/null || sudo rm -rf "/etc/keyd"
fi

# Ensure target directories exist
mkdir -p "$HOME/.config"

# 4. Stow system configurations (keyd)
echo "[+] Installing and stowing keyd system configuration..."
sudo stow -t / keyd
sudo systemctl enable --now keyd.service

# Enable Avahi daemon for mDNS resolution
echo "[+] Enabling Avahi daemon for mDNS resolution..."
sudo systemctl enable --now avahi-daemon

# 5. Stow user dotfiles
echo "[+] Stowing user configuration files..."
stow alacritty fish nvim starship tmux i3

# 6. Install TPM (Tmux Plugin Manager) if missing
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "[+] Installing Tmux Plugin Manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 7. Change default shell to Fish
if [ "${SHELL}" != "/usr/bin/fish" ]; then
  echo "[+] Changing default shell to Fish..."
  sudo chsh -s /usr/bin/fish "$(whoami)"
fi

echo ""
echo "[+] Bootstrap completed successfully!"
echo "[i] Please log out and log back in, or restart your machine to apply all changes."
echo "    After restarting, start tmux and press 'Prefix + I' (Ctrl+s followed by Shift+i) to load tmux plugins."
