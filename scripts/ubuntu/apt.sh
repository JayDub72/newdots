#!/bin/bash
# scripts/ubuntu/apt.sh - Manages apt packages for Ubuntu.

# Source utility functions
source "$(dirname "$0")/../utils.sh"

# --- Install Apt Packages ---
install_apt_packages() {
    header "Installing apt packages"
    
    local packages_file="$1"
    
    if [ -f "$packages_file" ]; then
        sudo apt-get update
        xargs -a "$packages_file" sudo apt-get install -y || handle_error "apt package installation failed."
        log "apt packages installed."
    else
        log "No packages file found at $packages_file. Skipping."
    fi
}
