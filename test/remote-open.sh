#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-remote-open-test.XXXXXX")

cleanup() {
  rm -rf -- "$test_root"
}
trap cleanup EXIT HUP INT TERM

tests=0

fail() {
  printf 'not ok - %s\n' "$*" >&2
  exit 1
}

pass() {
  tests=$((tests + 1))
  printf 'ok %d - %s\n' "$tests" "$*"
}

assert_eq() {
  local expected=$1
  local actual=$2
  local message=$3
  [[ $actual == "$expected" ]] || fail "$message (expected '$expected', got '$actual')"
}

fake_bin=$test_root/bin
mkdir -p "$fake_bin"
cat >"$fake_bin/ssh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" >"$SSH_ARGS_LOG"
cat >"$SSH_STDIN_LOG"
EOF
chmod +x "$fake_bin/ssh"

url='https://example.com/search?q=one&next=two'
SSH_ARGS_LOG=$test_root/ssh-args \
  SSH_STDIN_LOG=$test_root/ssh-stdin \
  PATH="$fake_bin:$PATH" \
  "$repo_root/bin/remote-open" "$url"

expected_args=$(printf '%s\n' \
  '-o' \
  'BatchMode=yes' \
  '-o' \
  'ConnectTimeout=3' \
  '-o' \
  'StrictHostKeyChecking=accept-new' \
  'macbook' \
  'IFS= read -r url; exec /usr/bin/open "$url"')
assert_eq "$expected_args" "$(cat "$test_root/ssh-args")" \
  'http URLs should use non-interactive SSH to the default host'
assert_eq "$url" "$(cat "$test_root/ssh-stdin")" \
  'the URL should reach the remote opener without shell interpretation'
pass 'remote-open forwards HTTP URLs safely to the default MacBook host'

SSH_ARGS_LOG=$test_root/custom-ssh-args \
  SSH_STDIN_LOG=$test_root/custom-ssh-stdin \
  REMOTE_OPEN_HOST=travel-mac \
  PATH="$fake_bin:$PATH" \
  "$repo_root/bin/remote-open" 'http://example.com'

grep -Fqx 'travel-mac' "$test_root/custom-ssh-args" ||
  fail 'REMOTE_OPEN_HOST did not override the default host'
pass 'remote-open accepts a custom destination host'

plugin_home=$test_root/plugin-home
mkdir -p "$plugin_home/dotfiles/bin"
cat >"$plugin_home/dotfiles/bin/remote-open" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" >"$PLUGIN_OPEN_LOG"
EOF
chmod +x "$plugin_home/dotfiles/bin/remote-open"

PLUGIN_OPEN_LOG=$test_root/plugin-open \
  HOME="$plugin_home" \
  HERDR_PLUGIN_CLICKED_URL="$url" \
  bash "$repo_root/config/herdr/plugins/remote-open/open.sh"
assert_eq "$url" "$(cat "$test_root/plugin-open")" \
  'the Herdr action should forward its clicked URL'
pass 'the Herdr action delegates clicked URLs to remote-open'

rm -f "$test_root/plugin-open"
PLUGIN_OPEN_LOG=$test_root/plugin-open \
  HOME="$plugin_home" \
  HERDR_PLUGIN_CLICKED_URL= \
  bash "$repo_root/config/herdr/plugins/remote-open/open.sh"
[[ ! -e $test_root/plugin-open ]] || fail 'an empty Herdr URL invoked remote-open'
pass 'the Herdr action ignores invocations without a clicked URL'

LOCAL_OPEN_LOG=$test_root/local-open \
  HERDR_PLUGIN_CLICKED_URL="$url" \
  bash -c '
    hostname() { printf "%s\n" Griffins-MacBook; }
    exec() { printf "%s\n" "$@" >"$LOCAL_OPEN_LOG"; exit 0; }
    source "$1"
  ' bash "$repo_root/config/herdr/plugins/remote-open/open.sh"
expected_local_open=$(printf '%s\n' /usr/bin/open "$url")
assert_eq "$expected_local_open" "$(cat "$test_root/local-open")" \
  'the Herdr action should open locally outside the Mac mini'
pass 'the Herdr action keeps shared installations local on other Macs'

run_zshrc_for_host() {
  local host_name=$1
  TEST_HOST_NAME=$host_name \
    REPO_ROOT="$repo_root" \
    HOME="$test_root/zsh-home" \
    BROWSER=existing-browser \
    zsh -f -c '
      hostname() { print -r -- "$TEST_HOST_NAME"; }
      mise() { return 1; }
      stty() { return 0; }
      source "$REPO_ROOT/zshrc"
      print -r -- "${BROWSER-unset}"
    '
}

assert_eq "$test_root/zsh-home/dotfiles/bin/remote-open" \
  "$(run_zshrc_for_host Griffins-MacMini)" \
  'Mac mini shells should route browser opens through remote-open'
pass 'zshrc configures remote-open on the Mac mini'

assert_eq 'existing-browser' "$(run_zshrc_for_host Griffins-MacBook)" \
  'other Macs should preserve their browser configuration'
pass 'zshrc leaves browser configuration unchanged on other machines'

printf '1..%d\n' "$tests"
