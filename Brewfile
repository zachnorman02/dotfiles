# Brewfile — Mac Studio (AI box) setup
# Apply with:  brew bundle --file=./Brewfile
# Check with:  brew bundle check --file=./Brewfile

# --- CLI / dev ---
brew "git"
brew "gh"
brew "go"
brew "python"
brew "uv"
brew "node"
brew "awscli"
brew "jq"
brew "mas"          # Mac App Store CLI (used for Tailscale below)

# --- Local LLM ---
brew "llama.cpp"
brew "ollama"

# --- Apps ---
cask "lm-studio"
cask "visual-studio-code"
cask "orbstack"
cask "rectangle"
cask "raycast"
cask "stats"
cask "google-chrome"
cask "firefox"
cask "claude"

# Tailscale — Standalone variant (Tailscale's recommended macOS build).
# Do NOT also install the App Store version; having both breaks the extension.
cask "tailscale-app"
