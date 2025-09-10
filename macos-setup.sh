#!/bin/bash
# macos-setup.sh - Main script for macOS setup.

/# --- Configuration ---
LOG_FILE="$HOME/dotfiles-setup.log"
DOTFILES_DIR="$HOME/dotfiles"
BREWFILE_PATH="$(dirname "$0")/scripts/macos/Brewfile"
MACOS_DEFAULTS_SCRIPT="$DOTFILES_DIR/macos-defaults.sh"


# --- Source Scripts ---
source "$(dirname "$0")/scripts/utils.sh"
source "$(dirname "$0")/scripts/common/dotfiles.sh"
source "$(dirname "$0")/scripts/macos/homebrew.sh"
source "$(dirname "$0")/scripts/macos/macos-defaults.sh"
source "$(dirname "$0")/scripts/macos/sudoers.sh"

# --- Main ---
main() {
    header "Starting macOS setup"

    # Check for sudo privileges and keep sudo alive.
    header "Checking for administrator privileges"
    if ! sudo -v; then
        log "ERROR: Administrator privileges are required."
        exit 1
    fi
    # Keep-alive: update existing `sudo` time stamp until the script has finished.
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    log "Administrator privileges confirmed."
    
    # Install Xcode Command Line Tools (dependency for Homebrew)
    install_xcode_command_line_tools
    
    # Install Homebrew
    install_homebrew
    
    # Install Brewfile packages
    allow_brew_no_password
    install_brewfile_packages "$BREWFILE_PATH"
    revert_brew_no_password
    
    # Symlink dotfiles
    symlink_dotfiles "$DOTFILES_DIR"
    
    # Configure macOS defaults
    configure_macos_defaults "$MACOS_DEFAULTS_SCRIPT"
    
    log "macOS setup complete."
}

main "$@"
