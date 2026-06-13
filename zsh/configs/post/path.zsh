PATH="/usr/local/sbin:$PATH"
PATH="$HOME/.bun/bin:$PATH"
PATH="/opt/homebrew/bin:$PATH"
# mise (activated in mise.zsh) owns version resolution; asdf shims are a
# transition-period fallback, only added when mise is unavailable.
if ! command -v mise >/dev/null 2>&1; then
  PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
fi
PATH="$HOME/.bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH=".git/safe/../../bin:$PATH"
export -U PATH
