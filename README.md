# dotfiles

Setup for a fresh Mac (built for the Mac Studio AI box, works for any Apple Silicon Mac).

## Quick start

On a brand-new Mac, `git` triggers the Command Line Tools installer the first time you run it:

```bash
git clone https://github.com/zachnorman02/dotfiles ~/dotfiles
cd ~/dotfiles
GIT_NAME="Your Name" GIT_EMAIL="you@example.com" ./setup.sh
```

The script is idempotent — safe to re-run any time.

## What it does

- Xcode Command Line Tools + Homebrew (and adds `brew` to `~/.zprofile`)
- Everything in [`Brewfile`](Brewfile): dev CLIs, llama.cpp, Ollama, LM Studio, VS Code, OrbStack, Rectangle, Raycast, Stats, Chrome, Firefox, Claude, Tailscale (Standalone variant)
- zsh: `setopt interactivecomments` (so pasted `# comments` work)
- Python 3.12 / 3.13 via `uv`, plus an `~/ml` venv with `mlx-lm`
- Git defaults (`main`, rebase on pull, auto-upstream, prune, rerere) and a global gitignore
- Ollama as a background service
- Power: never sleep, wake on LAN, auto-restart after power loss
- Firewall on, Remote Login (SSH) and Screen Sharing on
- Time Machine exclusions for model caches (`~/.lmstudio`, `~/.ollama`, `~/.cache/huggingface`, `~/ml/.venv`)

## Options

| Env var | Effect |
|---|---|
| `GIT_NAME` / `GIT_EMAIL` | Set git identity (only applied when given) |
| `NEW_HOSTNAME` | Rename the machine |
| `GPU_WIRED_MB` | Persist `iogpu.wired_limit_mb` across reboots (e.g. `114688` ≈ 112 GB on a 128 GB machine) |
| `SKIP_APPS=1` | Skip `brew bundle`; settings only |

## Manual steps afterwards

1. Install pending macOS updates
2. Open Tailscale and sign in
3. `gh auth login`
4. Confirm **System Settings → General → Sharing → Screen Sharing / Remote Login** are on (macOS sometimes ignores the scripted toggle)

## UPS shutdown (NUT client)

The UPS's USB cable goes to the NAS, which runs a NUT server (UGOS: Control Panel → Hardware & Power → UPS → NUT Server: Enable). This Mac listens to it and shuts down cleanly when the battery runs low.

```bash
./ups/setup-nut-client.sh
```

It asks for the NAS's home-network IP and the NUT password (from `/etc/nut/upsd.users` on the NAS). The password goes only into a root-only file on this Mac, never this repo.
