#!/usr/bin/env bash
# Persist the GPU wired-memory limit across reboots.
#   GPU_WIRED_MB  required, e.g. 114688 (~112 GB on a 128 GB Mac)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

if [[ -z "${GPU_WIRED_MB:-}" ]]; then
  warn "GPU_WIRED_MB not set — skipping (current: $(sysctl -n iogpu.wired_limit_mb))."
  exit 0
fi
need_sudo
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
sudo sysctl "iogpu.wired_limit_mb=${GPU_WIRED_MB}" >/dev/null
sysctl iogpu.wired_limit_mb
