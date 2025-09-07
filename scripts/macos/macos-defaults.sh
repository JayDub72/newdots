#!/bin/bash
# scripts/macos/macos-defaults.sh - Configures macOS defaults.

# Source utility functions
source "$(dirname "$0")/../utils.sh"

# --- Configure macOS Defaults ---
configure_macos_defaults() {
    header "Configuring macOS defaults"
    
    local defaults_script="$1"
    
    if [ -f "$defaults_script" ]; then
        bash "$defaults_script" || handle_error "macOS defaults configuration failed."
        log "macOS defaults configured."
    else
        log "No macOS defaults script found at $defaults_script. Skipping."
    fi
}
