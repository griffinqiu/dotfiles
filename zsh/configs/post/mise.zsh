# Install behavior kept here as env vars; exact tool versions and resolved
# macOS-arm64 assets are tracked in ~/.config/mise/config.toml and mise.lock.
# Prefer precompiled Ruby, matching the committed lockfile.
export MISE_RUBY_COMPILE=false
# Allow installing older python-build-standalone releases that lack attestations.
export MISE_PYTHON_GITHUB_ATTESTATIONS=false
# Auto-answer yes to mise prompts, notably config trust checks
# (new worktrees would otherwise error until `mise trust`).
export MISE_YES=1

# Homebrew owns Mise. Loaded before path.zsh, so resolve it explicitly; retain
# the former standalone path only as a migration fallback.
if [ -x /opt/homebrew/bin/mise ]; then
  eval "$(/opt/homebrew/bin/mise activate zsh)"
elif [ -x "$HOME"/.local/bin/mise ]; then
  eval "$("$HOME"/.local/bin/mise activate zsh)"
elif command -v mise >/dev/null; then
  eval "$(mise activate zsh)"
fi
