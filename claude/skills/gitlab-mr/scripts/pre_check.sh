#!/usr/bin/env bash
# pre_check for /gitlab-mr: workspace state, branch, token, ahead/behind.
# On success, prints `TARGET_BRANCH=<name>` as the last line. Exit 1 on any failure.

set -euo pipefail

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
cyan()  { printf '\033[36m%s\033[0m\n' "$*"; }

fail() { red "❌ $*"; exit 1; }

# ── 1. clean workspace ─────────────────────────────────────────────────────
if [ -n "$(git status --porcelain --ignore-submodules=dirty)" ]; then
  fail "当前本地有未提交的变更。请先 commit 或 stash 后重试。"
fi

# ── 2. not on main/master ──────────────────────────────────────────────────
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
case "$CURRENT_BRANCH" in
  main|master) fail "不能在 $CURRENT_BRANCH 分支上创建 MR，请切换到 feature 分支。" ;;
esac

# ── 3. glab-api / token ────────────────────────────────────────────────────
if ! command -v glab-api >/dev/null 2>&1; then
  fail "glab-api 未在 PATH 中。请确认 ~/dotfiles/bin 已加入 PATH 并 rcup 完成。"
fi

if ! glab-api whoami >/dev/null 2>&1; then
  cat <<'EOF' >&2
❌ GitLab token 无效或未配置。

请任选其一：
  export LB_GITLAB_TOKEN=glpat-xxxx   # 最简单
  glab auth login                      # 用 glab CLI 登录

Token 需要 'api' scope。
EOF
  exit 1
fi
green "✅ GitLab token 验证通过"

# ── 4. detect target branch ────────────────────────────────────────────────
TARGET_BRANCH=""
if git rev-parse --verify origin/master >/dev/null 2>&1; then
  TARGET_BRANCH="master"
elif git rev-parse --verify origin/main >/dev/null 2>&1; then
  TARGET_BRANCH="main"
else
  TARGET_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)"
fi
[ -n "$TARGET_BRANCH" ] || fail "无法探测远程主分支（origin/master 或 origin/main）。"

cyan "🔍 基准分支：origin/$TARGET_BRANCH"
git fetch origin "$TARGET_BRANCH" --quiet || cyan "⚠️  fetch 失败（可能是离线），继续用本地 origin/$TARGET_BRANCH"

# ── 5. ahead / behind ──────────────────────────────────────────────────────
AHEAD="$(git rev-list --count "origin/$TARGET_BRANCH..HEAD" 2>/dev/null || echo 0)"
BEHIND="$(git rev-list --count "HEAD..origin/$TARGET_BRANCH" 2>/dev/null || echo 0)"

cyan "📊 Ahead: $AHEAD · Behind: $BEHIND"

if [ "$BEHIND" -gt 0 ]; then
  fail "当前分支落后 origin/$TARGET_BRANCH $BEHIND 个提交。请先 rebase：git rebase origin/$TARGET_BRANCH"
fi

if [ "$AHEAD" -eq 0 ]; then
  fail "当前分支相对 origin/$TARGET_BRANCH 没有新提交，无法创建 MR。"
fi

# ── done ───────────────────────────────────────────────────────────────────
green "✅ 全部检查通过"
echo "  · 分支：$CURRENT_BRANCH"
echo "  · 领先 origin/$TARGET_BRANCH $AHEAD 个提交"
echo "TARGET_BRANCH=$TARGET_BRANCH"
