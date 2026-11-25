#!/usr/bin/env bash
# setup.sh — idempotent setup for the Mac Studio (AI / headless-friendly box).
# Safe to re-run: every step checks before changing anything.
#
# Usage:
#   ./setup.sh
#   NEW_HOSTNAME=zach-studio GPU_WIRED_MB=114688 ./setup.sh
#   GIT_NAME="Zach Norman" GIT_EMAIL="you@example.com" ./setup.sh
#
# Options (env vars):
#   GIT_NAME       git user.name  (only applied when given)
#   GIT_EMAIL      git user.email (only applied when given)
#   NEW_HOSTNAME   rename the machine (ComputerName/HostName/LocalHostName)
#   GPU_WIRED_MB   persist iogpu.wired_limit_mb across reboots (omit to leave macOS default)
#   SKIP_APPS=1    skip brew bundle (settings only)
#
# You'll be asked for your password once (sudo); the script keeps it alive while running.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS only"; exit 1; }

# --- sudo once, keep alive ---------------------------------------------------
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Xcode Command Line Tools ------------------------------------------------
log "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  warn "Finish the Command Line Tools installer dialog, then re-run this script."
  exit 0
fi

# --- Homebrew ----------------------------------------------------------------
log "Homebrew"
if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi

if [[ "${SKIP_APPS:-0}" != "1" ]]; then
  log "brew bundle"
  brew bundle --file="$SCRIPT_DIR/Brewfile" || warn "Some Brewfile entries failed — check output above (mas needs App Store sign-in)."
fi

# --- zsh ---------------------------------------------------------------------
log "zsh options"
touch "$HOME/.zshrc"
grep -qxF 'setopt interactivecomments' "$HOME/.zshrc" || echo 'setopt interactivecomments' >> "$HOME/.zshrc"

# --- Git config --------------------------------------------------------------
log "Git config"
gitset() { git config --global "$1" >/dev/null 2>&1 || git config --global "$1" "$2"; }  # only if unset
if [[ -n "${GIT_NAME:-}" ]];  then git config --global user.name  "$GIT_NAME";  fi
if [[ -n "${GIT_EMAIL:-}" ]]; then git config --global user.email "$GIT_EMAIL"; fi
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

# --- Python via uv -----------------------------------------------------------
log "Python toolchains (uv)"
uv python install 3.12 3.13
if [[ ! -d "$HOME/ml/.venv" ]]; then
  mkdir -p "$HOME/ml"
  (cd "$HOME/ml" && uv venv --python 3.12 && uv pip install mlx-lm huggingface_hub)
fi

# --- Ollama as a background service -----------------------------------------
log "Ollama service"
brew services start ollama >/dev/null 2>&1 || warn "Couldn't start Ollama service."

# --- Hostname ----------------------------------------------------------------
if [[ -n "${NEW_HOSTNAME:-}" ]]; then
  log "Renaming machine to $NEW_HOSTNAME"
  sudo scutil --set ComputerName  "$NEW_HOSTNAME"
  sudo scutil --set HostName      "$NEW_HOSTNAME"
  sudo scutil --set LocalHostName "$NEW_HOSTNAME"
fi

# --- Power: never sleep, wake on LAN, restart after power loss --------------
log "Power settings"
sudo pmset -a sleep 0 disksleep 0 displaysleep 15 womp 1 autorestart 1

# --- Firewall ----------------------------------------------------------------
log "Firewall"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on >/dev/null

# --- Remote Login (SSH) ------------------------------------------------------
log "Remote Login (SSH)"
if ! sudo systemsetup -getremotelogin 2>/dev/null | grep -q On; then
  sudo systemsetup -setremotelogin on 2>/dev/null \
    || warn "Couldn't enable SSH from the script (Terminal may need Full Disk Access). Enable it in System Settings > General > Sharing."
fi

# --- Screen Sharing ----------------------------------------------------------
log "Screen Sharing"
sudo launchctl enable system/com.apple.screensharing 2>/dev/null || true
sudo launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
warn "Verify Screen Sharing is ON in System Settings > General > Sharing (macOS may ignore the scripted toggle)."

# --- Time Machine: exclude big re-downloadable model caches ------------------
log "Time Machine exclusions"
for d in "$HOME/.lmstudio" "$HOME/.ollama" "$HOME/.cache/huggingface" "$HOME/ml/.venv"; do
  mkdir -p "$d"
  tmutil addexclusion "$d" 2>/dev/null || true   # sticky exclusion, follows the folder
done

# --- Optional: persist GPU wired-memory limit --------------------------------
if [[ -n "${GPU_WIRED_MB:-}" ]]; then
  log "Persisting iogpu.wired_limit_mb=$GPU_WIRED_MB"
  PLIST=/Library/LaunchDaemons/local.iogpu-wired-limit.plist
  sudo tee "$PLIST" >/dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>local.iogpu-wired-limit</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/sbin/sysctl</string>
    <string>iogpu.wired_limit_mb=${GPU_WIRED_MB}</string>
  </array>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
EOF
  sudo chown root:wheel "$PLIST"; sudo chmod 644 "$PLIST"
  sudo launchctl bootout system "$PLIST" 2>/dev/null || true
  sudo launchctl bootstrap system "$PLIST"
  sudo sysctl "iogpu.wired_limit_mb=${GPU_WIRED_MB}" >/dev/null   # apply now; launchd job handles reboots
  sysctl iogpu.wired_limit_mb
fi

# --- Summary -----------------------------------------------------------------
log "Done"
echo "Hostname:      $(scutil --get LocalHostName).local"
echo "Python (brew): $(/opt/homebrew/bin/python3 --version 2>&1)"
echo "ML venv:       ~/ml/.venv  (activate: source ~/ml/.venv/bin/activate)"
echo
echo "Manual steps remaining:"
echo "  - Install pending macOS updates (fixes the root-cert warning from brew doctor)"
echo "  - Open Tailscale and sign in"
echo "  - Run 'gh auth login' to connect GitHub"
echo "  - Confirm Sharing > Screen Sharing and Remote Login are on"
