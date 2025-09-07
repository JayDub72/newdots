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

# --- Main ---
main() {
    header "Starting macOS setup"
    
    # Install Xcode Command Line Tools (dependency for Homebrew)
    install_xcode_command_line_tools
    
    # Install Homebrew
    install_homebrew
    
    # Install Brewfile packages
    install_brewfile_packages "$BREWFILE_PATH"
    
    # Symlink dotfiles
    symlink_dotfiles "$DOTFILES_DIR"
    
    # Configure macOS defaults
    configure_macos_defaults "$MACOS_DEFAULTS_SCRIPT"
    
    log "macOS setup complete."
}

main "$@"
