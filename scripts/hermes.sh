#!/usr/bin/env bash
# Hermes Agent (Nous Research) — self-hosted AI agent; command-line install, data in ~/.hermes.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Hermes Agent"
if command -v hermes >/dev/null 2>&1; then
  echo "Already installed: $(hermes --version 2>/dev/null || echo hermes)"
  echo "Update with the same installer, or see: hermes --help"
  exit 0
fi

# Official installer (sets up its own Python env; no prerequisites beyond git).
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

echo
echo "Next:"
echo "  source ~/.zshrc        # pick up the hermes command"
echo "  hermes model           # choose a provider: OpenRouter, or a custom OpenAI endpoint"
echo "                         #   LM Studio local: http://localhost:1234/v1"
echo "  hermes doctor          # verify the setup"
echo "  hermes desktop         # optional desktop app"
