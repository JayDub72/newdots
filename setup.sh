#!/bin/zsh
# setup.sh - OS detection and dispatcher
# Author: [Your Name]
# Description: Detects OS and calls the appropriate setup script for macOS or Ubuntu.

set -e

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f "/etc/os-release" ]] && grep -qi ubuntu /etc/os-release; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

OS_TYPE=$(detect_os)
if [[ "$OS_TYPE" == "macos" ]]; then
    echo "🫆 Detected macOS. Running MacOS setup..."
    zsh "$(dirname "$0")/macos-setup.sh"
elif [[ "$OS_TYPE" == "ubuntu" ]]; then
    echo "Detected Ubuntu. Running Ubuntu setup..."
    bash "$(dirname "$0")/ubuntu-setup.sh"
else
    echo "❌ Unsupported OS. This script supports macOS and Ubuntu only."
    exit 1
fi