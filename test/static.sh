#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-static-test.XXXXXX")

cleanup() {
  rm -rf -- "$test_root"
}
trap cleanup EXIT HUP INT TERM

tests=0
skips=0

fail() {
  printf 'not ok - %s\n' "$*" >&2
  exit 1
}

pass() {
  tests=$((tests + 1))
  printf 'ok %d - %s\n' "$tests" "$*"
}

skip() {
  tests=$((tests + 1))
  skips=$((skips + 1))
  printf 'ok %d - %s # SKIP\n' "$tests" "$*"
}

if ! git -C "$repo_root" diff --check; then
  fail 'unstaged changes contain whitespace errors'
fi
if ! git -C "$repo_root" diff --cached --check; then
  fail 'staged changes contain whitespace errors'
fi
pass 'Git diffs contain no whitespace errors'

if ! command -v zsh >/dev/null 2>&1; then
  fail 'zsh is required to parse the repository zsh configuration'
fi

zsh_files=(
  "$repo_root/aliases"
  "$repo_root/zshenv"
  "$repo_root/zshrc"
  "$repo_root/zshrc.oh-my-zsh"
)

for zsh_file in "${zsh_files[@]}"; do
  if ! zsh -n "$zsh_file"; then
    fail "zsh syntax check failed: ${zsh_file#"$repo_root"/}"
  fi
done
pass 'zsh configuration parses successfully'

shell_files=()
while IFS= read -r -d '' shell_file; do
  first_line=$(sed -n '1p' "$shell_file")
  case "$first_line" in
    *bash* | */sh) shell_files+=("$shell_file") ;;
  esac
done < <(
  find \
    "$repo_root/bin" \
    "$repo_root/hooks" \
    "$repo_root/test" \
    -type f -print0
)

if command -v shellcheck >/dev/null 2>&1; then
  if ! shellcheck --severity=error "${shell_files[@]}"; then
    fail 'ShellCheck found shell correctness errors'
  fi
  pass 'ShellCheck found no shell correctness errors'
else
  skip 'shellcheck is not installed'
fi

if command -v shfmt >/dev/null 2>&1; then
  if ! shfmt -d -i 2 -ci "$repo_root/test/run" "$repo_root/test/static.sh"; then
    fail 'shfmt found formatting differences in the test harness'
  fi
  pass 'shfmt accepts the test harness formatting'
else
  skip 'shfmt is not installed'
fi

if command -v nvim >/dev/null 2>&1; then
  isolated_home="$test_root/home"
  mkdir -p \
    "$isolated_home" \
    "$test_root/cache" \
    "$test_root/config" \
    "$test_root/data" \
    "$test_root/state"

  if ! env \
    HOME="$isolated_home" \
    XDG_CACHE_HOME="$test_root/cache" \
    XDG_CONFIG_HOME="$test_root/config" \
    XDG_DATA_HOME="$test_root/data" \
    XDG_STATE_HOME="$test_root/state" \
    DOTFILES_NVIM_CONFIG_ROOT="$repo_root/config/nvim" \
    nvim --headless --clean -n -u NONE -i NONE \
    '+lua for _, file in ipairs(vim.fn.glob(vim.env.DOTFILES_NVIM_CONFIG_ROOT .. "/**/*.lua", false, true)) do assert(loadfile(file)) end' \
    '+qa'; then
    fail 'Neovim could not parse the Lua configuration'
  fi
  pass 'Neovim parses the Lua configuration headlessly'
else
  skip 'nvim is not installed'
fi

if command -v mvim >/dev/null 2>&1; then
  mkdir -p "$test_root/vim-home"
  if ! HOME="$test_root/vim-home" \
    mvim -v -Nu "$repo_root/vimrc" -U NONE \
    -n -es -i NONE '+qa!'; then
    fail 'MacVim could not load the Vim configuration'
  fi
  pass 'MacVim loads the Vim configuration headlessly'
else
  skip 'mvim is not installed'
fi

# Two separate commits replaced these bodies with symlinks pointing at their own
# path, which reads as `Too many levels of symbolic links` and silently disables
# every affected skill. Catch it before it reaches a commit again.
unreadable_skills=
while IFS= read -r skill_file; do
  [ -n "$skill_file" ] || continue
  if [ -L "$skill_file" ] || ! head -n 1 "$skill_file" >/dev/null 2>&1; then
    unreadable_skills="${unreadable_skills}${unreadable_skills:+, }$skill_file"
  fi
done <<EOF
$(git -C "$repo_root" ls-files 'claude/skills/*' '.claude/skills/*')
EOF
if [ -z "$unreadable_skills" ]; then
  pass 'skill bodies are readable regular files, not symlinks'
else
  fail "unreadable or symlinked skill bodies: $unreadable_skills"
fi

printf '1..%d # %d skipped\n' "$tests" "$skips"
