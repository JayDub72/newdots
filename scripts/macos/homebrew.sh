#!/bin/bash
# scripts/macos/homebrew.sh - Manages Homebrew installation and packages.

# Source utility functions
source "$(dirname "$0")/../utils.sh"

# --- Install Xcode Command Line Tools ---
install_xcode_command_line_tools() {
    header "Checking for Xcode Command Line Tools"
    
    if ! xcode-select -p &> /dev/null; then
        log "Xcode Command Line Tools not found. Installing..."
        xcode-select --install
        
        # Wait until the Xcode Command Line Tools are installed
        log "Waiting for Xcode Command Line Tools installation to complete..."
        until xcode-select -p &> /dev/null; do
            sleep 5
            log "Still waiting for installation..."
        done
        
        log "Xcode Command Line Tools installed."
    else
        log "Xcode Command Line Tools are already installed."
    fi
}

# --- Install Homebrew ---
install_homebrew() {
    header "Installing Homebrew"
    
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        log "Homebrew installed."
    else
        log "Homebrew is already installed."
    fi
}

# --- Install Brewfile Packages ---
install_brewfile_packages() {
    header "Installing Brewfile packages"
    
    local brewfile_path="$1"
    
    if [ -f "$brewfile_path" ]; then
        brew bundle --file="$brewfile_path" || handle_error "Brewfile installation failed."
        log "Brewfile packages installed."
    else
        log "No Brewfile found at $brewfile_path. Skipping."
    fi
}
