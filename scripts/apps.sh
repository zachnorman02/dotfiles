#!/usr/bin/env bash
# Install everything in the Brewfile.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
brew_env

log "brew bundle"
brew bundle --file="$DOTFILES_DIR/Brewfile" \
  || warn "Some Brewfile entries failed. Casks for apps already in /Applications need Terminal in Privacy & Security > App Management."
