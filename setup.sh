#!/usr/bin/env bash
# setup.sh — run all setup modules, or just the ones you name.
#
#   ./setup.sh                 run every default module, in order
#   ./setup.sh git zsh         run only those modules
#   ./setup.sh nut             run an optional module
#   ./setup.sh --list          list modules
#
# Each module is also runnable on its own: ./scripts/<name>.sh
# Every module is idempotent — safe to re-run.
#
# Env vars some modules use:
#   GIT_NAME, GIT_EMAIL   git identity              (git)
#   NEW_HOSTNAME          rename the machine        (macos)
#   GPU_WIRED_MB          persist GPU memory limit  (gpu; skipped if unset)
#   NAS_IP                NAS home-network IP       (nut; prompts if unset)

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# Run by default, in this order.
DEFAULT=(xcode homebrew apps zsh git python ollama macos timemachine gpu)
# Only run when named (interactive or machine-specific).
OPTIONAL=(nut)

describe() { sed -n '2s/^# *//p' "$DOTFILES_DIR/scripts/$1.sh"; }

if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
  echo "Default (run with no arguments):"
  for m in "${DEFAULT[@]}";  do printf '  %-12s %s\n' "$m" "$(describe "$m")"; done
  echo "Optional (run by name):"
  for m in "${OPTIONAL[@]}"; do printf '  %-12s %s\n' "$m" "$(describe "$m")"; done
  exit 0
fi

if [[ $# -gt 0 ]]; then MODULES=("$@"); else MODULES=("${DEFAULT[@]}"); fi

for m in "${MODULES[@]}"; do
  [[ -f "$DOTFILES_DIR/scripts/$m.sh" ]] || die "Unknown module '$m' — see ./setup.sh --list"
done

# Ask for the password once up front if any module needs it.
for m in "${MODULES[@]}"; do
  if grep -q need_sudo "$DOTFILES_DIR/scripts/$m.sh"; then need_sudo; break; fi
done

FAILED=()
for m in "${MODULES[@]}"; do
  set +e
  bash "$DOTFILES_DIR/scripts/$m.sh"
  rc=$?
  set -e
  if [[ $rc -eq 2 ]]; then warn "Stopping: '$m' needs you to finish something first."; exit 2; fi
  [[ $rc -ne 0 ]] && FAILED+=("$m")
done

echo
if [[ ${#FAILED[@]} -gt 0 ]]; then
  warn "Finished with failures: ${FAILED[*]}  (re-run with: ./setup.sh ${FAILED[*]})"
  exit 1
fi
log "Done: ${MODULES[*]}"
if [[ $# -eq 0 ]]; then
  echo "Manual steps: macOS updates · sign in to Tailscale · gh auth login · confirm Sharing settings"
  echo "Optional:     ./setup.sh nut   (UPS shutdown via the NAS)"
fi
