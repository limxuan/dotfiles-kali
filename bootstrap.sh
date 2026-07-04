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
remove_if_real "$HOME/.config/kitty"

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
stow alacritty fish kitty nvim starship tmux

# 6. Install TPM (Tmux Plugin Manager) if missing
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "[+] Installing Tmux Plugin Manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 7. Change default shell to Fish safely
FISH_PATH=$(which fish 2>/dev/null || echo "/usr/bin/fish")
if [ -f "$FISH_PATH" ]; then
  # Ensure the path is in /etc/shells to prevent SSH/PAM login rejection
  if ! grep -qxF "$FISH_PATH" /etc/shells; then
    echo "[+] Adding $FISH_PATH to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
  fi
  
  # Also ensure /bin/fish is added if it exists and is different
  if [ "$FISH_PATH" = "/usr/bin/fish" ] && [ -f "/bin/fish" ] && ! grep -qxF "/bin/fish" /etc/shells; then
    echo "/bin/fish" | sudo tee -a /etc/shells > /dev/null
  fi

  CURRENT_SHELL=$(getent passwd "$(whoami)" | cut -d: -f7)
  if [ "$CURRENT_SHELL" != "$FISH_PATH" ]; then
    echo "[+] Changing default shell to $FISH_PATH..."
    sudo chsh -s "$FISH_PATH" "$(whoami)"
  fi
else
  echo "[!] Fish shell not found, skipping shell change."
fi


# 8. Setup SSH authorized keys
echo "[+] Configuring SSH authorized keys..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxkC9AWoLNhjeaDXB/pE7iK1cYrpyfMds8r0OAbesFT"
if ! grep -qF "$SSH_KEY" "$HOME/.ssh/authorized_keys"; then
  echo "$SSH_KEY" >> "$HOME/.ssh/authorized_keys"
  echo "  - Added public key to authorized_keys"
fi

echo ""
echo "[+] Bootstrap completed successfully!"
echo "[i] Please log out and log back in, or restart your machine to apply all changes."
echo "    After restarting, start tmux and press 'Prefix + I' (Ctrl+s followed by Shift+i) to load tmux plugins."

