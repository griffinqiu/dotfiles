#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-linux-packages-test.XXXXXX")
trap 'rm -rf -- "$test_tmp"' EXIT HUP INT TERM

fake_bin=$test_tmp/bin
test_log=$test_tmp/commands.log
manifest=$test_tmp/Linuxfile
mkdir -p "$fake_bin"
tests=0

fail() {
  printf 'not ok - %s\n' "$*" >&2
  exit 1
}

pass() {
  tests=$((tests + 1))
  printf 'ok %d - %s\n' "$tests" "$*"
}

write_fake() {
  local fake_name=$1
  cat >"$fake_bin/$fake_name"
  chmod +x "$fake_bin/$fake_name"
}

write_fake id <<'EOF'
#!/bin/sh
[ "$1" = -u ] && printf '%s\n' "${TEST_UID:-1000}"
EOF

write_fake sudo <<'EOF'
#!/bin/sh
printf 'sudo:%s\n' "$*" >>"$TEST_LOG"
[ "$1" = -- ] && shift
exec "$@"
EOF

write_fake apt-get <<'EOF'
#!/bin/sh
printf 'apt-get:%s frontend=%s\n' "$*" "${DEBIAN_FRONTEND:-}" >>"$TEST_LOG"
EOF

write_fake dnf <<'EOF'
#!/bin/sh
printf 'dnf:%s\n' "$*" >>"$TEST_LOG"
EOF

write_fake localedef <<'EOF'
#!/bin/sh
printf 'localedef:%s\n' "$*" >>"$TEST_LOG"
EOF

write_fake locale <<'EOF'
#!/bin/sh
[ "$1" = -a ] && printf '%s\n' C POSIX ${TEST_LOCALES:-}
EOF

# Both take the package last; only dpkg-query reports a status string.
write_fake dpkg-query <<'EOF'
#!/bin/sh
for queried_package do :; done
case " ${TEST_INSTALLED:-} " in
  *" $queried_package "*) printf 'install ok installed' ;;
  *) exit 1 ;;
esac
EOF

write_fake rpm <<'EOF'
#!/bin/sh
for queried_package do :; done
case " ${TEST_INSTALLED:-} " in
  *" $queried_package "*) ;;
  *) exit 1 ;;
esac
EOF

cat >"$manifest" <<'EOF'
# apt            dnf
alpha            alpha-dnf
build-essential  gcc
-                gcc-c++
apt-only         -   # trailing comment
EOF

run_packages() {
  local package_manager=$1
  shift
  PATH="$fake_bin:$PATH" \
    TEST_LOG="$test_log" \
    DOTFILES_LINUX_PACKAGE_MANAGER="$package_manager" \
    "$repo_root/bin/dotfiles-linux-packages" "$@"
}

if check_output=$(TEST_INSTALLED=alpha run_packages apt check "$manifest"); then
  fail 'check must fail while packages are missing'
fi
[ "$check_output" = $'missing package: build-essential\nmissing package: apt-only' ] ||
  fail "apt check must list missing apt packages, got: $check_output"
TEST_INSTALLED='alpha build-essential apt-only' run_packages apt check "$manifest" >/dev/null ||
  fail 'check must pass once every package is installed'
pass 'apt check lists missing packages from the first column'

if check_output=$(TEST_INSTALLED=alpha-dnf run_packages dnf check "$manifest"); then
  fail 'dnf check must fail while packages are missing'
fi
[ "$check_output" = $'missing package: gcc\nmissing package: gcc-c++' ] ||
  fail "dnf check must read the second column and skip '-', got: $check_output"
pass 'dnf check reads the second column and skips unneeded rows'

: >"$test_log"
TEST_INSTALLED=alpha TEST_LOCALES=en_US.utf8 \
  run_packages apt install "$manifest" >/dev/null
expected_log='sudo:-- apt-get update
apt-get:update frontend=
sudo:-- env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential apt-only
apt-get:install -y --no-install-recommends build-essential apt-only frontend=noninteractive'
[ "$(cat "$test_log")" = "$expected_log" ] ||
  fail "apt install must install only missing packages through sudo, got: $(cat "$test_log")"
pass 'apt install updates indexes and installs only missing packages through sudo'

: >"$test_log"
TEST_INSTALLED='alpha build-essential apt-only' TEST_LOCALES=en_US.UTF-8 \
  run_packages apt install "$manifest" >/dev/null
[ ! -s "$test_log" ] || fail 'apt install must do nothing when everything is present'

: >"$test_log"
TEST_INSTALLED='alpha build-essential apt-only' TEST_LOCALES=en_US.UTF-8 \
  run_packages apt install --upgrade "$manifest" >/dev/null
grep -Fqx 'apt-get:install -y --no-install-recommends alpha build-essential apt-only frontend=noninteractive' \
  "$test_log" || fail 'apt --upgrade must reinstall every listed package'
pass 'apt install is idempotent and --upgrade covers every listed package'

: >"$test_log"
TEST_UID=0 TEST_INSTALLED=alpha TEST_LOCALES=en_US.utf8 \
  run_packages apt install "$manifest" >/dev/null
if grep -q '^sudo:' "$test_log"; then
  fail 'root must run the package manager without sudo'
fi
grep -q '^apt-get:install' "$test_log" || fail 'root must still install packages'
pass 'root installs packages without sudo'

: >"$test_log"
TEST_INSTALLED='alpha build-essential apt-only' \
  run_packages apt install "$manifest" >/dev/null
grep -Fqx 'localedef:-i en_US -f UTF-8 en_US.UTF-8' "$test_log" ||
  fail 'install must generate en_US.UTF-8 when it is missing'
pass 'install generates the en_US.UTF-8 locale when missing'

: >"$test_log"
TEST_INSTALLED=alpha-dnf TEST_LOCALES=en_US.utf8 \
  run_packages dnf install --upgrade "$manifest" >/dev/null
expected_log='sudo:-- dnf install -y gcc gcc-c++
dnf:install -y gcc gcc-c++
sudo:-- dnf upgrade -y alpha-dnf gcc gcc-c++
dnf:upgrade -y alpha-dnf gcc gcc-c++'
[ "$(cat "$test_log")" = "$expected_log" ] ||
  fail "dnf must install missing packages, then upgrade listed ones, got: $(cat "$test_log")"
pass 'dnf installs missing packages and --upgrade upgrades listed ones'

printf '%s\n' 'one two three' >"$test_tmp/malformed"
if malformed_output=$(run_packages apt check "$test_tmp/malformed" 2>&1); then
  fail 'a row without exactly two columns must be rejected'
fi
[[ $malformed_output == *'malformed row 1'* ]] ||
  fail "malformed manifests must be reported, got: $malformed_output"
if run_packages apt check --upgrade "$manifest" >/dev/null 2>&1; then
  fail '--upgrade must be rejected outside install'
fi
pass 'malformed manifests and misplaced options are rejected'

for package_manager in apt dnf; do
  if manifest_output=$(run_packages "$package_manager" check \
    "$repo_root/Linuxfile" "$repo_root/Linuxfile.optional" 2>&1); then
    fail "$package_manager check must report the empty fake system"
  fi
  [[ $manifest_output != *malformed* ]] ||
    fail "repository manifests must parse for $package_manager: $manifest_output"
  [[ $manifest_output == *'missing package: zsh'* ]] ||
    fail "repository manifests must install zsh with $package_manager"
done
pass 'repository Linuxfiles parse for apt and dnf'

echo "1..$tests"
