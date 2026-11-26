#!/usr/bin/env bash
# Xcode Command Line Tools (needed for git, compilers, Homebrew).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  warn "Finish the Command Line Tools installer dialog, then re-run."
  exit 2
fi
echo "Installed at $(xcode-select -p)"
