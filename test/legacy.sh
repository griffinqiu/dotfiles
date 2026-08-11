#!/usr/bin/env bash

set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-legacy-test.XXXXXX")
cleanup() {
  rm -rf -- "$tmp_dir"
}
trap cleanup EXIT HUP INT TERM

tests=0

fail() {
  echo "not ok - $*" >&2
  exit 1
}

pass() {
  tests=$((tests + 1))
  echo "ok $tests - $*"
}

assert_eq() {
  expected=$1
  actual=$2
  message=$3
  [[ $actual == "$expected" ]] || fail "$message (expected '$expected', got '$actual')"
}

git_repo=$tmp_dir/default-branch
git init -q "$git_repo"
git -C "$git_repo" config user.name Test
git -C "$git_repo" config user.email test@example.com
printf 'base\n' >"$git_repo/file"
git -C "$git_repo" add file
git -C "$git_repo" commit -qm base

git -C "$git_repo" update-ref refs/remotes/origin/main HEAD
git -C "$git_repo" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
actual=$(cd "$git_repo" && "$repo_dir/bin/git-default-branch")
assert_eq main "$actual" "remote HEAD should select main"
pass "git-default-branch reads remote HEAD"

git -C "$git_repo" symbolic-ref -d refs/remotes/origin/HEAD
actual=$(cd "$git_repo" && "$repo_dir/bin/git-default-branch")
assert_eq main "$actual" "main fallback should be selected"
pass "git-default-branch falls back to main"

git -C "$git_repo" update-ref -d refs/remotes/origin/main
git -C "$git_repo" update-ref refs/remotes/origin/master HEAD
actual=$(cd "$git_repo" && "$repo_dir/bin/git-default-branch")
assert_eq master "$actual" "master fallback should be selected"
pass "git-default-branch falls back to master"

git -C "$git_repo" update-ref refs/remotes/upstream/trunk HEAD
git -C "$git_repo" symbolic-ref refs/remotes/upstream/HEAD refs/remotes/upstream/trunk
actual=$(cd "$git_repo" && "$repo_dir/bin/git-default-branch" upstream)
assert_eq trunk "$actual" "custom remote HEAD should be selected"
pass "git-default-branch supports custom remotes and branches"

git -C "$git_repo" update-ref -d refs/remotes/origin/master
if (cd "$git_repo" && "$repo_dir/bin/git-default-branch" >/dev/null 2>&1); then
  fail "git-default-branch should fail when no default can be determined"
fi
pass "git-default-branch fails instead of guessing"

printf 'feature\n' >>"$git_repo/file"
git -C "$git_repo" commit -qam feature
output=$(cd "$git_repo" && GIT_CHURN_REMOTE=upstream "$repo_dir/bin/git-churn")
[[ $output == *' file' ]] || fail "git-churn should compare with the detected custom default branch"
pass "git-churn uses the shared default-branch detector"

fake_bin=$tmp_dir/bin
mkdir -p "$fake_bin"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf "%s\\n" "$*" >>"$GIT_CALL_LOG"' \
  'case "$1" in' \
  '  rev-parse) exit 0 ;;' \
  '  symbolic-ref) printf "origin/main\\n" ;;' \
  '  fetch|rebase) exit 0 ;;' \
  '  *) exit 1 ;;' \
  'esac' >"$fake_bin/git"
chmod +x "$fake_bin/git"
GIT_CALL_LOG=$tmp_dir/git.log PATH="$fake_bin:$PATH" "$repo_dir/bin/git-up" --autostash
rg -Fxq 'fetch origin' "$tmp_dir/git.log" || fail "git-up should fetch origin"
rg -Fxq 'rebase origin/main --autostash' "$tmp_dir/git.log" || fail "git-up should rebase the detected branch and preserve args"
pass "git-up fetches and rebases the detected default branch"

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf "%s\\n" "$@" >"$CALL_LOG"' >"$fake_bin/gh"
chmod +x "$fake_bin/gh"
CALL_LOG=$tmp_dir/gh.log PATH="$fake_bin:$PATH" "$repo_dir/bin/git-pr" --title "two words" --draft
actual=$(tr '\n' '|' <"$tmp_dir/gh.log")
assert_eq 'pr|create|--title|two words|--draft|' "$actual" "git-pr should preserve every argument"
pass "git-pr delegates safely to gh"

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf "%s\\n" "$@" >"$CALL_LOG"' >"$fake_bin/bootmux"
chmod +x "$fake_bin/bootmux"
CALL_LOG=$tmp_dir/mux.log PATH="$fake_bin:$PATH" "$repo_dir/bin/mux"
assert_eq picker "$(tr '\n' ' ' <"$tmp_dir/mux.log" | sed 's/ $//')" "mux without args should open picker"
CALL_LOG=$tmp_dir/mux.log PATH="$fake_bin:$PATH" "$repo_dir/bin/mux" my-project
assert_eq 'start my-project' "$(tr '\n' ' ' <"$tmp_dir/mux.log" | sed 's/ $//')" "mux project should call start"
CALL_LOG=$tmp_dir/mux.log PATH="$fake_bin:$PATH" "$repo_dir/bin/mux" list --json
assert_eq 'list --json' "$(tr '\n' ' ' <"$tmp_dir/mux.log" | sed 's/ $//')" "mux subcommand should pass through"
CALL_LOG=$tmp_dir/mux.log PATH="$fake_bin:$PATH" "$repo_dir/bin/mux" config get default-backend
assert_eq 'config get default-backend' "$(tr '\n' ' ' <"$tmp_dir/mux.log" | sed 's/ $//')" "mux config should pass through"
CALL_LOG=$tmp_dir/mux.log PATH="$fake_bin:$PATH" "$repo_dir/bin/mux" stop-all
assert_eq 'stop-all' "$(tr '\n' ' ' <"$tmp_dir/mux.log" | sed 's/ $//')" "mux stop-all should pass through"
CALL_LOG=$tmp_dir/mux.log PATH="$fake_bin:$PATH" "$repo_dir/bin/mux" --backend herdr list
assert_eq '--backend herdr list' "$(tr '\n' ' ' <"$tmp_dir/mux.log" | sed 's/ $//')" "mux should preserve a backend before a subcommand"
CALL_LOG=$tmp_dir/mux.log PATH="$fake_bin:$PATH" "$repo_dir/bin/mux" --backend herdr my-project
assert_eq '--backend herdr start my-project' "$(tr '\n' ' ' <"$tmp_dir/mux.log" | sed 's/ $//')" "mux should add start after a backend for project names"
pass "mux maps picker, projects, all current subcommands, and backends"

gem_dir="$tmp_dir/gem path"
mkdir -p "$gem_dir"
printf '%s\n' 'value = -needle' >"$gem_dir/source.rb"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'if [[ $1 == list && $2 == --paths ]]; then' \
  '  printf "%s\\n" "$FAKE_GEM_PATH"' \
  'elif [[ $1 == show ]]; then' \
  '  printf "%s\\n" "$FAKE_GEM_PATH"' \
  'else' \
  '  exit 2' \
  'fi' >"$fake_bin/bundle"
chmod +x "$fake_bin/bundle"
output=$(FAKE_GEM_PATH="$gem_dir" PATH="$fake_bin:$PATH" "$repo_dir/bin/bundler-search" -needle)
[[ $output == *'source.rb'* ]] || fail "bundler-search should support spaces and a leading-dash pattern"
pass "bundler-search uses safe arrays and ripgrep"

replace_file="$tmp_dir/file with spaces.txt"
printf '%s\n' 'foo1 -flag foo2' >"$replace_file"
"$repo_dir/bin/replace" 'foo[0-9]' value "$replace_file"
assert_eq 'value -flag value' "$(tr -d '\n' <"$replace_file")" "regex replacement should replace both values"
"$repo_dir/bin/replace" --literal -flag done "$replace_file"
assert_eq 'value done value' "$(tr -d '\n' <"$replace_file")" "literal replacement should accept a leading dash"
"$repo_dir/bin/replace" --literal absent ignored "$replace_file"
pass "replace is NUL-safe and supports regex, literal, and zero-match cases"

[[ ! -e "$repo_dir/agrc" ]] || fail "legacy agrc should be removed"
[[ ! -e "$repo_dir/vimrc.bundles" ]] || fail "vim-plug bundle file should be removed"
[[ ! -e "$repo_dir/nvim.lsp" ]] || fail "obsolete vim-plug Neovim LSP config should be removed"
! rg -q 'VIM_PLUG_(REV|SHA256)|install_vim_plug|run_vim_plugins' \
  "$repo_dir/bin/dotfiles-bootstrap" "$repo_dir/bin/dotfiles-doctor" ||
  fail "vim-plug provisioning should be removed"
! rg -q 'alias mux=' "$repo_dir/aliases" || fail "mux alias should be removed"
pass "retired ag and vim-plug entry points are gone"

# Oh My Zsh owns compinit, the prompt, and `g`; duplicating any of them was a bug.
[[ ! -d "$repo_dir/zsh" ]] ||
  fail "zsh configuration is inlined in zshrc; the zsh directory should be gone"
! rg -q '^\s*compinit|_load_settings' "$repo_dir/zshrc" ||
  fail "compinit must run once, from Oh My Zsh"
! rg -q '^\s*(z|mise|docker|docker-compose)$' "$repo_dir/zshrc.oh-my-zsh" ||
  fail "plugins duplicated by mise activation, OrbStack, or zoxide should stay disabled"
pass "Oh My Zsh integration has no duplicated compinit, prompt, or plugin"

# PATH has to be built before anything resolved through it.
rg -n '^(PATH=|command -v mise|fpath=|\[\[ -f ~/\.zshrc\.oh-my-zsh)' "$repo_dir/zshrc" |
  cut -d: -f1 | sort -cn ||
  fail "zshrc must order PATH, mise activation, fpath, then Oh My Zsh"
pass "zshrc loads PATH, mise, completions, and Oh My Zsh in dependency order"

echo "1..$tests"
