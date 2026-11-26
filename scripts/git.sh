#!/usr/bin/env bash
# Git identity and defaults.
#   GIT_NAME / GIT_EMAIL  set identity (only applied when given)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

log "Git config"
gitset() { git config --global "$1" >/dev/null 2>&1 || git config --global "$1" "$2"; }  # only if unset
[[ -n "${GIT_NAME:-}"  ]] && git config --global user.name  "$GIT_NAME"
[[ -n "${GIT_EMAIL:-}" ]] && git config --global user.email "$GIT_EMAIL"
gitset init.defaultBranch main
gitset pull.rebase true
gitset push.autoSetupRemote true
gitset fetch.prune true
gitset rerere.enabled true
gitset core.excludesfile "$HOME/.gitignore_global"
touch "$HOME/.gitignore_global"
for p in .DS_Store .venv/ __pycache__/ .env; do
  grep -qxF "$p" "$HOME/.gitignore_global" || echo "$p" >> "$HOME/.gitignore_global"
done
git config --global user.name  >/dev/null || warn "git user.name not set — re-run with GIT_NAME=\"...\""
git config --global user.email >/dev/null || warn "git user.email not set — re-run with GIT_EMAIL=\"...\""
