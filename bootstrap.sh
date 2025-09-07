#!/bin/bash
# bootstrap.sh - Downloads and initiates the dotfiles setup.
# This script is meant to be run on a fresh system to kickstart the setup process.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
REPO_OWNER="JayDub72"
REPO_NAME="newdots"
BRANCH="main" # Or your default branch name
REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.zip"
TEMP_DIR="/tmp/${REPO_NAME}-setup"

# --- Helper Functions ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

header() {
    echo -e "\n--- $1 ---"
}

# --- Main Logic ---

# 1. Check for dependencies
header "Checking for dependencies (curl, unzip)"
if ! command -v curl &> /dev/null; then
    log "ERROR: curl is not installed. Please install it first."
    exit 1
fi
if ! command -v unzip &> /dev/null; then
    log "ERROR: unzip is not installed. Please install it first."
    exit 1
fi
log "Dependencies are satisfied."

# 2. Download the repository
header "Downloading repository"
# Clean up any previous temporary directories
if [ -d "$TEMP_DIR" ]; then
    log "Removing old temporary directory."
    rm -rf "$TEMP_DIR"
fi
mkdir -p "$TEMP_DIR"
log "Downloading from $REPO_URL..."
curl -L -o "${TEMP_DIR}/repo.zip" "$REPO_URL"
log "Download complete."

# 3. Extract the repository
header "Extracting repository"
unzip "${TEMP_DIR}/repo.zip" -d "$TEMP_DIR"
# The extracted folder will be named REPO_NAME-BRANCH
EXTRACTED_DIR="${TEMP_DIR}/${REPO_NAME}-${BRANCH}"
log "Extracted to ${EXTRACTED_DIR}"

# 4. Execute the main setup script
header "Executing main setup script"
if [ -f "${EXTRACTED_DIR}/setup.sh" ]; then
    log "Found setup.sh. Making it executable and running..."
    cd "${EXTRACTED_DIR}"
    chmod +x setup.sh
    ./setup.sh
    cd - > /dev/null
else
    log "ERROR: setup.sh not found in the repository."
    exit 1
fi

# 5. Cleanup
header "Cleaning up temporary files"
rm -rf "$TEMP_DIR"
log "Cleanup complete."

header "Bootstrap process finished successfully!"
