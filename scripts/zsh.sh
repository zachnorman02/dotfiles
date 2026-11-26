#!/usr/bin/env bash
# zsh options.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "zsh options"
touch "$HOME/.zshrc"
grep -qxF "setopt interactivecomments" "$HOME/.zshrc" || echo "setopt interactivecomments" >> "$HOME/.zshrc"
echo "ok"
