#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SCRIPT="$REPO_ROOT/bin/ai-commit-suggest"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/ai-commit-suggest-test.XXXXXX")
STUB_BIN="$TEST_ROOT/bin"
STUB_LOG_DIR="$TEST_ROOT/log"
WORK_REPO="$TEST_ROOT/repo"
RUN_PID=""
TEST_COUNT=0

cleanup_test() {
  status=$?
  trap - EXIT HUP INT TERM
  if [ -n "$RUN_PID" ]; then
    kill "$RUN_PID" 2>/dev/null || true
    wait "$RUN_PID" 2>/dev/null || true
  fi
  case "$TEST_ROOT" in
    "${TMPDIR:-/tmp}"/ai-commit-suggest-test.*) rm -rf "$TEST_ROOT" ;;
  esac
  exit "$status"
}

trap cleanup_test EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

fail() {
  printf 'not ok %s - %s\n' "$TEST_COUNT" "$*" >&2
  exit 1
}

ok() {
  TEST_COUNT=$((TEST_COUNT + 1))
  printf 'ok %s - %s\n' "$TEST_COUNT" "$1"
}

assert_line() {
  file=$1
  expected=$2
  grep -Fqx -- "$expected" "$file" || fail "$file does not contain exact line: $expected"
}

assert_count() {
  expected=$1
  pattern=$2
  file=$3
  actual=$(grep -Ec -- "$pattern" "$file" || true)
  [ "$actual" = "$expected" ] || fail "$file: expected $expected matches for $pattern, got $actual"
}

reset_logs() {
  rm -f "$STUB_LOG_DIR"/*
}

mkdir -p "$STUB_BIN" "$STUB_LOG_DIR" "$WORK_REPO"

git -C "$WORK_REPO" init -q
git -C "$WORK_REPO" config user.name "AI Commit Test"
git -C "$WORK_REPO" config user.email "ai-commit-test@example.invalid"
printf 'initial\n' >"$WORK_REPO/example.txt"
git -C "$WORK_REPO" add example.txt
git -C "$WORK_REPO" commit -qm "chore: seed test repository"
printf 'changed content\n' >"$WORK_REPO/example.txt"
git -C "$WORK_REPO" add example.txt

cat >"$STUB_BIN/stub-provider" <<'STUB'
#!/bin/sh

set -eu

command_name=${0##*/}
case "$command_name" in
  gh)
    provider=copilot
    [ "${1:-}" = "copilot" ] && shift
    [ "${1:-}" = "--" ] && shift
    ;;
  claude) provider=claude ;;
  codex) provider=codex ;;
  *) exit 90 ;;
esac

printf '%s\n' "$provider" >>"$STUB_LOG_DIR/calls"
printf '%s\n' "$PWD" >"$STUB_LOG_DIR/$provider.pwd"
mkdir -p provider-cache
printf 'provider state\n' >provider-cache/state
ls -l prompt.txt schema.json >"$STUB_LOG_DIR/$provider.modes" 2>/dev/null || true
jq empty schema.json || exit 95
printf '%s\n' "$@" >"$STUB_LOG_DIR/$provider.args"

prompt_file="$STUB_LOG_DIR/$provider.prompt"
output_file=""

case "$provider" in
  copilot)
    while [ "$#" -gt 0 ]; do
      case "$1" in
        -p | --print)
          shift
          [ "$#" -gt 0 ] || exit 91
          printf '%s\n' "$1" >"$prompt_file"
          ;;
      esac
      shift
    done
    ;;
  claude)
    cat >"$prompt_file"
    ;;
  codex)
    while [ "$#" -gt 0 ]; do
      if [ "$1" = "-o" ]; then
        shift
        [ "$#" -gt 0 ] || exit 92
        output_file=$1
      fi
      shift
    done
    cat >"$prompt_file"
    ;;
esac

case "$provider" in
  copilot) mode=${STUB_COPILOT_MODE:-valid} ;;
  claude) mode=${STUB_CLAUDE_MODE:-valid} ;;
  codex) mode=${STUB_CODEX_MODE:-valid} ;;
esac

case "$mode" in
  fail)
    printf '%s unavailable\n' "$provider" >&2
    exit 42
    ;;
  slow)
    printf '%s\n' "$$" >"$STUB_LOG_DIR/$provider.pid"
    trap '' TERM
    (
      trap '' TERM
      while :; do
        printf 'tick\n' >>"$STUB_LOG_DIR/$provider.sleep.heartbeat"
        sleep 0.05
      done
    ) &
    sleep_pid=$!
    printf '%s\n' "$sleep_pid" >"$STUB_LOG_DIR/$provider.sleep.pid"
    wait "$sleep_pid"
    ;;
  delayfail)
    sleep "${STUB_DELAY_SECS:-0.6}"
    printf '%s delayed failure\n' "$provider" >&2
    exit 42
    ;;
  malformed)
    payload='not-json'
    ;;
  nine)
    payload='{"candidates":["feat: candidate one","fix: candidate two","docs: candidate three","test: candidate four","chore: candidate five","perf: candidate six","ci: candidate seven","build: candidate eight","style: candidate nine"]}'
    ;;
  duplicate)
    payload='{"candidates":["feat: duplicate","feat: duplicate","docs: candidate three","test: candidate four","chore: candidate five","perf: candidate six","ci: candidate seven","build: candidate eight","style: candidate nine","refactor: candidate ten"]}'
    ;;
  extra)
    payload='{"candidates":["feat: candidate one","fix: candidate two","docs: candidate three","test: candidate four","chore: candidate five","perf: candidate six","ci: candidate seven","build: candidate eight","style: candidate nine","refactor: candidate ten"],"explanation":"must be rejected"}'
    ;;
  valid)
    if [ "${STUB_OUTPUT_MODE:-short}" = "detailed" ]; then
      payload='{"candidates":[{"subject":"feat: candidate one","body":"Explain the first motivation."},{"subject":"fix: candidate two","body":"Explain the second motivation."},{"subject":"docs: candidate three","body":"Explain the third motivation."},{"subject":"test: candidate four","body":"Explain the fourth motivation."},{"subject":"chore: candidate five","body":"Explain the fifth motivation."}]}'
    else
      payload='{"candidates":["feat: candidate one","fix: candidate two","docs: candidate three","test: candidate four","chore: candidate five","perf: candidate six","ci: candidate seven","build: candidate eight","style: candidate nine","refactor: candidate ten"]}'
    fi
    ;;
  *) exit 93 ;;
esac

case "$provider" in
  claude)
    [ "$payload" = "not-json" ] && printf '%s\n' "$payload" \
      || printf '{"structured_output":%s}\n' "$payload"
    ;;
  codex)
    [ -n "$output_file" ] || exit 94
    printf '%s\n' "$payload" >"$output_file"
    ;;
  *) printf '%s\n' "$payload" ;;
esac
STUB

chmod +x "$STUB_BIN/stub-provider"
ln -s stub-provider "$STUB_BIN/gh"
ln -s stub-provider "$STUB_BIN/claude"
ln -s stub-provider "$STUB_BIN/codex"

PATH="$STUB_BIN:$PATH"
export PATH STUB_LOG_DIR

OUT="$TEST_ROOT/out"
ERR="$TEST_ROOT/err"

reset_logs
if (cd "$WORK_REPO" && AI_COMMIT_PROVIDER=pilot "$SCRIPT" --short) >"$OUT" 2>"$ERR"; then
  fail "substring provider name was accepted"
fi
grep -Fq "Unknown provider: pilot" "$ERR" || fail "invalid provider diagnostic missing"
[ ! -e "$STUB_LOG_DIR/calls" ] || fail "invalid provider invoked a CLI"
ok "provider validation is an exact enumeration"

reset_logs
(cd "$WORK_REPO" && "$SCRIPT" --short) >"$OUT" 2>"$ERR"
[ "$(wc -l <"$OUT" | tr -d ' ')" = "10" ] || fail "short output did not contain exactly 10 lines"
[ "$(cat "$STUB_LOG_DIR/calls")" = "copilot" ] || fail "default provider was not Copilot"
for flag in --silent --effort low --available-tools= --allow-all-tools \
  --disable-builtin-mcps --no-custom-instructions --no-ask-user --no-remote \
  --no-remote-export --no-auto-update --log-level none --no-color; do
  assert_line "$STUB_LOG_DIR/copilot.args" "$flag"
done
grep -Fq "untrusted data" "$STUB_LOG_DIR/copilot.prompt" || fail "prompt injection boundary missing"
copilot_tmp=$(cat "$STUB_LOG_DIR/copilot.pwd")
[ ! -d "$copilot_tmp" ] || fail "Copilot private directory was not cleaned"
assert_count 2 '^-rw-------' "$STUB_LOG_DIR/copilot.modes"
ok "Copilot uses an empty tool surface and private cleaned workspace"

reset_logs
(cd "$WORK_REPO" && AI_COMMIT_PROVIDER=claude "$SCRIPT" --short) >"$OUT" 2>"$ERR"
[ "$(cat "$STUB_LOG_DIR/calls")" = "claude" ] || fail "Claude was not selected first"
for flag in --effort low --safe-mode --tools --no-session-persistence --output-format json --json-schema; do
  assert_line "$STUB_LOG_DIR/claude.args" "$flag"
done
tools_line=$(grep -n '^--tools$' "$STUB_LOG_DIR/claude.args" | cut -d: -f1)
tools_value=$(sed -n "$((tools_line + 1))p" "$STUB_LOG_DIR/claude.args")
[ -z "$tools_value" ] || fail "Claude received a non-empty tool list"
grep -Fq "changed content" "$STUB_LOG_DIR/claude.prompt" || fail "Claude did not receive the prompt on stdin"
if grep -Fq "changed content" "$STUB_LOG_DIR/claude.args"; then
  fail "Claude prompt leaked into argv"
fi
ok "Claude disables tools and persistence and receives the prompt on stdin"

reset_logs
(cd "$WORK_REPO" && AI_COMMIT_PROVIDER=codex "$SCRIPT" --short) >"$OUT" 2>"$ERR"
[ "$(cat "$STUB_LOG_DIR/calls")" = "codex" ] || fail "Codex was not selected first"
for flag in --sandbox read-only --ephemeral --ignore-user-config --skip-git-repo-check \
  --output-schema --color never; do
  assert_line "$STUB_LOG_DIR/codex.args" "$flag"
done
grep -Fq "changed content" "$STUB_LOG_DIR/codex.prompt" || fail "Codex did not receive the prompt on stdin"
if grep -Fq "changed content" "$STUB_LOG_DIR/codex.args"; then
  fail "Codex prompt leaked into argv"
fi
ok "Codex uses read-only ephemeral structured execution over stdin"

reset_logs
(cd "$WORK_REPO" && STUB_COPILOT_MODE=nine "$SCRIPT" --short) >"$OUT" 2>"$ERR"
expected_calls=$(printf 'copilot\nclaude')
[ "$(cat "$STUB_LOG_DIR/calls")" = "$expected_calls" ] || fail "wrong default fallback order"
[ "$(wc -l <"$OUT" | tr -d ' ')" = "10" ] || fail "fallback did not return 10 candidates"
grep -Fq "exact-count validation" "$ERR" || fail "count validation diagnostic missing"
ok "wrong candidate count triggers the existing Copilot-to-Claude fallback"

reset_logs
(cd "$WORK_REPO" && STUB_COPILOT_MODE=extra "$SCRIPT" --short) >"$OUT" 2>"$ERR"
expected_calls=$(printf 'copilot\nclaude')
[ "$(cat "$STUB_LOG_DIR/calls")" = "$expected_calls" ] || fail "Copilot extra-key output did not fall back"
ok "Copilot output rejects top-level keys other than candidates"

reset_logs
(cd "$WORK_REPO" && AI_COMMIT_PROVIDER=codex STUB_CODEX_MODE=fail "$SCRIPT" --short) >"$OUT" 2>"$ERR"
expected_calls=$(printf 'codex\nclaude')
[ "$(cat "$STUB_LOG_DIR/calls")" = "$expected_calls" ] || fail "explicit-provider fallback order changed"
ok "explicit provider still falls back in the original priority order"

reset_logs
(cd "$WORK_REPO" && STUB_OUTPUT_MODE=detailed "$SCRIPT" --detailed) >"$OUT" 2>"$ERR"
assert_count 5 '^(feat|fix|docs|test|chore): ' "$OUT"
assert_count 4 '^===COMMIT===$' "$OUT"
ok "detailed schema requires and renders exactly five candidates"

reset_logs
if (cd "$WORK_REPO" && \
  STUB_COPILOT_MODE=duplicate \
  STUB_CLAUDE_MODE=nine \
  STUB_CODEX_MODE=malformed \
  "$SCRIPT" --short) >"$OUT" 2>"$ERR"; then
  fail "all-invalid provider outputs unexpectedly succeeded"
fi
expected_calls=$(printf 'copilot\nclaude\ncodex')
[ "$(cat "$STUB_LOG_DIR/calls")" = "$expected_calls" ] || fail "all-provider fallback order changed"
grep -Fq "All providers failed." "$ERR" || fail "terminal failure diagnostic missing"
ok "malformed, duplicate, and wrong-count results cannot pass validation"

reset_logs
started_at=$(perl -MTime::HiRes=time -e 'print time')
if (cd "$WORK_REPO" && \
  AI_COMMIT_TIMEOUT_SECS=1 \
  STUB_COPILOT_MODE=delayfail \
  STUB_DELAY_SECS=0.7 \
  STUB_CLAUDE_MODE=slow \
  "$SCRIPT" --short) >"$OUT" 2>"$ERR"; then
  fail "total fallback deadline unexpectedly succeeded"
fi
ended_at=$(perl -MTime::HiRes=time -e 'print time')
duration=$(awk "BEGIN { print $ended_at - $started_at }")
awk "BEGIN { exit !($duration < 1.5) }" || fail "fallback deadline reset per provider ($duration seconds)"
expected_calls=$(printf 'copilot\nclaude')
[ "$(cat "$STUB_LOG_DIR/calls")" = "$expected_calls" ] || fail "total deadline did not span fallback providers"
grep -Fq "total provider deadline exceeded after 1s" "$ERR" || fail "total deadline diagnostic missing"
timeout_tmp=$(cat "$STUB_LOG_DIR/claude.pwd")
[ ! -d "$timeout_tmp" ] || fail "timeout cleanup left the private directory"
[ -s "$STUB_LOG_DIR/claude.sleep.heartbeat" ] || fail "timeout sleep child never started"
timeout_heartbeat_before=$(wc -c <"$STUB_LOG_DIR/claude.sleep.heartbeat" | tr -d ' ')
sleep 0.2
timeout_heartbeat_after=$(wc -c <"$STUB_LOG_DIR/claude.sleep.heartbeat" | tr -d ' ')
[ "$timeout_heartbeat_before" = "$timeout_heartbeat_after" ] \
  || fail "timeout cleanup left the sleep child producing heartbeats"
ok "one total deadline spans fallback attempts and cleans the full process tree"

reset_logs
(
  cd "$WORK_REPO"
  exec env STUB_COPILOT_MODE=slow "$SCRIPT" --short
) >"$OUT" 2>"$ERR" &
RUN_PID=$!
attempt=0
while { [ ! -s "$STUB_LOG_DIR/copilot.pid" ] \
  || [ ! -s "$STUB_LOG_DIR/copilot.sleep.pid" ] \
  || [ ! -s "$STUB_LOG_DIR/copilot.sleep.heartbeat" ]; } \
  && [ "$attempt" -lt 100 ]; do
  sleep 0.05
  attempt=$((attempt + 1))
done
[ -s "$STUB_LOG_DIR/copilot.pid" ] || fail "slow stub did not start"
[ -s "$STUB_LOG_DIR/copilot.sleep.pid" ] || fail "slow stub child did not start"
[ -s "$STUB_LOG_DIR/copilot.sleep.heartbeat" ] || fail "slow stub child did not heartbeat"
signal_tmp=$(cat "$STUB_LOG_DIR/copilot.pwd")
kill -TERM "$RUN_PID"
wait "$RUN_PID" 2>/dev/null || true
RUN_PID=""
[ ! -d "$signal_tmp" ] || fail "signal cleanup left the private directory"
signal_heartbeat_before=$(wc -c <"$STUB_LOG_DIR/copilot.sleep.heartbeat" | tr -d ' ')
sleep 0.2
signal_heartbeat_after=$(wc -c <"$STUB_LOG_DIR/copilot.sleep.heartbeat" | tr -d ' ')
[ "$signal_heartbeat_before" = "$signal_heartbeat_after" ] \
  || fail "signal cleanup left the sleep child producing heartbeats"
ok "TERM recursively removes provider files and terminates the full process tree"

printf '1..%s\n' "$TEST_COUNT"
