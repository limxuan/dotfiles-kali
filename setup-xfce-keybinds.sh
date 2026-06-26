#!/usr/bin/env bash
# setup-xfce-keybinds.sh - Set keyboard shortcuts for XFCE workspace switching

set -euo pipefail

echo "[+] Configuring XFCE Workspace keyboard shortcuts..."

# Ensure we have 4 workspaces
xfconf-query -c xfwm4 -p /general/workspace_count -n -t int -s 4 || true

# Bind Caps Lock + 1..4 (which maps to Control+Shift+Alt+1..4 via keyd) to Switch Workspace 1..4
# Note: Keyd 'C-S-A-1' emits <Control><Shift><Alt>1
for i in {1..4}; do
  echo "  - Mapping Ctrl+Shift+Alt+$i to Workspace $i"
  # Clean up default shortcut if it exists
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Control><Shift><Alt>$i" --reset &>/dev/null || true
  # Create custom shortcut mapping to workspace_i_key
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Control><Shift><Alt>$i" -n -t string -s "workspace_${i}_key"
done

# Restart xfwm4 to apply changes safely
if command -v xfwm4 --replace &>/dev/null; then
  echo "[+] Reloading XFCE Window Manager..."
  xfwm4 --replace --daemonize &>/dev/null || true
fi

echo "[+] XFCE keyboard shortcuts successfully configured!"
