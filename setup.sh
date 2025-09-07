#!/bin/zsh
# setup.sh - Automate Mac setup for Sonoma on Apple Silicon (M4)
# Author: [Your Name]
# Description: Sets up dotfiles, installs Homebrew packages, Mac App Store apps, and configures macOS defaults.


set -e
LOG_FILE="setup.log"
DOTFILES_REPO="https://github.com/JayDub72/newdots/newdots.git"
DOTFILES_DIR="$HOME/.dotfiles"

log() {
    # Add emoji based on message content
    local msg="$1"
    local emoji=""
    case "$msg" in
        *"not found"*) emoji="❌";;
        *"Installing"*) emoji="⬇️";;
        *"installed"*) emoji="✅";;
        *"Pulling"*) emoji="🔄";;
        *"Cloning"*) emoji="📥";;
        *"Symlinked"*) emoji="🔗";;
        *"template"*) emoji="📝";;
        *"complete"*) emoji="🎉";;
        *"Waiting"*) emoji="⏳";;
        *"Running"*) emoji="⚙️";;
        *"Skipping"*) emoji="⏭️";;
        *"App Store app"*) emoji="🛒";;
        *"Homebrew"*) emoji="🍺";;
        *"macOS defaults"*) emoji="💻";;
        *) emoji="📢";;
    esac
    echo "$emoji [$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE"
}

header() {
    # Add emoji to section headers
    local msg="$1"
    local emoji=""
    case "$msg" in
        *"Xcode"*) emoji="🛠️";;
        *"dotfiles"*) emoji="📁";;
        *"GitHub"*) emoji="🌐";;
        *"template"*) emoji="📝";;
        *"Homebrew"*) emoji="🍺";;
        *"App Store"*) emoji="🛒";;
        *"macOS defaults"*) emoji="🖥️";;
        *"Setup complete"*) emoji="🎉";;
        *) emoji="📢";;
    esac
    echo "\n$emoji ==== $msg ====\n" | tee -a "$LOG_FILE"
}

# -1. Install Xcode Command Line Tools (for git, gcc, etc.)
header "Checking Xcode Command Line Tools (git prerequisite)"
if ! xcode-select -p &>/dev/null; then
    log "Xcode Command Line Tools not found. Installing..."
    xcode-select --install
    log "Waiting for Xcode Command Line Tools installation to complete..."
    until xcode-select -p &>/dev/null; do
        sleep 5
        log "Still waiting for installation..."
    done
    log "Xcode Command Line Tools installation detected."
    echo "\n🔔 Please confirm the installation is complete and press Enter to continue."
    read -r _
else
    log "Xcode Command Line Tools already installed."
fi

# 0. Pull latest dotfiles from GitHub
header "Syncing dotfiles from GitHub"
if [ -d "$DOTFILES_DIR/.git" ]; then
    log "Dotfiles repo exists. Pulling latest changes..."
    git -C "$DOTFILES_DIR" pull
else
    log "Cloning dotfiles repo..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
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
# Brewfile template
if [ ! -f "$DOTFILES_DIR/Brewfile" ]; then
    log "Creating Brewfile template."
    cat <<EOF > "$DOTFILES_DIR/Brewfile"
tap "homebrew/cask"
brew "git"
brew "zsh"
cask "google-chrome"
EOF
fi
# mas-apps.txt template
if [ ! -f "$DOTFILES_DIR/mas-apps.txt" ]; then
    log "Creating mas-apps.txt template."
    echo "497799835" > "$DOTFILES_DIR/mas-apps.txt" # Example: Xcode
fi
# macos-defaults.sh template
if [ ! -f "$DOTFILES_DIR/macos-defaults.sh" ]; then
    log "Creating macos-defaults.sh template."
    cat <<EOF > "$DOTFILES_DIR/macos-defaults.sh"
#!/bin/zsh
# macOS defaults template
defaults write com.apple.finder AppleShowAllFiles -bool true
killall Finder
EOF
    chmod +x "$DOTFILES_DIR/macos-defaults.sh"
fi

# 2. Dotfiles setup
header "Setting up dotfiles"
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    log "Symlinked .zshrc"
else
    log ".zshrc not found in dotfiles directory. Skipping symlink."
fi

# 3. Homebrew & Brewfile
header "Installing Homebrew and Brewfile packages"
if ! command -v brew &>/dev/null; then
    log "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log "Homebrew installed."
else
    log "Homebrew already installed."
fi

if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    log "Installing Brewfile packages..."
    brew bundle --file="$DOTFILES_DIR/Brewfile" | tee -a "$LOG_FILE"
else
    log "No Brewfile found in $DOTFILES_DIR. Skipping Brewfile install."
fi

# 4. Mac App Store apps (requires mas-cli)
header "Installing Mac App Store apps"
if ! command -v mas &>/dev/null; then
    log "mas-cli not found. Installing via Homebrew..."
    brew install mas
fi
if [ -f "$DOTFILES_DIR/mas-apps.txt" ]; then
    while read -r app_id; do
        if [[ "$app_id" =~ ^[0-9]+$ ]]; then
            log "Installing App Store app: $app_id"
            mas install "$app_id" | tee -a "$LOG_FILE"
        fi
    done < "$DOTFILES_DIR/mas-apps.txt"
else
    log "No mas-apps.txt found in $DOTFILES_DIR. Skipping App Store installs."
fi

# 5. macOS defaults
header "Configuring macOS defaults"
if [ -f "$DOTFILES_DIR/macos-defaults.sh" ]; then
    log "Running macOS defaults script..."
    zsh "$DOTFILES_DIR/macos-defaults.sh" | tee -a "$LOG_FILE"
else
    log "No macos-defaults.sh found in $DOTFILES_DIR. Skipping macOS defaults."
fi

header "Setup complete!"
log "All steps finished. Review $LOG_FILE for details."