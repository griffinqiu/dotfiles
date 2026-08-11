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

skip() {
  printf 'ok - %s # SKIP\n' "$*"
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

cat >"$test_tmp/bin/nvim-plugin-runner" <<'EOF'
#!/bin/sh
printf 'plugin:nvim:%s\n' "$*" >>"$TEST_LOG"
EOF

cat >"$test_tmp/bin/tpm-plugin-runner" <<'EOF'
#!/bin/sh
printf 'plugin:tpm:%s\n' "$*" >>"$TEST_LOG"
EOF

cat >"$test_tmp/bin/nvim-built-in" <<'EOF'
#!/bin/sh
printf 'nvim-built-in:%s\n' "$*" >>"$TEST_LOG"
EOF

cat >"$test_tmp/bin/tmux-built-in" <<'EOF'
#!/bin/sh
printf 'tmux-built-in:%s\n' "$*" >>"$TEST_LOG"
EOF

cat >"$test_tmp/bin/brew-prefix" <<'EOF'
#!/bin/sh
printf 'brew-prefix:%s\n' "$*" >>"$TEST_LOG"
if [ "$*" = '--prefix rcm' ]; then
  printf '%s\n' "$TEST_RCM_PREFIX"
  exit 0
fi
exit 82
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
        */tpm) printf '%s\n' "$TEST_TPM_REV" ;;
        */zsh-autosuggestions) printf '%s\n' "$TEST_ZSH_AUTOSUGGESTIONS_REV" ;;
        */zsh-syntax-highlighting) printf '%s\n' "$TEST_ZSH_SYNTAX_HIGHLIGHTING_REV" ;;
        */.oh-my-zsh) printf '%s\n' "$TEST_OMZ_REV" ;;
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
  "$test_tmp/bin/nvim-plugin-runner" \
  "$test_tmp/bin/tpm-plugin-runner" \
  "$test_tmp/bin/nvim-built-in" \
  "$test_tmp/bin/tmux-built-in" \
  "$test_tmp/bin/brew-prefix" \
  "$test_tmp/bin/git-deps"

TEST_TPM_REV=99469c4a9b1ccf77fade25842dc7bafbc8ce9946
TEST_OMZ_REV=97b27bb2ec0701330b18c2d3e340b22e742b3fa8
TEST_ZSH_AUTOSUGGESTIONS_REV=85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
TEST_ZSH_SYNTAX_HIGHLIGHTING_REV=c4d95591843d49838b7ad30081e7aba3135a6703
TEST_RCM_PREFIX=$test_tmp/rcm-prefix
mkdir -p "$TEST_RCM_PREFIX/bin"
cat >"$TEST_RCM_PREFIX/bin/rcup" <<'EOF'
#!/bin/sh
printf 'rcup-prefix:RCRC=%s args=%s\n' "${RCRC:-}" "$*" >>"$TEST_LOG"
EOF
chmod +x "$TEST_RCM_PREFIX/bin/rcup"
export TEST_TPM_REV TEST_OMZ_REV TEST_ZSH_AUTOSUGGESTIONS_REV \
  TEST_ZSH_SYNTAX_HIGHLIGHTING_REV TEST_RCM_PREFIX

run_bootstrap() {
  HOME="$test_tmp/home" \
    TEST_LOG="$test_log" \
    DOTFILES_ROOT="$repo_root" \
    DOTFILES_BREW_BIN="$test_tmp/bin/brew" \
    DOTFILES_RCUP_BIN="$test_tmp/bin/rcup" \
    DOTFILES_DOCTOR_BIN="$test_tmp/bin/doctor" \
    DOTFILES_MISE_BIN="$test_tmp/bin/mise" \
    DOTFILES_NVIM_PLUGIN_RUNNER="$test_tmp/bin/nvim-plugin-runner" \
    DOTFILES_TPM_PLUGIN_RUNNER="$test_tmp/bin/tpm-plugin-runner" \
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
    DOTFILES_NVIM_PLUGIN_RUNNER="$test_tmp/bin/nvim-plugin-runner" \
    DOTFILES_TPM_PLUGIN_RUNNER="$test_tmp/bin/tpm-plugin-runner" \
    DOTFILES_MACHINE_ARCH=arm64 \
    DOTFILES_BOOTSTRAP_SKIP_GIT_DEPS=1 \
    "$repo_root/bin/dotfiles-bootstrap" "$@"
}

builtin_plugin_home=$test_tmp/builtin-plugin-home
builtin_plugin_root=$test_tmp/plugin-only-root
mkdir -p \
  "$builtin_plugin_home/.cache" \
  "$builtin_plugin_home/.config/nvim" \
  "$builtin_plugin_home/.local/share" \
  "$builtin_plugin_home/.local/state" \
  "$builtin_plugin_home/.tmux/plugins/tpm/bin" \
  "$builtin_plugin_root/config/nvim/lua/config"
printf '%s\n' '-- minimal Neovim configuration' > \
  "$builtin_plugin_home/.config/nvim/init.lua"
printf '%s\n' '# minimal tmux configuration' > \
  "$builtin_plugin_home/.tmux.conf"
printf '%s\n' '-- executed only by real Neovim fixtures' > \
  "$builtin_plugin_root/config/nvim/lua/config/plugin-sync.lua"
builtin_plugin_root=$(CDPATH= cd -P -- "$builtin_plugin_root" && pwd)

cat >"$builtin_plugin_home/.tmux/plugins/tpm/bin/install_plugins" <<'EOF'
#!/bin/sh
printf 'tpm-built-in:install:%s\n' "$*" >>"$TEST_LOG"
EOF

cat >"$builtin_plugin_home/.tmux/plugins/tpm/bin/update_plugins" <<'EOF'
#!/bin/sh
printf 'tpm-built-in:update:%s\n' "$*" >>"$TEST_LOG"
if [ -n "${TEST_TPM_UPDATE_OUTPUT:-}" ]; then
  printf '%s\n' "$TEST_TPM_UPDATE_OUTPUT"
fi
exit "${TEST_TPM_UPDATE_STATUS:-0}"
EOF

chmod +x \
  "$builtin_plugin_home/.tmux/plugins/tpm/bin/install_plugins" \
  "$builtin_plugin_home/.tmux/plugins/tpm/bin/update_plugins"

run_builtin_plugins() {
  HOME="$builtin_plugin_home" \
    PATH=/usr/bin:/bin \
    XDG_CACHE_HOME="$builtin_plugin_home/.cache" \
    XDG_CONFIG_HOME="$builtin_plugin_home/.config" \
    XDG_DATA_HOME="$builtin_plugin_home/.local/share" \
    XDG_STATE_HOME="$builtin_plugin_home/.local/state" \
    TEST_LOG="$test_log" \
    TEST_TPM_UPDATE_OUTPUT="${TEST_TPM_UPDATE_OUTPUT:-}" \
    TEST_TPM_UPDATE_STATUS="${TEST_TPM_UPDATE_STATUS:-0}" \
    DOTFILES_ROOT="$builtin_plugin_root" \
    DOTFILES_BREW_BIN="$test_tmp/bin/missing-brew" \
    DOTFILES_DOCTOR_BIN="$test_tmp/bin/missing-doctor" \
    DOTFILES_MACHINE_ARCH=arm64 \
    DOTFILES_NVIM_PLUGIN_RUNNER= \
    DOTFILES_TPM_PLUGIN_RUNNER= \
    DOTFILES_NVIM_BIN="$test_tmp/bin/nvim-built-in" \
    DOTFILES_TMUX_BIN="$test_tmp/bin/tmux-built-in" \
    "$repo_root/bin/dotfiles-bootstrap" "$@"
}

run_real_nvim_plugins() {
  real_nvim_home=$1
  shift
  HOME="$real_nvim_home" \
    TMPDIR="$test_tmp" \
    XDG_CACHE_HOME="$real_nvim_home/.cache" \
    XDG_CONFIG_HOME="$real_nvim_home/.config" \
    XDG_DATA_HOME="$real_nvim_home/.local/share" \
    XDG_STATE_HOME="$real_nvim_home/.local/state" \
    NVIM_APPNAME=nvim \
    TEST_LOG="$test_log" \
    DOTFILES_ROOT="$repo_root" \
    DOTFILES_BREW_BIN="$test_tmp/bin/missing-brew" \
    DOTFILES_DOCTOR_BIN="$test_tmp/bin/missing-doctor" \
    DOTFILES_MACHINE_ARCH=arm64 \
    DOTFILES_NVIM_PLUGIN_RUNNER= \
    DOTFILES_TPM_PLUGIN_RUNNER="$test_tmp/bin/tpm-plugin-runner" \
    DOTFILES_NVIM_BIN="$real_nvim_bin" \
    "$repo_root/bin/dotfiles-bootstrap" --only plugins "$@"
}

: >"$test_log"
mkdir -p "$test_tmp/home/.codex"
: >"$test_tmp/home/.codex/AGENTS.md"
run_bootstrap --optional >/dev/null
grep -Fqx "brew:bundle install --no-upgrade --file $repo_root/Brewfile" "$test_log" ||
  fail 'default bootstrap must install core without upgrading'
grep -Fqx "brew:bundle install --no-upgrade --file $repo_root/Brewfile.optional" "$test_log" ||
  fail 'optional bootstrap must install optional tools without upgrading'
grep -Fqx "rcup:RCRC=$repo_root/rcrc args=-d $repo_root" "$test_log" ||
  fail 'bootstrap must invoke rcup with the repository rcrc'
grep -Fqx 'mise:install --locked -y' "$test_log" ||
  fail 'bootstrap must install locked mise runtimes'
rcup_line=$(grep -n '^rcup:' "$test_log" | cut -d: -f1)
mise_line=$(grep -n '^mise:' "$test_log" | cut -d: -f1)
first_plugin_line=$(grep -n '^plugin:' "$test_log" | sed -n '1s/:.*//p')
[ "$rcup_line" -lt "$mise_line" ] || fail 'mise install must run after rcup'
[ "$mise_line" -lt "$first_plugin_line" ] ||
  fail 'plugin installation must run after locked runtimes'
grep -Fqx 'plugin:nvim:install' "$test_log" ||
  fail 'default bootstrap must install Neovim plugins'
grep -Fqx 'plugin:tpm:install' "$test_log" ||
  fail 'default bootstrap must install tmux plugins'
[ ! -e "$test_tmp/home/.codex/AGENTS.md" ] ||
  fail 'bootstrap must move the legacy empty Codex instructions before rcup'
[ -f "$test_tmp/home/.codex/AGENTS.md.pre-dotfiles" ] ||
  fail 'bootstrap must preserve the legacy empty Codex instructions'
if grep -q '^doctor:' "$test_log"; then
  fail 'default bootstrap must leave doctor as an independent command'
fi
pass 'default bootstrap installs every component without running doctor'

: >"$test_log"
run_bootstrap --only packages >/dev/null
grep -Fqx "brew:bundle install --no-upgrade --file $repo_root/Brewfile" \
  "$test_log" || fail 'packages component must install the core Brewfile'
if grep -Eq '^(rcup|mise|plugin:|doctor:)' "$test_log"; then
  fail 'packages component must not run links, runtimes, plugins, or doctor'
fi

: >"$test_log"
run_bootstrap --only links >/dev/null
grep -Fqx "rcup:RCRC=$repo_root/rcrc args=-d $repo_root" "$test_log" ||
  fail 'links component must invoke rcup'
if grep -Eq '^(brew|mise|plugin:|doctor:)' "$test_log"; then
  fail 'links component must not run packages, runtimes, plugins, or doctor'
fi

mkdir -p "$test_tmp/home/dotfiles-local"
: >"$test_log"
run_bootstrap --only links >/dev/null
grep -Fqx \
  "rcup:RCRC=$repo_root/rcrc args=-d $test_tmp/home/dotfiles-local -d $repo_root" \
  "$test_log" ||
  fail 'links must give rcup the local override before the repository'
rmdir "$test_tmp/home/dotfiles-local"
pass 'local dotfiles take precedence over repository links'

prefix_rcup_home=$test_tmp/prefix-rcup-home
mkdir -p "$prefix_rcup_home"
: >"$test_log"
HOME="$prefix_rcup_home" \
  PATH=/usr/bin:/bin \
  TEST_LOG="$test_log" \
  TEST_RCM_PREFIX="$TEST_RCM_PREFIX" \
  DOTFILES_ROOT="$repo_root" \
  DOTFILES_BREW_BIN="$test_tmp/bin/brew-prefix" \
  DOTFILES_RCUP_BIN= \
  DOTFILES_MACHINE_ARCH=arm64 \
  "$repo_root/bin/dotfiles-bootstrap" --only links >/dev/null
grep -Fqx 'brew-prefix:--prefix rcm' "$test_log" || \
  fail 'links must ask Homebrew for the rcm prefix when rcup is not on PATH'
grep -Fqx \
  "rcup-prefix:RCRC=$repo_root/rcrc args=-d $repo_root" "$test_log" || \
  fail 'links must execute rcup resolved from the Homebrew rcm prefix'
pass 'rcup resolves from Homebrew without relying on shell PATH refresh'

: >"$test_log"
run_bootstrap --only runtimes >/dev/null
grep -Fqx 'mise:install --locked -y' "$test_log" ||
  fail 'runtimes component must install the locked mise tools'
if grep -Eq '^(brew|rcup|plugin:|doctor:)' "$test_log"; then
  fail 'runtimes component must not run packages, links, plugins, or doctor'
fi

: >"$test_log"
run_bootstrap --only plugins >/dev/null
for plugin_runner in nvim tpm; do
  grep -Fqx "plugin:$plugin_runner:install" "$test_log" ||
    fail "plugins component must invoke the $plugin_runner install runner"
done
if grep -Eq '^(brew|rcup|mise|doctor:)' "$test_log"; then
  fail 'plugins component must not run packages, links, runtimes, or doctor'
fi

: >"$test_log"
run_builtin_plugins --only plugins >/dev/null
expected_nvim_install="nvim-built-in:--headless -n -u $builtin_plugin_home/.config/nvim/init.lua -l $builtin_plugin_root/config/nvim/lua/config/plugin-sync.lua install"
actual_nvim_install=$(grep '^nvim-built-in:' "$test_log" || true)
[ "$actual_nvim_install" = "$expected_nvim_install" ] || \
  fail "built-in plugin install argv mismatch: ${actual_nvim_install:-not called}"
grep -Fqx 'tpm-built-in:install:' "$test_log" ||
  fail 'built-in plugin install must run the TPM installer'
if grep -q '^tpm-built-in:update:' "$test_log"; then
  fail 'default built-in plugin install must not update TPM plugins'
fi
[ ! -e "$builtin_plugin_root/Brewfile" ] || \
  fail 'the plugin-only fixture must not provide a Brewfile'
[ ! -e "$builtin_plugin_root/rcrc" ] || \
  fail 'the plugin-only fixture must not provide an rcrc'
[ ! -e "$test_tmp/bin/missing-doctor" ] || \
  fail 'the plugin-only fixture must not provide a doctor'
pass 'built-in plugins are isolated from packages, links, and doctor'

: >"$test_log"
run_builtin_plugins --only plugins --upgrade >/dev/null
expected_nvim_update="nvim-built-in:--headless -n -u $builtin_plugin_home/.config/nvim/init.lua -l $builtin_plugin_root/config/nvim/lua/config/plugin-sync.lua update"
actual_nvim_update=$(grep '^nvim-built-in:' "$test_log" || true)
[ "$actual_nvim_update" = "$expected_nvim_update" ] || \
  fail "built-in plugin update argv mismatch: ${actual_nvim_update:-not called}"
grep -Fqx 'tpm-built-in:install:' "$test_log" ||
  fail 'built-in plugin upgrade must install missing TPM plugins first'
grep -Fqx 'tpm-built-in:update:all' "$test_log" ||
  fail 'built-in plugin upgrade must update every TPM plugin'
pass 'built-in plugin upgrade syncs Neovim and refreshes TPM safely'

: >"$test_log"
tpm_failure_output=$test_tmp/tpm-failure.out
if TEST_TPM_UPDATE_OUTPUT='update fail: broken plugin' \
  run_builtin_plugins --only plugins --upgrade \
  >"$tpm_failure_output" 2>&1; then
  fail 'TPM update failure output must fail bootstrap even with exit status 0'
fi
grep -Fq 'update fail: broken plugin' "$tpm_failure_output" || \
  fail 'bootstrap must preserve TPM failure output for diagnosis'
grep -Fq 'one or more TPM plugin updates failed' "$tpm_failure_output" || \
  fail 'bootstrap must explain a zero-status TPM update failure'
grep -Fqx 'tpm-built-in:update:all' "$test_log" || \
  fail 'the TPM failure fixture must exercise the built-in updater'
pass 'TPM failure text cannot be mistaken for a successful update'

real_nvim_bin=$(command -v nvim || true)
if [ -n "$real_nvim_bin" ]; then
  missing_lazy_home=$test_tmp/missing-lazy-home
  mkdir -p \
    "$missing_lazy_home/.cache" \
    "$missing_lazy_home/.config/nvim" \
    "$missing_lazy_home/.local/share" \
    "$missing_lazy_home/.local/state"
  printf '%s\n' '-- intentionally has no Lazy.nvim module' > \
    "$missing_lazy_home/.config/nvim/init.lua"
  : >"$test_log"
  missing_lazy_output=$test_tmp/missing-lazy.out
  if run_real_nvim_plugins "$missing_lazy_home" \
    >"$missing_lazy_output" 2>&1; then
    fail 'real Neovim without Lazy.nvim must not report plugin success'
  fi
  grep -Fq 'Lazy.nvim is unavailable' "$missing_lazy_output" || \
    fail 'missing Lazy.nvim failure must remain diagnosable'
  if grep -q '^plugin:tpm:' "$test_log"; then
    fail 'TPM must not run after real Neovim plugin synchronization fails'
  fi
  pass 'real Neovim propagates a missing Lazy.nvim failure'

  task_error_home=$test_tmp/task-error-home
  mkdir -p \
    "$task_error_home/.cache" \
    "$task_error_home/.config/nvim/lua/lazy/core" \
    "$task_error_home/.local/share" \
    "$task_error_home/.local/state"
  printf '%s\n' '-- fake Lazy.nvim modules live below this config' > \
    "$task_error_home/.config/nvim/init.lua"
  cat >"$task_error_home/.config/nvim/lua/lazy/init.lua" <<'EOF'
local M = {}

function M.install(_) end
function M.restore(_) end
function M.sync(_) end

return M
EOF
  cat >"$task_error_home/.config/nvim/lua/lazy/core/config.lua" <<'EOF'
local task = { name = "install" }

function task:has_errors()
  return true
end

function task:output(_)
  return "boom"
end

return {
  plugins = {
    broken = { _ = { tasks = { task } } },
  },
}
EOF
  : >"$test_log"
  task_error_output=$test_tmp/task-error.out
  if run_real_nvim_plugins "$task_error_home" \
    >"$task_error_output" 2>&1; then
    fail 'real Neovim must fail when Lazy reports task errors'
  fi
  grep -Fq 'Lazy restore reported plugin task errors' \
    "$task_error_output" || \
    fail 'Lazy task failure must identify the failed operation'
  grep -Fq 'broken:install: boom' "$task_error_output" || \
    fail 'Lazy task failure must retain the plugin, task, and output'
  if grep -q '^plugin:tpm:' "$test_log"; then
    fail 'TPM must not run after Lazy reports a plugin task error'
  fi
  pass 'real Neovim propagates Lazy plugin task errors'
else
  skip 'real Neovim missing-Lazy and task-error propagation tests'
fi

: >"$test_log"
run_bootstrap --only links,runtimes >/dev/null
grep -Fqx "rcup:RCRC=$repo_root/rcrc args=-d $repo_root" "$test_log" ||
  fail 'component combinations must include links when selected'
grep -Fqx 'mise:install --locked -y' "$test_log" ||
  fail 'component combinations must include runtimes when selected'
if grep -Eq '^(brew|plugin:|doctor:)' "$test_log"; then
  fail 'component combinations must run only their selected components'
fi
pass '--only selects one component or a comma-separated component set'

: >"$test_log"
run_bootstrap --only packages --optional >/dev/null
grep -Fqx "brew:bundle install --no-upgrade --file $repo_root/Brewfile.optional" \
  "$test_log" || fail '--optional must work with the packages component'
if grep -Eq '^(rcup|mise|plugin:|doctor:)' "$test_log"; then
  fail 'optional packages must not expand the selected component set'
fi
pass '--optional changes package scope without changing component scope'

: >"$test_log"
run_bootstrap --upgrade >/dev/null
grep -Fqx "brew:bundle install --upgrade --file $repo_root/Brewfile" "$test_log" ||
  fail '--upgrade must be explicit'
if grep -q -- '--no-upgrade' "$test_log"; then
  fail '--upgrade must not also pass --no-upgrade'
fi
for plugin_runner in nvim tpm; do
  grep -Fqx "plugin:$plugin_runner:update" "$test_log" ||
    fail "--upgrade must put the $plugin_runner plugin runner in update mode"
done
if grep -q '^doctor:' "$test_log"; then
  fail '--upgrade must leave doctor as an independent command'
fi
pass '--upgrade explicitly upgrades packages and plugins'

: >"$test_log"
run_bootstrap --only packages,plugins --upgrade >/dev/null
grep -Fqx "brew:bundle install --upgrade --file $repo_root/Brewfile" \
  "$test_log" || fail '--upgrade must affect selected packages'
for plugin_runner in nvim tpm; do
  grep -Fqx "plugin:$plugin_runner:update" "$test_log" ||
    fail "--upgrade must affect selected $plugin_runner plugins"
done
if grep -Eq '^(rcup|mise|doctor:)' "$test_log"; then
  fail 'upgrading packages and plugins must not run unselected components'
fi
pass '--upgrade respects a combined packages and plugins selection'

upgrade_home=$test_tmp/upgrade-home
mkdir -p "$upgrade_home/.tmux/plugins/tpm/.git" \
  "$upgrade_home/.oh-my-zsh/.git" \
  "$upgrade_home/.oh-my-zsh/custom/plugins/zsh-autosuggestions/.git" \
  "$upgrade_home/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/.git"
: >"$test_log"
HOME="$upgrade_home" \
  TEST_LOG="$test_log" \
  DOTFILES_ROOT="$repo_root" \
  DOTFILES_BREW_BIN="$test_tmp/bin/brew" \
  DOTFILES_RCUP_BIN="$test_tmp/bin/rcup" \
  DOTFILES_DOCTOR_BIN="$test_tmp/bin/doctor" \
  DOTFILES_MISE_BIN="$test_tmp/bin/mise" \
  DOTFILES_NVIM_PLUGIN_RUNNER="$test_tmp/bin/nvim-plugin-runner" \
  DOTFILES_TPM_PLUGIN_RUNNER="$test_tmp/bin/tpm-plugin-runner" \
  DOTFILES_GIT_BIN="$test_tmp/bin/git-deps" \
  DOTFILES_MACHINE_ARCH=arm64 \
  "$repo_root/bin/dotfiles-bootstrap" --upgrade >/dev/null
grep -Fq "git:$upgrade_home/.tmux/plugins/tpm:fetch:" "$test_log" ||
  fail '--upgrade must fetch the pinned TPM revision'
[ -f "$upgrade_home/.tmux/plugins/tpm/.dotfiles-upgraded" ] ||
  fail '--upgrade did not move TPM to its pin'
for omz_checkout in \
  "$upgrade_home/.oh-my-zsh" \
  "$upgrade_home/.oh-my-zsh/custom/plugins/zsh-autosuggestions" \
  "$upgrade_home/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"; do
  grep -Fq "git:$omz_checkout:fetch:" "$test_log" ||
    fail "--upgrade must fetch the pinned revision for $omz_checkout"
  [ -f "$omz_checkout/.dotfiles-upgraded" ] ||
    fail "--upgrade did not move $omz_checkout to its pin"
done
pass '--upgrade moves TPM, Oh My Zsh, and its custom plugins to their pins'

: >"$test_log"
run_bootstrap --check --optional >/dev/null
grep -Fqx 'doctor:--optional' "$test_log" || fail '--check must invoke doctor'
if grep -Eq '^(brew|rcup|mise|plugin:)' "$test_log"; then
  fail '--check must not install packages, links, runtimes, or plugins'
fi
pass '--check remains a read-only compatibility alias for doctor'

: >"$test_log"
if run_bootstrap --check --upgrade >/dev/null 2>&1; then
  fail '--check and --upgrade must be rejected together'
fi
[ ! -s "$test_log" ] || fail 'invalid options must not run commands'
pass 'conflicting bootstrap modes are rejected'

invalid_only_home=$test_tmp/invalid-only-home
mkdir -p "$invalid_only_home/.codex"
: >"$invalid_only_home/.codex/AGENTS.md"
for invalid_only in unknown all '*' '' packages,,links packages,unknown; do
  : >"$test_log"
  if run_bootstrap_home "$invalid_only_home" \
    --only "$invalid_only" >/dev/null 2>&1; then
    fail "--only must reject invalid component selection: $invalid_only"
  fi
  [ ! -s "$test_log" ] ||
    fail 'invalid component selections must not run any component'
  [ -f "$invalid_only_home/.codex/AGENTS.md" ] &&
    [ ! -s "$invalid_only_home/.codex/AGENTS.md" ] ||
    fail 'invalid component selections must not move user files'
  [ ! -e "$invalid_only_home/.codex/AGENTS.md.pre-dotfiles" ] ||
    fail 'invalid component selections must leave no migration backup'
done
pass 'unknown and empty component selections fail before mutation'

for invalid_scoped_options in \
  '--only links --optional' \
  '--only runtimes --upgrade' \
  '--check --only packages'; do
  : >"$test_log"
  # This intentionally splits the fixed test cases into CLI arguments.
  # shellcheck disable=SC2086
  if run_bootstrap $invalid_scoped_options >/dev/null 2>&1; then
    fail "bootstrap must reject options outside their component scope: $invalid_scoped_options"
  fi
  [ ! -s "$test_log" ] ||
    fail 'component option scope errors must fail before mutation'
done
pass 'component-specific options are rejected outside their valid scope'

: >"$test_log"
if DOTFILES_MACHINE_ARCH=x86_64 run_bootstrap >/dev/null 2>&1; then
  fail 'bootstrap must reject architectures missing from the mise lock'
fi
[ ! -s "$test_log" ] ||
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
grep -Fqx 'keep me' "$nonempty_home/.codex/AGENTS.md" ||
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
[ "$linked_codex_home/.codex/AGENTS.md" -ef "$repo_root/codex/AGENTS.md" ] ||
  fail 'bootstrap must accept the expected Codex instructions symlink'

dangling_codex_home=$test_tmp/dangling-codex-home
mkdir -p "$dangling_codex_home/.codex"
ln -s "$dangling_codex_home/missing" \
  "$dangling_codex_home/.codex/AGENTS.md"
: >"$test_log"
if run_bootstrap_home "$dangling_codex_home" >/dev/null 2>&1; then
  fail 'bootstrap must refuse a dangling Codex instructions symlink'
fi
[ ! -s "$test_log" ] ||
  fail 'Codex symlink conflicts must fail before package or link mutation'
[ -L "$dangling_codex_home/.codex/AGENTS.md" ] ||
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
[ ! -s "$test_log" ] ||
  fail 'foreign Codex instructions must fail before package or link mutation'
[ "$foreign_codex_home/.codex/AGENTS.md" -ef \
  "$foreign_codex_home/instructions.md" ] ||
  fail 'bootstrap must preserve foreign Codex instructions'
pass 'Codex symlinks are accepted only when they resolve to Claude-backed instructions'

mise_migration_home=$test_tmp/mise-migration-home
mkdir -p "$mise_migration_home/.config/mise"
printf '%s\n' 'legacy mise config' > \
  "$mise_migration_home/.config/mise/config.toml"
: >"$test_log"
run_bootstrap_home "$mise_migration_home" >/dev/null
[ ! -e "$mise_migration_home/.config/mise/config.toml" ] ||
  fail 'bootstrap must move the previous Mise config before rcup'
grep -Fqx 'legacy mise config' \
  "$mise_migration_home/.config/mise/config.toml.pre-dotfiles" ||
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
[ ! -s "$test_log" ] ||
  fail 'Mise migration conflicts must fail before package or link mutation'
grep -Fqx current "$mise_conflict_home/.config/mise/config.toml" ||
  fail 'bootstrap must preserve a conflicting Mise config'
grep -Fqx backup \
  "$mise_conflict_home/.config/mise/config.toml.pre-dotfiles" ||
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
  [ ! -s "$test_log" ] ||
    fail "$mise_link_kind Mise conflicts must fail before package mutation"
  [ -L "$mise_link_home/.config/mise/config.toml" ] ||
    fail "bootstrap must preserve a $mise_link_kind Mise config symlink"
done
pass 'Mise config migration is recoverable and preflighted'

standalone_mise_home=$test_tmp/standalone-mise-home
mkdir -p "$standalone_mise_home/.local/bin"
printf '%s\n' 'old standalone mise' >"$standalone_mise_home/.local/bin/mise"
: >"$test_log"
run_bootstrap_home "$standalone_mise_home" >/dev/null
[ ! -e "$standalone_mise_home/.local/bin/mise" ] ||
  fail 'bootstrap must move the standalone Mise before rcup'
grep -Fqx 'old standalone mise' \
  "$standalone_mise_home/.local/bin/mise.pre-dotfiles" ||
  fail 'bootstrap must preserve the standalone Mise exactly'
run_bootstrap_home "$standalone_mise_home" >/dev/null ||
  fail 'standalone Mise migration must be idempotent'

homebrew_mise_link_home=$test_tmp/homebrew-mise-link-home
mkdir -p "$homebrew_mise_link_home/.local/bin"
ln -s /opt/homebrew/bin/mise "$homebrew_mise_link_home/.local/bin/mise"
: >"$test_log"
run_bootstrap_home "$homebrew_mise_link_home" >/dev/null ||
  fail 'bootstrap must accept a standalone path delegating to Homebrew Mise'
doctor_output=$(HOME="$homebrew_mise_link_home" \
  PATH=/usr/bin:/bin \
  DOTFILES_ROOT="$repo_root" \
  "$repo_root/bin/dotfiles-doctor" 2>&1 || true)
printf '%s\n' "$doctor_output" | grep -Fq \
  '[ok]   standalone Mise path delegates to the Homebrew-owned command' ||
  fail 'doctor must accept a standalone path delegating to Homebrew Mise'
pass 'standalone Mise migration leaves Homebrew as the single owner'

retired_home=$test_tmp/retired-home
mkdir -p "$retired_home"
ln -s "$repo_root/CLAUDE.md" "$retired_home/.CLAUDE.md"
ln -s "$repo_root/AGENTS.md" "$retired_home/.AGENTS.md"
ln -s "$repo_root/agrc" "$retired_home/.agrc"
: >"$test_log"
run_bootstrap_home "$retired_home" >/dev/null
for retired_link in \
  "$retired_home/.CLAUDE.md" \
  "$retired_home/.AGENTS.md" \
  "$retired_home/.agrc"; do
  [ ! -L "$retired_link" ] ||
    fail "bootstrap did not remove owned retired symlink: $retired_link"
done
second_retired_run=$(run_bootstrap_home "$retired_home") ||
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
[ ! -s "$test_log" ] ||
  fail 'root instruction conflicts must fail before package or link mutation'
grep -Fqx 'keep my instructions' "$foreign_root_home/.CLAUDE.md" ||
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
[ ! -s "$test_log" ] ||
  fail 'foreign root symlinks must fail before package or link mutation'
[ "$foreign_root_link_home/.AGENTS.md" -ef \
  "$foreign_root_link_home/instructions.md" ] ||
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
  check-ignore --no-index -q -- 'config/.DS_Store' ||
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
  if printf '%s\n' "$rcm_output" |
    grep -Eq ":$repo_root/(AGENTS\.md|CLAUDE\.md)$"; then
    fail 'rcm must exclude repository instruction files'
  fi
  for nested_instruction in \
    claude/CLAUDE.md \
    codex/AGENTS.md \
    config/nvim/CLAUDE.md \
    config/nvim/AGENTS.md; do
    printf '%s\n' "$rcm_output" |
      grep -Fq ":$repo_root/$nested_instruction" ||
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

# A throwaway HOME makes every `[[ -f ~/... ]]` guard in zshrc fail, so this
# exercises the PATH block without loading Oh My Zsh or the local overrides.
resolved_path=$(HOME="$test_tmp/home" PATH=/usr/bin:/bin zsh -fc \
  ". '$repo_root/zshrc'; print -r -- \"\$PATH\"" 2>/dev/null)
homebrew_prefix=${resolved_path%%/opt/homebrew/bin*}
standalone_prefix=${resolved_path%%"$test_tmp/home/.local/bin"*}
case ":$resolved_path:" in
  *":/opt/homebrew/bin:"*) ;;
  *) fail 'interactive PATH must contain the Homebrew bin directory' ;;
esac
case ":$resolved_path:" in
  *":$test_tmp/home/.local/bin:"*) ;;
  *) fail 'interactive PATH must contain ~/.local/bin' ;;
esac
# Compared by position, not adjacency: mise activation prepends its own shims.
[ "${#homebrew_prefix}" -lt "${#standalone_prefix}" ] ||
  fail 'Homebrew must precede ~/.local/bin so it owns the mise command'
pass 'interactive PATH prefers Homebrew Mise over the retired standalone install'

grep -Fq 'brew "rcm"' "$repo_root/Brewfile" || fail 'core Brewfile must install rcm'
grep -Fq 'brew "herdr"' "$repo_root/Brewfile" || fail 'core Brewfile must install Herdr'
for core_formula in \
  git git-lfs coreutils gawk uv diff-so-fancy shellcheck shfmt stylua macvim; do
  grep -Fq "brew \"$core_formula\"" "$repo_root/Brewfile" ||
    fail "core Brewfile must install $core_formula"
done
grep -Fq 'mise mvim nvim' "$repo_root/bin/dotfiles-doctor" ||
  fail 'doctor must check the mvim command'
grep -Fq 'bundle check --no-upgrade' "$repo_root/bin/dotfiles-doctor" ||
  fail 'doctor must not require upgrades in default check mode'
grep -Fq 'HOMEBREW_NO_AUTO_UPDATE=1' "$repo_root/bin/dotfiles-doctor" ||
  fail 'doctor must not update Homebrew state during a read-only check'
grep -Fq 'brew "griffinqiu/tap/bootmux"' "$repo_root/Brewfile" ||
  fail 'core Brewfile must install Bootmux from its tap'
grep -Fq 'brew "reattach-to-user-namespace"' "$repo_root/Brewfile.optional" ||
  fail 'optional Brewfile must retain reattach-to-user-namespace'
grep -Fq 'brew "zellij"' "$repo_root/Brewfile.optional" ||
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
    mise install --locked -y --dry-run >/dev/null ||
    fail 'mise lock must resolve completely in locked mode'
  pass 'mise lock resolves in locked dry-run mode'
fi

sh -n "$repo_root/bin/dotfiles-bootstrap"
sh -n "$repo_root/bin/dotfiles-doctor"
sh -n "$repo_root/hooks/post-up"
sh -n "$repo_root/test/bootstrap.sh"
pass 'shell syntax'
