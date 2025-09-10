#!/bin/bash
# scripts/macos/sudoers.sh - Manages sudoers configuration for passwordless Homebrew execution.

# Source utility functions
source "$(dirname "$0")/../utils.sh"

SUDOERS_FILE="/etc/sudoers.d/brew_passwordless"

# --- Allow Passwordless Brew ---
# Adds a sudoers rule to allow the admin group to run brew without a password.
allow_brew_no_password() {
    header "Temporarily allowing passwordless Homebrew execution"
    
    # Determine Homebrew prefix based on architecture
    if [[ "$(uname -m)" == "arm64" ]]; then
        HOMEBREW_PREFIX="/opt/homebrew"
    else
        HOMEBREW_PREFIX="/usr/local"
    fi
    
    local brew_path="${HOMEBREW_PREFIX}/bin/brew"
    
    # Create the sudoers file. This requires sudo.
    if ! sudo sh -c "echo '%admin ALL=(ALL) NOPASSWD: ${brew_path}' > '${SUDOERS_FILE}'"; then
        handle_error "Failed to create sudoers file for passwordless brew."
    fi
    
    log "Passwordless rule for Homebrew created at ${SUDOERS_FILE}"
}

# --- Revert Passwordless Brew ---
# Removes the sudoers rule file.
revert_brew_no_password() {
    header "Reverting passwordless Homebrew execution"
    
    if [ -f "${SUDOERS_FILE}" ]; then
        if ! sudo rm "${SUDOERS_FILE}"; then
            log "ERROR: Failed to remove sudoers file at ${SUDOERS_FILE}. Please remove it manually."
        else
            log "Successfully removed temporary sudoers file."
        fi
    else
        log "No temporary sudoers file found to remove."
    fi
}
