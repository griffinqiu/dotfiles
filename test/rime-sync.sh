#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-rime-sync-test.XXXXXX")

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

rime_dir="$test_root/Rime"
sync_dir="$test_root/cloud sync"
log_dir="$test_root/logs"
fake_squirrel="$test_root/Squirrel"
mkdir -p "$rime_dir" "$sync_dir/test-mac" "$log_dir/rime.squirrel"
touch "$rime_dir/default.yaml"
cat >"$rime_dir/installation.yaml" <<EOF
installation_id: "test-mac"
rime_version: 1.16.0
sync_dir: "$sync_dir"
EOF

fake_notifier="$test_root/notify"
touch "$fake_squirrel"
chmod +x "$fake_squirrel"

# The fake rewrites the files real Squirrel rewrites, unless told to fail or hang.
cat >"$fake_notifier" <<'EOF'
#!/bin/sh
printf '%s\n' "$1" >>"$FAKE_CALLS"
case "$1:${FAKE_MODE:-ok}" in
  *:hang) ;;
  SquirrelReloadNotification:error) echo 'E deployer.cc] Error deploying' >>"$FAKE_ERROR_LOG" ;;
  SquirrelReloadNotification:*) touch "$FAKE_RIME_DIR/user.yaml" ;;
  SquirrelSyncNotification:*) touch "$FAKE_SNAPSHOT_DIR/rime_ice.userdb.txt" ;;
esac
EOF
chmod +x "$fake_notifier"

reset_step_files() {
  touch -t 202001010000 "$rime_dir/default.yaml" "$rime_dir/user.yaml" "$sync_dir/test-mac/rime_ice.userdb.txt"
}

run_rime_sync() {
  : >"$test_root/calls"
  reset_step_files
  env \
    RIME_SQUIRREL_BIN="$fake_squirrel" \
    RIME_SQUIRREL_NOTIFIER="$fake_notifier" \
    RIME_USER_DIR="$rime_dir" \
    RIME_LOG_DIR="$log_dir" \
    RIME_SYNC_TIMEOUT=2 \
    FAKE_CALLS="$test_root/calls" \
    FAKE_RIME_DIR="$rime_dir" \
    FAKE_SNAPSHOT_DIR="$sync_dir/test-mac" \
    FAKE_ERROR_LOG="$log_dir/rime.squirrel/rime.squirrel.ERROR" \
    "$@" \
    "$repo_root/bin/rime-sync" >"$test_root/stdout" 2>"$test_root/stderr"
}

echo 'E old error before rime-sync started' >"$log_dir/rime.squirrel/rime.squirrel.ERROR"
run_rime_sync || fail "rime-sync failed although both steps succeeded: $(cat "$test_root/stderr")"
[ "$(tr '\n' ' ' <"$test_root/calls")" = 'SquirrelReloadNotification SquirrelSyncNotification ' ] ||
  fail "rime-sync must deploy before syncing, got: $(cat "$test_root/calls")"
grep -q '^sync: ok' "$test_root/stdout" || fail 'rime-sync did not report a successful sync'
[ "$(stat -f %m "$rime_dir/default.yaml")" -gt 1577836800 ] ||
  fail 'rime-sync must mark default.yaml modified so Squirrel redeploys'
pass 'rime-sync forces a deploy, then syncs into the configured sync_dir'

if run_rime_sync FAKE_MODE=error; then
  fail 'rime-sync succeeded although Squirrel logged an error'
fi
grep -q 'Error deploying' "$test_root/stderr" || fail 'rime-sync did not show the new error'
if grep -q 'old error' "$test_root/stderr"; then
  fail 'rime-sync reported an error logged before it started'
fi
[ "$(cat "$test_root/calls")" = 'SquirrelReloadNotification' ] || fail 'rime-sync must stop after a failed deploy'
pass 'rime-sync stops and shows only errors logged during its run'

if run_rime_sync FAKE_MODE=hang; then
  fail 'rime-sync succeeded without any confirmation from Squirrel'
fi
grep -q 'not confirmed within 2s' "$test_root/stderr" || fail 'rime-sync did not report the timeout'
pass 'rime-sync times out when Squirrel never confirms'

if env RIME_SQUIRREL_BIN="$test_root/missing" "$repo_root/bin/rime-sync" 2>/dev/null; then
  fail 'rime-sync succeeded without a Squirrel binary'
fi
pass 'rime-sync fails clearly when Squirrel is not installed'

printf '1..%d\n' "$tests"
