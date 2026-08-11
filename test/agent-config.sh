#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
subject="$repo_root/bin/agent-config"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/agent-config-test.XXXXXX")"

cleanup() {
  rm -rf "$test_root"
}
trap cleanup EXIT

fail() {
  printf 'not ok - %s\n' "$*" >&2
  exit 1
}

assert_relative_link() {
  local path="$1" link_value="$2" source="$3"
  [ -L "$path" ] || fail "$path is not a symlink"
  [ "$(readlink "$path")" = "$link_value" ] || \
    fail "$path does not contain relative target $link_value"
  [ -e "$path" ] || fail "$path is a broken symlink"
  [ "$path" -ef "$source" ] || fail "$path does not resolve to $source"
}

write_skill() {
  local project="$1" name="$2"
  mkdir -p "$project/.claude/skills/$name"
  printf '%s\n' \
    '---' \
    "name: $name" \
    "description: Test skill $name." \
    '---' \
    '' \
    "# $name" \
    > "$project/.claude/skills/$name/SKILL.md"
}

non_git="$test_root/non-git"
mkdir -p "$non_git"
if (cd "$non_git" && "$subject" check \
    >"$test_root/non-git.out" 2>"$test_root/non-git.err"); then
  fail 'check accepted a default directory outside a Git repository'
fi
grep -q 'not inside a Git repository' "$test_root/non-git.err" || \
  fail 'default non-Git failure did not explain --project'

fresh_project="$test_root/fresh"
mkdir -p "$fresh_project"
"$subject" init --project "$fresh_project" >/dev/null
[ -s "$fresh_project/CLAUDE.md" ] || fail 'init did not create CLAUDE.md'
assert_relative_link \
  "$fresh_project/AGENTS.md" 'CLAUDE.md' "$fresh_project/CLAUDE.md"
"$subject" check --project "$fresh_project" >/dev/null
"$subject" init --project "$fresh_project" >/dev/null

existing_claude="$test_root/existing-claude"
mkdir -p "$existing_claude"
printf 'custom Claude instructions\n' > "$existing_claude/CLAUDE.md"
"$subject" init --project "$existing_claude" >/dev/null
[ "$(cat "$existing_claude/CLAUDE.md")" = 'custom Claude instructions' ] || \
  fail 'init changed an existing CLAUDE.md'
assert_relative_link \
  "$existing_claude/AGENTS.md" 'CLAUDE.md' "$existing_claude/CLAUDE.md"

agents_only="$test_root/agents-only"
mkdir -p "$agents_only"
printf 'keep AGENTS content\n' > "$agents_only/AGENTS.md"
if "$subject" init --project "$agents_only" \
    >"$test_root/agents-only.out" 2>"$test_root/agents-only.err"; then
  fail 'init accepted AGENTS.md without CLAUDE.md'
fi
[ "$(cat "$agents_only/AGENTS.md")" = 'keep AGENTS content' ] || \
  fail 'init changed an AGENTS-only project'
[ ! -e "$agents_only/CLAUDE.md" ] || \
  fail 'init partially migrated an AGENTS-only project'
grep -q 'Move the AGENTS.md content to CLAUDE.md' "$test_root/agents-only.err" || \
  fail 'init did not print AGENTS-to-CLAUDE migration guidance'

conflicting_instructions="$test_root/conflicting-instructions"
mkdir -p "$conflicting_instructions"
printf 'Claude body\n' > "$conflicting_instructions/CLAUDE.md"
printf 'Codex body\n' > "$conflicting_instructions/AGENTS.md"
if "$subject" init --project "$conflicting_instructions" >/dev/null 2>&1; then
  fail 'init accepted a conflicting AGENTS.md'
fi
[ "$(cat "$conflicting_instructions/CLAUDE.md")" = 'Claude body' ] || \
  fail 'init changed the Claude body during a conflict'
[ "$(cat "$conflicting_instructions/AGENTS.md")" = 'Codex body' ] || \
  fail 'init changed the Codex body during a conflict'

write_skill "$fresh_project" alpha
write_skill "$fresh_project" beta
"$subject" sync --project "$fresh_project" >/dev/null
assert_relative_link \
  "$fresh_project/.agents/skills/alpha" \
  '../../.claude/skills/alpha' \
  "$fresh_project/.claude/skills/alpha"
assert_relative_link \
  "$fresh_project/.agents/skills/beta" \
  '../../.claude/skills/beta' \
  "$fresh_project/.claude/skills/beta"
"$subject" sync --project "$fresh_project" >/dev/null
"$subject" check --project "$fresh_project" >/dev/null

conflicting_skills="$test_root/conflicting-skills"
mkdir -p "$conflicting_skills"
"$subject" init --project "$conflicting_skills" >/dev/null
write_skill "$conflicting_skills" alpha
write_skill "$conflicting_skills" beta
mkdir -p "$conflicting_skills/.agents/skills/alpha"
printf 'keep directory\n' > "$conflicting_skills/.agents/skills/alpha/sentinel"
if "$subject" sync --project "$conflicting_skills" \
    >/dev/null 2>"$test_root/conflicting-skills.err"; then
  fail 'sync accepted a conflicting real skill directory'
fi
grep -q 'sync preflight failed; no files changed' \
  "$test_root/conflicting-skills.err" || \
  fail 'sync did not report its all-or-nothing conflict outcome'
[ "$(cat "$conflicting_skills/.agents/skills/alpha/sentinel")" = 'keep directory' ] || \
  fail 'sync changed a conflicting skill directory'
[ ! -e "$conflicting_skills/.agents/skills/beta" ] || \
  fail 'sync created a partial link before reporting a conflict'

orphan_project="$test_root/orphan"
mkdir -p "$orphan_project"
"$subject" init --project "$orphan_project" >/dev/null
mkdir -p "$orphan_project/.agents/skills"
ln -s '../../.claude/skills/orphan' "$orphan_project/.agents/skills/orphan"
if "$subject" check --project "$orphan_project" >/dev/null 2>&1; then
  fail 'check accepted an orphaned Codex skill alias'
fi

assert_relative_link "$repo_root/AGENTS.md" \
  'CLAUDE.md' "$repo_root/CLAUDE.md"
assert_relative_link "$repo_root/codex/AGENTS.md" \
  '../claude/CLAUDE.md' "$repo_root/claude/CLAUDE.md"
assert_relative_link "$repo_root/config/nvim/AGENTS.md" \
  'CLAUDE.md' "$repo_root/config/nvim/CLAUDE.md"
assert_relative_link "$repo_root/agents/skills/manage-agent-config" \
  '../../claude/skills/manage-agent-config' \
  "$repo_root/claude/skills/manage-agent-config"
# dotfiles-theme only styles this repository, so it stays project-scoped on both
# sides. Publishing it through agents/skills would put it in Codex's global
# namespace while Claude only ever saw the project copy.
assert_relative_link "$repo_root/.agents/skills/dotfiles-theme" \
  '../../.claude/skills/dotfiles-theme' \
  "$repo_root/.claude/skills/dotfiles-theme"
[ ! -e "$repo_root/agents/skills/dotfiles-theme" ] ||
  fail 'dotfiles-theme is project-scoped and must not be published globally'

printf 'ok - agent-config init, sync, check, idempotence, and conflicts\n'
