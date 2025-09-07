#!/bin/bash
# ubuntu-setup.sh - Ubuntu specific setup script
set -e
LOG_FILE="setup.log"
DOTFILES_REPO="https://github.com/JayDub72/newdots/newdots.git"
DOTFILES_DIR="$HOME/.dotfiles"

log() {
    echo "$[$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE"
}

header() {
    echo "\n ==== $msg ====\n" | tee -a "$LOG_FILE"
}

header "🛠️ Checking Ubuntu prerequisites"
if ! command -v git &>/dev/null; then
    log "git not found. Installing..."
    if sudo apt-get update && sudo apt-get install -y git 2>&1 | tee -a "$LOG_FILE"; then
        log "git installed."
    else
        log "❌ git installation failed. Check output above for troubleshooting."
        exit 1
    fi
else
    log "git already installed."
fi

# 0. Pull latest dotfiles from GitHub
header "Syncing dotfiles from GitHub"
if [ -d "$DOTFILES_DIR/.git" ]; then
    log "Dotfiles repo exists. Pulling latest changes..."
    if ! git -C "$DOTFILES_DIR" pull 2>&1 | tee -a "$LOG_FILE"; then
        log "❌ Failed to pull latest dotfiles. Please check your git configuration and network."
    fi
else
    log "Cloning dotfiles repo..."
    if ! git clone "$DOTFILES_REPO" "$DOTFILES_DIR" 2>&1 | tee -a "$LOG_FILE"; then
        log "❌ Failed to clone dotfiles repo. Please check your git configuration and network."
        exit 1
    fi
fi

# 1. Ensure template files exist
header "Ensuring template files exist"
# .zshrc template
if [ ! -f "$DOTFILES_DIR/.zshrc" ]; then
    log "Creating .zshrc template."
    cat <<EOF > "$DOTFILES_DIR/.zshrc"
# .zshrc template
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh
EOF
fi

# Ubuntu install script template
if [ ! -f "$DOTFILES_DIR/ubuntu-packages.txt" ]; then
    log "Creating ubuntu-packages.txt template."
    echo "curl\nwget\ngit\nzsh" > "$DOTFILES_DIR/ubuntu-packages.txt"
fi

# 2. Dotfiles setup
header "Setting up dotfiles"
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    if ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" 2>&1 | tee -a "$LOG_FILE"; then
        log "Symlinked .zshrc"
    else
        log "❌ Failed to symlink .zshrc. Check permissions."
    fi
else
    log ".zshrc not found in dotfiles directory. Skipping symlink."
fi

# 3. Install packages from ubuntu-packages.txt
header "Installing Ubuntu packages"
if [ -f "$DOTFILES_DIR/ubuntu-packages.txt" ]; then
    while read -r pkg; do
        log "Installing $pkg..."
        if sudo apt-get install -y "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            log "$pkg installed."
        else
            log "❌ Failed to install $pkg. Check output above for troubleshooting."
        fi
    done < "$DOTFILES_DIR/ubuntu-packages.txt"
else
    log "No ubuntu-packages.txt found in $DOTFILES_DIR. Skipping package install."
fi

header "Setup complete!"
log "All steps finished. Review $LOG_FILE for details."
