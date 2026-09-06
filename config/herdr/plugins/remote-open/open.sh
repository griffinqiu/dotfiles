#!/usr/bin/env bash

set -euo pipefail

url=${HERDR_PLUGIN_CLICKED_URL:-}
[[ -n $url ]] || exit 0

exec "$HOME/dotfiles/bin/remote-open" "$url"
