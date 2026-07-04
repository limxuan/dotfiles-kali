#!/usr/bin/env bash
# setup-xfce-keybinds.sh - Set keyboard shortcuts for XFCE workspace switching

set -euo pipefail

echo "[+] Configuring XFCE Workspace keyboard shortcuts..."

# Ensure we have 6 workspaces
xfconf-query -c xfwm4 -p /general/workspace_count -n -t int -s 6 || true

# Bind keys for workspaces 1..6:
# 1. Switch Workspace shortcut: Ctrl + Alt + 1..6 (Primary+Alt+1..6)
#    (This is triggered by both physical Ctrl+Alt+1..6 and Caps+1..6 since Caps maps to C-A-1..6)
# 2. Move active window to Workspace: Alt + Shift + 1..6
# Shift symbols for numbers 1..6 on a standard US keyboard
symbols=("exclam" "at" "numbersign" "dollar" "percent" "asciicircum")

for i in {1..6}; do
  echo "  - Mapping Workspace $i shortcuts (Switch & Move)"
  sym=${symbols[$((i-1))]}
  
  # Clear old conflicting custom Ctrl+Alt+1..6 shortcuts if they exist
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>$i" --reset &>/dev/null || true
  
  # Switch Workspace shortcut (Ctrl + Alt + Shift + 1..6, triggered by physical keys and Caps+1..6 via keyd)
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Shift><Alt>$i" --reset &>/dev/null || true
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Shift><Alt>$i" -n -t string -s "workspace_${i}_key"
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt><Shift>$i" --reset &>/dev/null || true
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt><Shift>$i" -n -t string -s "workspace_${i}_key"
  
  # Move Window to Workspace shortcut (Alt + Shift + 1..6)
  # Map both the numbers and their shifted symbols to ensure compatibility
  for key in "$i" "$sym"; do
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>$key" --reset &>/dev/null || true
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>$key" -n -t string -s "move_window_workspace_${i}_key"
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Shift><Alt>$key" --reset &>/dev/null || true
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Shift><Alt>$key" -n -t string -s "move_window_workspace_${i}_key"
  done
done

# Restart xfwm4 to apply changes safely
if command -v xfwm4 --replace &>/dev/null; then
  echo "[+] Reloading XFCE Window Manager..."
  xfwm4 --replace --daemonize &>/dev/null || true
fi

echo "[+] XFCE keyboard shortcuts successfully configured!"
