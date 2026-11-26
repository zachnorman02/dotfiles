# lib/common.sh — shared helpers, sourced by setup.sh and every scripts/*.sh.
# Safe to source more than once.

[[ -n "${_DOTFILES_COMMON:-}" ]] && return 0
_DOTFILES_COMMON=1

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31mxx  %s\033[0m\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || die "macOS only"

# Ask for sudo once and keep it alive until the top-level process exits.
need_sudo() {
  [[ -n "${_DOTFILES_SUDO:-}" ]] && return 0
  sudo -v
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
  export _DOTFILES_SUDO=1
}

# Put Homebrew on PATH for this process if it's installed.
brew_env() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  command -v brew >/dev/null 2>&1 || die "Homebrew not installed — run: ./setup.sh homebrew"
}
