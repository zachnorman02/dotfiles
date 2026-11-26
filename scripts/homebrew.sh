#!/usr/bin/env bash
# Install Homebrew and add it to ~/.zprofile.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Homebrew"
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  need_sudo
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
grep -q "brew shellenv" "$HOME/.zprofile" 2>/dev/null \
  || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
brew_env
brew --version | head -1
