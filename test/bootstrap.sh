#!/bin/sh

set -eu

script_path=$0
while [ -L "$script_path" ]; do
  script_dir=$(CDPATH= cd -P -- "$(dirname -- "$script_path")" && pwd)
  script_path=$(readlink "$script_path")
  case "$script_path" in
    /*) ;;
    *) script_path=$script_dir/$script_path ;;
  esac
done
repo_root=$(CDPATH= cd -P -- "$(dirname -- "$script_path")/.." && pwd)
original_home=$HOME

test_tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-bootstrap-test.XXXXXX")
trap 'rm -rf -- "$test_tmp"' EXIT HUP INT TERM
mkdir -p "$test_tmp/bin" "$test_tmp/home"
git init -q "$test_tmp/ignore-repo"
test_log=$test_tmp/commands.log

fail() {
  printf 'not ok - %s\n' "$*" >&2
  exit 1
}

pass() {
  printf 'ok - %s\n' "$*"
}

cat >"$test_tmp/bin/brew" <<'EOF'
#!/bin/sh
printf 'brew:%s\n' "$*" >>"$TEST_LOG"
EOF

cat >"$test_tmp/bin/rcup" <<'EOF'
#!/bin/sh
printf 'rcup:RCRC=%s args=%s\n' "${RCRC:-}" "$*" >>"$TEST_LOG"
EOF

cat >"$test_tmp/bin/doctor" <<'EOF'
#!/bin/sh
printf 'doctor:%s\n' "$*" >>"$TEST_LOG"
EOF

cat >"$test_tmp/bin/mise" <<'EOF'
#!/bin/sh
printf 'mise:%s\n' "$*" >>"$TEST_LOG"
EOF

cat >"$test_tmp/bin/git-deps" <<'EOF'
#!/bin/sh
set -eu

checkout_path=
if [ "${1:-}" = -C ]; then
  checkout_path=$2
  shift 2
fi

case "${1:-}" in
  rev-parse)
    if [ -f "$checkout_path/.dotfiles-upgraded" ]; then
      case "$checkout_path" in
        */.oh-my-zsh) printf '%s\n' "$TEST_OMZ_REV" ;;
        */tpm) printf '%s\n' "$TEST_TPM_REV" ;;
        *) exit 91 ;;
      esac
    else
      printf '%s\n' old-revision
    fi
    ;;
  fetch)
    printf 'git:%s:fetch:%s\n' "$checkout_path" "$*" >>"$TEST_LOG"
    ;;
  checkout)
    : >"$checkout_path/.dotfiles-upgraded"
    printf 'git:%s:checkout:%s\n' "$checkout_path" "$*" >>"$TEST_LOG"
    ;;
  *) exit 92 ;;
esac
EOF

chmod +x \
  "$test_tmp/bin/brew" \
  "$test_tmp/bin/rcup" \
  "$test_tmp/bin/doctor" \
  "$test_tmp/bin/mise" \
  "$test_tmp/bin/git-deps"

TEST_OMZ_REV=59a9740721b734835812121322d6fe4827b0853a
TEST_TPM_REV=99469c4a9b1ccf77fade25842dc7bafbc8ce9946
export TEST_OMZ_REV TEST_TPM_REV

run_bootstrap() {
  HOME="$test_tmp/home" \
  TEST_LOG="$test_log" \
  DOTFILES_ROOT="$repo_root" \
  DOTFILES_BREW_BIN="$test_tmp/bin/brew" \
  DOTFILES_RCUP_BIN="$test_tmp/bin/rcup" \
  DOTFILES_DOCTOR_BIN="$test_tmp/bin/doctor" \
  DOTFILES_MISE_BIN="$test_tmp/bin/mise" \
  DOTFILES_MACHINE_ARCH="${DOTFILES_MACHINE_ARCH:-arm64}" \
  DOTFILES_BOOTSTRAP_SKIP_GIT_DEPS=1 \
    "$repo_root/bin/dotfiles-bootstrap" "$@"
}

run_bootstrap_home() {
  bootstrap_home=$1
  shift
  HOME="$bootstrap_home" \
  TEST_LOG="$test_log" \
  DOTFILES_ROOT="$repo_root" \
  DOTFILES_BREW_BIN="$test_tmp/bin/brew" \
  DOTFILES_RCUP_BIN="$test_tmp/bin/rcup" \
  DOTFILES_DOCTOR_BIN="$test_tmp/bin/doctor" \
  DOTFILES_MISE_BIN="$test_tmp/bin/mise" \
  DOTFILES_MACHINE_ARCH=arm64 \
  DOTFILES_BOOTSTRAP_SKIP_GIT_DEPS=1 \
    "$repo_root/bin/dotfiles-bootstrap" "$@"
}

: >"$test_log"
mkdir -p "$test_tmp/home/.codex"
: >"$test_tmp/home/.codex/AGENTS.md"
run_bootstrap --optional >/dev/null
grep -Fqx "brew:bundle install --no-upgrade --file $repo_root/Brewfile" "$test_log" || \
  fail 'default bootstrap must install core without upgrading'
grep -Fqx "brew:bundle install --no-upgrade --file $repo_root/Brewfile.optional" "$test_log" || \
  fail 'optional bootstrap must install optional tools without upgrading'
grep -Fqx "rcup:RCRC=$repo_root/rcrc args=-d $repo_root" "$test_log" || \
  fail 'bootstrap must invoke rcup with the repository rcrc'
grep -Fqx 'mise:install --locked -y' "$test_log" || \
  fail 'bootstrap must install locked mise runtimes'
rcup_line=$(grep -n '^rcup:' "$test_log" | cut -d: -f1)
mise_line=$(grep -n '^mise:' "$test_log" | cut -d: -f1)
[ "$rcup_line" -lt "$mise_line" ] || fail 'mise install must run after rcup'
[ ! -e "$test_tmp/home/.codex/AGENTS.md" ] || \
  fail 'bootstrap must move the legacy empty Codex instructions before rcup'
[ -f "$test_tmp/home/.codex/AGENTS.md.pre-dotfiles" ] || \
  fail 'bootstrap must preserve the legacy empty Codex instructions'
grep -Fqx 'doctor:--optional' "$test_log" || \
  fail 'bootstrap must run the optional doctor'
pass 'default bootstrap is no-upgrade and includes optional tools only on request'

: >"$test_log"
run_bootstrap --upgrade >/dev/null
grep -Fqx "brew:bundle install --upgrade --file $repo_root/Brewfile" "$test_log" || \
  fail '--upgrade must be explicit'
if grep -q -- '--no-upgrade' "$test_log"; then
  fail '--upgrade must not also pass --no-upgrade'
fi
pass '--upgrade is explicit'

upgrade_home=$test_tmp/upgrade-home
mkdir -p "$upgrade_home/.oh-my-zsh/.git" "$upgrade_home/.tmux/plugins/tpm/.git"
: >"$test_log"
HOME="$upgrade_home" \
TEST_LOG="$test_log" \
DOTFILES_ROOT="$repo_root" \
DOTFILES_BREW_BIN="$test_tmp/bin/brew" \
DOTFILES_RCUP_BIN="$test_tmp/bin/rcup" \
DOTFILES_DOCTOR_BIN="$test_tmp/bin/doctor" \
DOTFILES_MISE_BIN="$test_tmp/bin/mise" \
DOTFILES_GIT_BIN="$test_tmp/bin/git-deps" \
DOTFILES_MACHINE_ARCH=arm64 \
  "$repo_root/bin/dotfiles-bootstrap" --upgrade >/dev/null
grep -Fq "git:$upgrade_home/.oh-my-zsh:fetch:" "$test_log" || \
  fail '--upgrade must fetch the pinned Oh My Zsh revision'
grep -Fq "git:$upgrade_home/.tmux/plugins/tpm:fetch:" "$test_log" || \
  fail '--upgrade must fetch the pinned TPM revision'
[ -f "$upgrade_home/.oh-my-zsh/.dotfiles-upgraded" ] || \
  fail '--upgrade did not move Oh My Zsh to its pin'
[ -f "$upgrade_home/.tmux/plugins/tpm/.dotfiles-upgraded" ] || \
  fail '--upgrade did not move TPM to its pin'
pass '--upgrade moves existing Git dependencies to verified pins'

: >"$test_log"
run_bootstrap --check --optional >/dev/null
grep -Fqx 'doctor:--optional' "$test_log" || fail '--check must invoke doctor'
if grep -Eq '^(brew|rcup|mise):' "$test_log"; then
  fail '--check must not install packages, runtimes, or run rcup'
fi
pass '--check is read-only'

: >"$test_log"
if run_bootstrap --check --upgrade >/dev/null 2>&1; then
  fail '--check and --upgrade must be rejected together'
fi
[ ! -s "$test_log" ] || fail 'invalid options must not run commands'
pass 'conflicting bootstrap modes are rejected'

: >"$test_log"
if DOTFILES_MACHINE_ARCH=x86_64 run_bootstrap >/dev/null 2>&1; then
  fail 'bootstrap must reject architectures missing from the mise lock'
fi
[ ! -s "$test_log" ] || \
  fail 'unsupported architecture must fail before package or link mutation'
pass 'unsupported macOS architectures fail before mutation'

nonempty_home=$test_tmp/nonempty-home
mkdir -p "$nonempty_home/.codex"
printf '%s\n' 'keep me' >"$nonempty_home/.codex/AGENTS.md"
: >"$test_log"
if HOME="$nonempty_home" \
  TEST_LOG="$test_log" \
  DOTFILES_ROOT="$repo_root" \
  DOTFILES_BREW_BIN="$test_tmp/bin/brew" \
  DOTFILES_RCUP_BIN="$test_tmp/bin/rcup" \
  DOTFILES_DOCTOR_BIN="$test_tmp/bin/doctor" \
  DOTFILES_MISE_BIN="$test_tmp/bin/mise" \
  DOTFILES_BOOTSTRAP_SKIP_GIT_DEPS=1 \
  "$repo_root/bin/dotfiles-bootstrap" >/dev/null 2>&1; then
  fail 'bootstrap must refuse non-empty Codex instruction conflicts'
fi
grep -Fqx 'keep me' "$nonempty_home/.codex/AGENTS.md" || \
  fail 'bootstrap must not alter non-empty Codex instructions'
if [ -s "$test_log" ]; then
  fail 'Codex instruction conflicts must fail before package or link mutation'
fi
pass 'Codex instruction migration is narrow and recoverable'

linked_codex_home=$test_tmp/linked-codex-home
mkdir -p "$linked_codex_home/.codex"
ln -s "$repo_root/codex/AGENTS.md" "$linked_codex_home/.codex/AGENTS.md"
: >"$test_log"
run_bootstrap_home "$linked_codex_home" >/dev/null
[ "$linked_codex_home/.codex/AGENTS.md" -ef "$repo_root/codex/AGENTS.md" ] || \
  fail 'bootstrap must accept the expected Codex instructions symlink'

dangling_codex_home=$test_tmp/dangling-codex-home
mkdir -p "$dangling_codex_home/.codex"
ln -s "$dangling_codex_home/missing" \
  "$dangling_codex_home/.codex/AGENTS.md"
: >"$test_log"
if run_bootstrap_home "$dangling_codex_home" >/dev/null 2>&1; then
  fail 'bootstrap must refuse a dangling Codex instructions symlink'
fi
[ ! -s "$test_log" ] || \
  fail 'Codex symlink conflicts must fail before package or link mutation'
[ -L "$dangling_codex_home/.codex/AGENTS.md" ] || \
  fail 'bootstrap must preserve a conflicting Codex symlink'

foreign_codex_home=$test_tmp/foreign-codex-home
mkdir -p "$foreign_codex_home/.codex"
printf '%s\n' foreign >"$foreign_codex_home/instructions.md"
ln -s "$foreign_codex_home/instructions.md" \
  "$foreign_codex_home/.codex/AGENTS.md"
: >"$test_log"
if run_bootstrap_home "$foreign_codex_home" >/dev/null 2>&1; then
  fail 'bootstrap must refuse a foreign Codex instructions symlink'
fi
[ ! -s "$test_log" ] || \
  fail 'foreign Codex instructions must fail before package or link mutation'
[ "$foreign_codex_home/.codex/AGENTS.md" -ef \
  "$foreign_codex_home/instructions.md" ] || \
  fail 'bootstrap must preserve foreign Codex instructions'
pass 'Codex symlinks are accepted only when they resolve to Claude-backed instructions'

mise_migration_home=$test_tmp/mise-migration-home
mkdir -p "$mise_migration_home/.config/mise"
printf '%s\n' 'legacy mise config' > \
  "$mise_migration_home/.config/mise/config.toml"
: >"$test_log"
run_bootstrap_home "$mise_migration_home" >/dev/null
[ ! -e "$mise_migration_home/.config/mise/config.toml" ] || \
  fail 'bootstrap must move the previous Mise config before rcup'
grep -Fqx 'legacy mise config' \
  "$mise_migration_home/.config/mise/config.toml.pre-dotfiles" || \
  fail 'bootstrap must preserve the previous Mise config exactly'

mise_conflict_home=$test_tmp/mise-conflict-home
mkdir -p "$mise_conflict_home/.config/mise"
printf '%s\n' current >"$mise_conflict_home/.config/mise/config.toml"
printf '%s\n' backup > \
  "$mise_conflict_home/.config/mise/config.toml.pre-dotfiles"
: >"$test_log"
if run_bootstrap_home "$mise_conflict_home" >/dev/null 2>&1; then
  fail 'bootstrap must refuse to overwrite a previous Mise backup'
fi
[ ! -s "$test_log" ] || \
  fail 'Mise migration conflicts must fail before package or link mutation'
grep -Fqx current "$mise_conflict_home/.config/mise/config.toml" || \
  fail 'bootstrap must preserve a conflicting Mise config'
grep -Fqx backup \
  "$mise_conflict_home/.config/mise/config.toml.pre-dotfiles" || \
  fail 'bootstrap must preserve an existing Mise backup'

for mise_link_kind in dangling foreign; do
  mise_link_home=$test_tmp/mise-$mise_link_kind-link-home
  mkdir -p "$mise_link_home/.config/mise"
  mise_link_target=$mise_link_home/missing.toml
  if [ "$mise_link_kind" = foreign ]; then
    printf '%s\n' foreign >"$mise_link_target"
  fi
  ln -s "$mise_link_target" "$mise_link_home/.config/mise/config.toml"
  : >"$test_log"
  if run_bootstrap_home "$mise_link_home" >/dev/null 2>&1; then
    fail "bootstrap must refuse a $mise_link_kind Mise config symlink"
  fi
  [ ! -s "$test_log" ] || \
    fail "$mise_link_kind Mise conflicts must fail before package mutation"
  [ -L "$mise_link_home/.config/mise/config.toml" ] || \
    fail "bootstrap must preserve a $mise_link_kind Mise config symlink"
done
pass 'Mise config migration is recoverable and preflighted'

standalone_mise_home=$test_tmp/standalone-mise-home
mkdir -p "$standalone_mise_home/.local/bin"
printf '%s\n' 'old standalone mise' >"$standalone_mise_home/.local/bin/mise"
: >"$test_log"
run_bootstrap_home "$standalone_mise_home" >/dev/null
[ ! -e "$standalone_mise_home/.local/bin/mise" ] || \
  fail 'bootstrap must move the standalone Mise before rcup'
grep -Fqx 'old standalone mise' \
  "$standalone_mise_home/.local/bin/mise.pre-dotfiles" || \
  fail 'bootstrap must preserve the standalone Mise exactly'
run_bootstrap_home "$standalone_mise_home" >/dev/null || \
  fail 'standalone Mise migration must be idempotent'

homebrew_mise_link_home=$test_tmp/homebrew-mise-link-home
mkdir -p "$homebrew_mise_link_home/.local/bin"
ln -s /opt/homebrew/bin/mise "$homebrew_mise_link_home/.local/bin/mise"
: >"$test_log"
run_bootstrap_home "$homebrew_mise_link_home" >/dev/null || \
  fail 'bootstrap must accept a standalone path delegating to Homebrew Mise'
doctor_output=$(HOME="$homebrew_mise_link_home" \
  PATH=/usr/bin:/bin \
  DOTFILES_ROOT="$repo_root" \
  "$repo_root/bin/dotfiles-doctor" 2>&1 || true)
printf '%s\n' "$doctor_output" | grep -Fq \
  '[ok]   standalone Mise path delegates to the Homebrew-owned command' || \
  fail 'doctor must accept a standalone path delegating to Homebrew Mise'
pass 'standalone Mise migration leaves Homebrew as the single owner'

retired_home=$test_tmp/retired-home
mkdir -p "$retired_home/.zsh/completion"
ln -s "$repo_root/CLAUDE.md" "$retired_home/.CLAUDE.md"
ln -s "$repo_root/AGENTS.md" "$retired_home/.AGENTS.md"
ln -s "$repo_root/agrc" "$retired_home/.agrc"
ln -s "$repo_root/zsh/completion/_ag" "$retired_home/.zsh/completion/_ag"
: >"$test_log"
run_bootstrap_home "$retired_home" >/dev/null
for retired_link in \
  "$retired_home/.CLAUDE.md" \
  "$retired_home/.AGENTS.md" \
  "$retired_home/.agrc" \
  "$retired_home/.zsh/completion/_ag"; do
  [ ! -L "$retired_link" ] || \
    fail "bootstrap did not remove owned retired symlink: $retired_link"
done
second_retired_run=$(run_bootstrap_home "$retired_home") || \
  fail 'retired symlink cleanup must be idempotent'
case "$second_retired_run" in
  *'Removed retired'*) fail 'rerun tried to remove an already retired link' ;;
esac

foreign_root_home=$test_tmp/foreign-root-home
mkdir -p "$foreign_root_home"
printf '%s\n' 'keep my instructions' >"$foreign_root_home/.CLAUDE.md"
: >"$test_log"
if run_bootstrap_home "$foreign_root_home" >/dev/null 2>&1; then
  fail 'bootstrap must refuse foreign root agent instructions'
fi
[ ! -s "$test_log" ] || \
  fail 'root instruction conflicts must fail before package or link mutation'
grep -Fqx 'keep my instructions' "$foreign_root_home/.CLAUDE.md" || \
  fail 'bootstrap must preserve foreign root agent instructions'

foreign_root_link_home=$test_tmp/foreign-root-link-home
mkdir -p "$foreign_root_link_home"
printf '%s\n' 'foreign root instructions' > \
  "$foreign_root_link_home/instructions.md"
ln -s "$foreign_root_link_home/instructions.md" \
  "$foreign_root_link_home/.AGENTS.md"
: >"$test_log"
if run_bootstrap_home "$foreign_root_link_home" >/dev/null 2>&1; then
  fail 'bootstrap must refuse a foreign root instruction symlink'
fi
[ ! -s "$test_log" ] || \
  fail 'foreign root symlinks must fail before package or link mutation'
[ "$foreign_root_link_home/.AGENTS.md" -ef \
  "$foreign_root_link_home/instructions.md" ] || \
  fail 'bootstrap must preserve a foreign root instruction symlink'
pass 'retired symlink cleanup is exact and foreign instructions are preserved'

if HOME="$test_tmp/home" \
  DOTFILES_ROOT="$repo_root" \
  DOTFILES_BREW_BIN="$test_tmp/bin/missing-brew" \
  DOTFILES_RCUP_BIN="$test_tmp/bin/rcup" \
  DOTFILES_DOCTOR_BIN="$test_tmp/bin/doctor" \
  DOTFILES_MISE_BIN="$test_tmp/bin/mise" \
  "$repo_root/bin/dotfiles-bootstrap" >/dev/null 2>&1; then
  fail 'bootstrap must fail clearly when Homebrew is missing'
fi
pass 'missing Homebrew is rejected before mutation'

is_globally_ignored() {
  git -C "$test_tmp/ignore-repo" \
    -c core.excludesFile="$repo_root/gitignore" \
    check-ignore --no-index -q -- "$1"
}

is_globally_ignored '.DS_Store' || fail '.DS_Store should be globally ignored'
is_globally_ignored 'scratch.swp' || fail 'editor swap files should be globally ignored'
is_globally_ignored 'tags' || fail 'root tags should be globally ignored'
is_globally_ignored 'TAGS' || fail 'root TAGS should be globally ignored'
for project_file in \
  .claude .env .tool-versions uv.lock node_modules/example package.log \
  tags.lock tags.temp docs/tags; do
  if is_globally_ignored "$project_file"; then
    fail "$project_file must be decided by each repository"
  fi
done
pass 'global ignore contains only OS/editor artifacts'

git -C "$repo_root" -c core.excludesFile=/dev/null \
  check-ignore --no-index -q -- 'config/.DS_Store' || \
  fail 'the repository must ignore nested .DS_Store without the global file'
pass 'repository-local ignore protects macOS metadata'

if command -v lsrc >/dev/null 2>&1; then
  rcm_output=$(HOME="$test_tmp/home" RCRC="$repo_root/rcrc" \
    lsrc -d "$repo_root")
  ignored_sources=
  old_ifs=$IFS
  IFS='
'
  for mapping in $rcm_output; do
    source_path=${mapping#*:}
    case "$source_path" in
      "$repo_root"/*)
        relative_path=${source_path#"$repo_root"/}
        if git -C "$repo_root" \
          -c core.excludesFile="$repo_root/gitignore" \
          check-ignore -q -- "$relative_path" 2>/dev/null; then
          ignored_sources="${ignored_sources}${ignored_sources:+, }$relative_path"
        fi
        ;;
    esac
  done
  IFS=$old_ifs
  [ -z "$ignored_sources" ] || fail "rcm includes ignored files: $ignored_sources"
  if printf '%s\n' "$rcm_output" | \
    grep -Eq ":$repo_root/(AGENTS\.md|CLAUDE\.md)$"; then
    fail 'rcm must exclude repository instruction files'
  fi
  for nested_instruction in \
    claude/CLAUDE.md \
    codex/AGENTS.md \
    config/nvim/CLAUDE.md \
    config/nvim/AGENTS.md; do
    printf '%s\n' "$rcm_output" | \
      grep -Fq ":$repo_root/$nested_instruction" || \
      fail "rcm must retain nested instruction mapping: $nested_instruction"
  done
  pass 'rcm excludes every Git-ignored source'
fi

if grep -Eq 'brew bundle|curl|git clone|Plug(Update|Clean)|agent-config|link-agent' \
  "$repo_root/hooks/post-up"; then
  fail 'post-up must not install, download, or upgrade software'
fi
HOME="$test_tmp/home" "$repo_root/hooks/post-up" >/dev/null
[ -d "$test_tmp/home/.cache/nvim/tags" ] || fail 'post-up must create the Neovim tag cache'
pass 'post-up is local and idempotent'

resolved_path=$(HOME="$test_tmp/home" PATH=/usr/bin:/bin zsh -fc \
  ". '$repo_root/zsh/configs/post/path.zsh'; print -r -- \"\$PATH\"")
case ":$resolved_path:" in
  *":/opt/homebrew/bin:$test_tmp/home/.local/bin:"*) ;;
  *) fail 'Homebrew must precede ~/.local/bin so it owns the mise command' ;;
esac
pass 'interactive PATH prefers Homebrew Mise over the retired standalone install'

grep -Fq 'brew "rcm"' "$repo_root/Brewfile" || fail 'core Brewfile must install rcm'
grep -Fq 'brew "herdr"' "$repo_root/Brewfile" || fail 'core Brewfile must install Herdr'
for core_formula in \
  git git-lfs coreutils gawk uv diff-so-fancy shellcheck shfmt stylua macvim; do
  grep -Fq "brew \"$core_formula\"" "$repo_root/Brewfile" || \
    fail "core Brewfile must install $core_formula"
done
grep -Fq 'mise mvim nvim' "$repo_root/bin/dotfiles-doctor" || \
  fail 'doctor must check the mvim command'
grep -Fq 'bundle check --no-upgrade' "$repo_root/bin/dotfiles-doctor" || \
  fail 'doctor must not require upgrades in default check mode'
grep -Fq 'HOMEBREW_NO_AUTO_UPDATE=1' "$repo_root/bin/dotfiles-doctor" || \
  fail 'doctor must not update Homebrew state during a read-only check'
grep -Fq 'brew "griffinqiu/tap/bootmux"' "$repo_root/Brewfile" || \
  fail 'core Brewfile must install Bootmux from its tap'
grep -Fq 'brew "reattach-to-user-namespace"' "$repo_root/Brewfile.optional" || \
  fail 'optional Brewfile must retain reattach-to-user-namespace'
grep -Fq 'brew "zellij"' "$repo_root/Brewfile.optional" || \
  fail 'optional Brewfile must include Zellij'
if rg -q 'homebrew/cask-fonts' \
  "$repo_root/Brewfile" "$repo_root/Brewfile.optional"; then
  fail 'Brewfiles must not restore obsolete Homebrew entries'
fi
pass 'Brewfiles contain the expected modern package boundary'

if grep -Eq '=[[:space:]]*"(latest|stable|lts)"|cargo:bootmux' \
  "$repo_root/config/mise/config.toml"; then
  fail 'mise config must use exact pins and leave Bootmux to Homebrew'
fi
pass 'mise tools use exact pins'

if command -v mise >/dev/null 2>&1; then
  HOME="$test_tmp/home" \
  MISE_GLOBAL_CONFIG_FILE="$repo_root/config/mise/config.toml" \
  MISE_GLOBAL_CONFIG_ROOT="$repo_root/config/mise" \
  MISE_IGNORED_CONFIG_PATHS="$original_home/.config/mise/config.toml" \
  MISE_DATA_DIR="$test_tmp/mise-data" \
  MISE_CACHE_DIR="$test_tmp/mise-cache" \
  MISE_STATE_DIR="$test_tmp/mise-state" \
  MISE_INSTALLS_DIR="$test_tmp/mise-installs" \
  RUSTUP_HOME="$test_tmp/rustup" \
  CARGO_HOME="$test_tmp/cargo" \
    mise install --locked -y --dry-run >/dev/null || \
    fail 'mise lock must resolve completely in locked mode'
  pass 'mise lock resolves in locked dry-run mode'
fi

sh -n "$repo_root/bin/dotfiles-bootstrap"
sh -n "$repo_root/bin/dotfiles-doctor"
sh -n "$repo_root/hooks/post-up"
sh -n "$repo_root/test/bootstrap.sh"
pass 'shell syntax'
