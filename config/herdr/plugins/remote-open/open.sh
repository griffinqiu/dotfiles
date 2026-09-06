#!/usr/bin/env bash

set -euo pipefail

url=${HERDR_PLUGIN_CLICKED_URL:-}
[[ -n $url ]] || exit 0

if [[ $(hostname -s) != "Griffins-MacMini" ]]; then
  exec /usr/bin/open "$url"
fi

exec "$HOME/dotfiles/bin/remote-open" "$url"
