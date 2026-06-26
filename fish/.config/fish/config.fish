# --- Environment Variables ---
set -g fish_greeting
set -gx EDITOR nvim
set -gx XDG_CONFIG_HOME $HOME/.config

# --- Core Aliases ---
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git checkout"
alias gcc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias c="clear"
alias v="nvim"
alias ls="eza -l -g --icons"
alias lst="eza -g --icons --tree --level=2 -a"
alias t="tmux"
alias tks="tmux kill-server"
alias b="bash"

# --- Key Bindings ---
bind \cn open_nvim
bind \co open_lazygit
bind \cg edit_command 
bind \cs check_tmux
bind \ce edit_clipboard
bind \ct open_ws

# --- Auto-Install Fisher & Bass ---
if not functions -q fisher
    echo "[+] Installing fisher & bass..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    fisher install edc/bass
end

# --- Integrations ---
if command -v zoxide &>/dev/null
    zoxide init fish | source
end

if command -v starship &>/dev/null
    starship init fish | source
end

if test -d ~/.local/share/mise
    ~/.local/share/mise/bin/mise activate fish | source
end
