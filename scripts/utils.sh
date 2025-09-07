#!/bin/bash
# scripts/utils.sh - Shared utility functions for logging and setup.

# --- Logging ---
# Usage: log "Your message here"
log() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE"
}

# --- Header ---
# Usage: header "Your section title"
header() {
    local msg="$1"
    echo -e "\n--- $msg ---" | tee -a "$LOG_FILE"
}

# --- Error Handling ---
# Usage: handle_error "Description of what failed"
handle_error() {
    local msg="$1"
    log "ERROR: $msg"
    log "See $LOG_FILE for more details."
    exit 1
}
