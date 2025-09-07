#!/bin/bash
# scripts/common/dotfiles.sh - Manages dotfile symlinking.

# Source utility functions
source "$(dirname "$0")/../utils.sh"

# --- Symlink Dotfiles ---
# Creates symlinks for all files in the dotfiles directory.
symlink_dotfiles() {
    header "Symlinking dotfiles"
    
    local dotfiles_dir="$1"
    
    # Find all files in the dotfiles directory (excluding this script)
    find "$dotfiles_dir" -maxdepth 1 -type f -name ".*" | while read -r file; do
        local filename
        filename=$(basename "$file")
        local symlink_path="$HOME/$filename"
        
        # If a symlink already exists, remove it
        if [ -L "$symlink_path" ]; then
            rm "$symlink_path"
        fi
        
        # Create the symlink
        ln -s "$file" "$symlink_path"
        log "Symlinked $filename to $symlink_path"
    done
    
    log "Dotfile symlinking complete."
}
