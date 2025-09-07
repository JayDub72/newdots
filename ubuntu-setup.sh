#!/bin/bash
# ubuntu-setup.sh - Main script for Ubuntu setup.

# --- Configuration ---
LOG_FILE="$HOME/dotfiles-setup.log"
DOTFILES_DIR="$HOME/dotfiles"
PACKAGES_FILE="$DOTFILES_DIR/ubuntu-packages.txt"

# --- Source Scripts ---
source "$(dirname "$0")/scripts/utils.sh"
source "$(dirname "$0")/scripts/common/dotfiles.sh"
source "$(dirname "$0")/scripts/ubuntu/apt.sh"

# --- Main ---
main() {
    header "Starting Ubuntu setup"
    
    # Install apt packages
    install_apt_packages "$PACKAGES_FILE"
    
    # Symlink dotfiles
    symlink_dotfiles "$DOTFILES_DIR"
    
    log "Ubuntu setup complete."
}

main "$@"
