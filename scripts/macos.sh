#!/usr/bin/env bash
# macOS system settings: hostname, power, firewall, SSH, Screen Sharing.
#   NEW_HOSTNAME  rename the machine
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
need_sudo

if [[ -n "${NEW_HOSTNAME:-}" ]]; then
  log "Renaming machine to $NEW_HOSTNAME"
  for k in ComputerName HostName LocalHostName; do sudo scutil --set "$k" "$NEW_HOSTNAME"; done
fi

log "Power: never sleep, wake on LAN, restart after power loss"
sudo pmset -a sleep 0 disksleep 0 displaysleep 15 womp 1 autorestart 1

log "Firewall"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on >/dev/null

log "Remote Login (SSH)"
if ! sudo systemsetup -getremotelogin 2>/dev/null | grep -q On; then
  sudo systemsetup -setremotelogin on 2>/dev/null \
    || warn "Could not enable SSH from a script. Turn it on in System Settings > General > Sharing."
fi

log "Screen Sharing"
sudo launchctl enable system/com.apple.screensharing 2>/dev/null || true
sudo launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
warn "Confirm Screen Sharing is ON in System Settings > General > Sharing (macOS may ignore the scripted toggle)."
