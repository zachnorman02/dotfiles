#!/usr/bin/env bash
# Python toolchains via uv, plus ~/ml venv with mlx-lm.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
brew_env

log "Python (uv)"
uv python install 3.12 3.13
if [[ ! -d "$HOME/ml/.venv" ]]; then
  mkdir -p "$HOME/ml"
  (cd "$HOME/ml" && uv venv --python 3.12 && uv pip install mlx-lm huggingface_hub)
fi
echo "ML venv: ~/ml/.venv"
