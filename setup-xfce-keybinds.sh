#!/usr/bin/env bash
# setup-xfce-keybinds.sh - Set keyboard shortcuts for XFCE workspace switching

set -euo pipefail

echo "[+] Configuring XFCE Workspace keyboard shortcuts..."

# Ensure we have 6 workspaces
xfconf-query -c xfwm4 -p /general/workspace_count -n -t int -s 6 || true

# Bind keys for workspaces 1..6:
# 1. Caps Lock + 1..6 (maps to Primary+Shift+Alt+1..6 via keyd) to Switch Workspace
# 2. Ctrl + Alt + 1..6 (Primary+Alt+1..6) as a troubleshooting fallback to Switch Workspace (bypasses keyd)
# 3. Alt + Shift + 1..6 to Move active window to Workspace
for i in {1..6}; do
  echo "  - Mapping Workspace $i shortcuts (Switch & Move)"
  
  # Switch Workspace shortcut (Caps Lock + 1..6 -> Ctrl+Shift+Alt+1..6)
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Shift><Alt>$i" --reset &>/dev/null || true
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Shift><Alt>$i" -n -t string -s "workspace_${i}_key"
  
  # Switch Workspace shortcut (Ctrl + Alt + 1..6 fallback)
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>$i" --reset &>/dev/null || true
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>$i" -n -t string -s "workspace_${i}_key"
  
  # Move Window to Workspace shortcut (Alt + Shift + 1..6)
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>$i" --reset &>/dev/null || true
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>$i" -n -t string -s "move_window_workspace_${i}_key"
done

# Restart xfwm4 to apply changes safely
if command -v xfwm4 --replace &>/dev/null; then
  echo "[+] Reloading XFCE Window Manager..."
  xfwm4 --replace --daemonize &>/dev/null || true
fi

echo "[+] XFCE keyboard shortcuts successfully configured!"
