#!/usr/bin/env bash
# Run Ollama as a background service.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
brew_env

log "Ollama service"
brew services start ollama >/dev/null 2>&1 || warn "Could not start Ollama service."
brew services list | grep ollama || true
