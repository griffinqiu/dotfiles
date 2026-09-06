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
remote_home=$test_root/remote-home
mkdir -p "$remote_home/.config/remote-open"
printf '%s\n' remote-browser >"$remote_home/.config/remote-open/host"

SSH_ARGS_LOG=$test_root/ssh-args \
  SSH_STDIN_LOG=$test_root/ssh-stdin \
  HOME="$remote_home" \
  XDG_CONFIG_HOME="$remote_home/.config" \
  PATH="$fake_bin:$PATH" \
  "$repo_root/bin/remote-open" "$url"

expected_args=$(printf '%s\n' \
  '-o' \
  'BatchMode=yes' \
  '-o' \
  'ConnectTimeout=3' \
  '-o' \
  'StrictHostKeyChecking=accept-new' \
  'remote-browser' \
  'remote-open')
assert_eq "$expected_args" "$(cat "$test_root/ssh-args")" \
  'http URLs should use non-interactive SSH to the locally configured host'
assert_eq "$url" "$(cat "$test_root/ssh-stdin")" \
  'the URL should reach the remote opener without shell interpretation'
pass 'remote-open forwards HTTP URLs safely using machine-local configuration'

SSH_ARGS_LOG=$test_root/custom-ssh-args \
  SSH_STDIN_LOG=$test_root/custom-ssh-stdin \
  HOME="$test_root/unconfigured-home" \
  XDG_CONFIG_HOME="$test_root/unconfigured-home/.config" \
  REMOTE_OPEN_HOST=travel-browser \
  PATH="$fake_bin:$PATH" \
  "$repo_root/bin/remote-open" 'http://example.com'

grep -Fqx 'travel-browser' "$test_root/custom-ssh-args" ||
  fail 'REMOTE_OPEN_HOST did not override the default host'
pass 'remote-open accepts a custom destination host'

LOCAL_OPEN_LOG=$test_root/local-open \
  HOME="$test_root/unconfigured-home" \
  XDG_CONFIG_HOME="$test_root/unconfigured-home/.config" \
  bash -c '
    exec() { printf "%s\n" "$@" >"$LOCAL_OPEN_LOG"; exit 0; }
    source "$1" "$2"
  ' bash "$repo_root/bin/remote-open" "$url"
expected_local_open=$(printf '%s\n' /usr/bin/open "$url")
assert_eq "$expected_local_open" "$(cat "$test_root/local-open")" \
  'machines without remote-open configuration should open locally'
pass 'remote-open leaves shared installations local by default'

RECEIVER_OPEN_LOG=$test_root/receiver-open \
  SSH_ORIGINAL_COMMAND=remote-open \
  bash -c '
    exec() { printf "%s\n" "$@" >"$RECEIVER_OPEN_LOG"; exit 0; }
    source "$1"
  ' bash "$repo_root/bin/remote-open-receiver" <<<"$url"
assert_eq "$expected_local_open" "$(cat "$test_root/receiver-open")" \
  'the forced receiver should open a validated URL'
pass 'the forced receiver accepts remote-open URL requests'

if printf '%s\n' "$url" | SSH_ORIGINAL_COMMAND=whoami \
  "$repo_root/bin/remote-open-receiver" 2>/dev/null; then
  fail 'the forced receiver accepted an arbitrary SSH command'
fi
if printf '%s\n' 'file:///etc/passwd' | SSH_ORIGINAL_COMMAND=remote-open \
  "$repo_root/bin/remote-open-receiver" 2>/dev/null; then
  fail 'the forced receiver accepted a non-HTTP URL'
fi
pass 'the forced receiver rejects shell commands and unsupported URLs'

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

run_zshrc_for_home() {
  local home_dir=$1
  REPO_ROOT="$repo_root" \
    HOME="$home_dir" \
    BROWSER=existing-browser \
    zsh -f -c '
      mise() { return 1; }
      stty() { return 0; }
      source "$REPO_ROOT/zshrc"
      print -r -- "${BROWSER-unset}"
    '
}

configured_zsh_home=$test_root/configured-zsh-home
mkdir -p "$configured_zsh_home/.config/remote-open"
printf '%s\n' remote-browser >"$configured_zsh_home/.config/remote-open/host"
assert_eq "$configured_zsh_home/dotfiles/bin/remote-open" \
  "$(run_zshrc_for_home "$configured_zsh_home")" \
  'configured shells should route browser opens through remote-open'
pass 'zshrc enables remote-open from machine-local configuration'

assert_eq 'existing-browser' \
  "$(run_zshrc_for_home "$test_root/unconfigured-zsh-home")" \
  'unconfigured machines should preserve their browser configuration'
pass 'zshrc leaves browser configuration unchanged on other machines'

printf '1..%d\n' "$tests"
