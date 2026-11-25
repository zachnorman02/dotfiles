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

# Tailscale from the App Store (must be signed into the App Store first).
# If this ID is ever wrong, `mas search Tailscale` shows the current one.
mas "Tailscale", id: 1475387142
