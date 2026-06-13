# Install behavior kept here as env vars; tool versions are declared in
# ~/.config/mise/config.toml (managed via `mise use -g`, untracked like the old ~/.tool-versions).
# MISE_RUBY_COMPILE=false -> try precompiled ruby first, fall back to compiling
# if none exists for the platform. macOS 26 has no prebuilt ruby yet, so installs
# still compile today; switches to precompiled automatically once upstream ships
# it (or when mise 2026.8.0 makes precompiled the default).
export MISE_RUBY_COMPILE=false
# Allow installing older python-build-standalone releases that lack attestations.
export MISE_PYTHON_GITHUB_ATTESTATIONS=false

# Loaded before path.zsh (alphabetical order), so resolve mise explicitly.
if [ -x "$HOME"/.local/bin/mise ]; then
  eval "$("$HOME"/.local/bin/mise activate zsh)"
elif [ -x /opt/homebrew/bin/mise ]; then
  eval "$(/opt/homebrew/bin/mise activate zsh)"
elif command -v mise >/dev/null; then
  eval "$(mise activate zsh)"
fi
