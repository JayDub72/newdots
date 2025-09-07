#!/bin/bash
# scripts/macos/sudo-askpass.sh - A helper script for Homebrew to use for sudo authentication.
# It leverages the parent script's sudo keep-alive.

# This script will be called by `sudo -A`.
# If the user has a valid sudo timestamp, this will succeed.
# The parent script (`macos-setup.sh`) is responsible for keeping the sudo timestamp alive.
sudo -n true
