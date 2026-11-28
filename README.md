# dotfiles

Setup for a fresh Mac (built for the Mac Studio AI box, works for any Apple Silicon Mac).

## Quick start

On a brand-new Mac, `git` triggers the Command Line Tools installer the first time you run it:

```bash
git clone https://github.com/zachnorman02/dotfiles ~/dotfiles
cd ~/dotfiles
GIT_NAME="Your Name" GIT_EMAIL="you@example.com" ./setup.sh
```

Everything is idempotent — safe to re-run any time.

## Running parts of it

`setup.sh` runs a list of modules in `scripts/`. Run all of them, or just the ones you name:

```bash
./setup.sh                  # all default modules, in order
./setup.sh git zsh          # only these
./setup.sh nut              # an optional module
./setup.sh --list           # what's available
./scripts/gpu.sh            # any module also runs on its own
```

| Module | What it does | Default? |
|---|---|---|
| `xcode` | Xcode Command Line Tools | yes |
| `homebrew` | Homebrew, added to `~/.zprofile` | yes |
| `apps` | Everything in [`Brewfile`](Brewfile): dev CLIs, llama.cpp, Ollama, NUT, LM Studio, VS Code, OrbStack, Rectangle, Raycast, Stats, Chrome, Firefox, Claude, Claude Code CLI, Tailscale (Standalone) | yes |
| `zsh` | `setopt interactivecomments` (pasted `# comments` work) | yes |
| `git` | Identity (from `GIT_NAME`/`GIT_EMAIL`), sensible defaults, global gitignore | yes |
| `python` | Python 3.12/3.13 via `uv`, `~/ml` venv with `mlx-lm` | yes |
| `ollama` | Ollama as a background service | yes |
| `macos` | Never sleep, wake on LAN, restart after power loss, firewall, SSH, Screen Sharing, optional rename | yes |
| `timemachine` | Exclude model caches from Time Machine | yes |
| `gpu` | Persist the GPU memory limit (skipped unless `GPU_WIRED_MB` is set) | yes |
| `nut` | Shut down cleanly when the UPS on the NAS runs low | no — run by name |
| `hermes` | [Hermes Agent](https://hermes-agent.nousresearch.com/docs) by Nous Research (official installer) | no — run by name |

## Options

| Env var | Used by | Effect |
|---|---|---|
| `GIT_NAME` / `GIT_EMAIL` | `git` | Set git identity (only applied when given) |
| `NEW_HOSTNAME` | `macos` | Rename the machine |
| `GPU_WIRED_MB` | `gpu` | Persist `iogpu.wired_limit_mb` (e.g. `114688` ≈ 112 GB on a 128 GB machine) |
| `NAS_IP` | `nut` | NAS home-network IP (prompts if unset) |

## Adding a module

1. Create `scripts/<name>.sh`. Line 2 is a one-line comment describing it (shown by `--list`).
2. Start it with `source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"` to get `log`, `warn`, `die`, `need_sudo` and `brew_env`.
3. Add its name to `DEFAULT` or `OPTIONAL` in `setup.sh`.

Exit 0 on success, 1 on failure (the run continues and reports it at the end), or 2 to stop the whole run because something needs you first.

## Manual steps afterwards

1. Install pending macOS updates
2. Open Tailscale and sign in
3. `gh auth login`
4. Confirm **System Settings → General → Sharing → Screen Sharing / Remote Login** are on (macOS sometimes ignores the scripted toggle)

## UPS shutdown (`nut` module)

The UPS's USB cable goes to the NAS, which runs a NUT server (UGOS: Control Panel → Hardware & Power → UPS → NUT Server: Enable). This Mac listens to it and shuts down cleanly when the battery runs low.

```bash
./setup.sh nut
```

It asks for the NAS's home-network IP and the NUT password (from `/etc/nut/upsd.users` on the NAS). The password goes only into a root-only file on this Mac, never this repo.
