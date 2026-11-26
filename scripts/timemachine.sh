#!/usr/bin/env bash
# Exclude big, re-downloadable model caches from Time Machine.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Time Machine exclusions"
for d in "$HOME/.lmstudio" "$HOME/.ollama" "$HOME/.cache/huggingface" "$HOME/ml/.venv"; do
  mkdir -p "$d"
  tmutil addexclusion "$d" 2>/dev/null || true
done
tmutil isexcluded "$HOME/.lmstudio" "$HOME/.ollama" "$HOME/.cache/huggingface" "$HOME/ml/.venv" || true
