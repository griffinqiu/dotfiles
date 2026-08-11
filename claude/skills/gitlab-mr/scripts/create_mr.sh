#!/usr/bin/env bash
# create_mr.sh: push branch + create/update GitLab MR with review content anchored in description.
#
# Usage:
#   create_mr.sh --review-file <path> --title "<title>" [--target-branch <name>]

set -euo pipefail

REVIEW_BEGIN='<!-- ai-pr-review:begin -->'
REVIEW_END='<!-- ai-pr-review:end -->'

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
cyan()  { printf '\033[36m%s\033[0m\n' "$*"; }
fail()  { red "❌ $*"; exit 1; }

usage() {
  cat <<EOF
Usage: $0 --review-file <path> --title "<title>" [--target-branch <name>]
EOF
  exit 1
}

REVIEW_FILE=""
TARGET_BRANCH=""
TITLE=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --review-file)   REVIEW_FILE="${2:-}"; shift 2 ;;
    --target-branch) TARGET_BRANCH="${2:-}"; shift 2 ;;
    --title)         TITLE="${2:-}"; shift 2 ;;
    -h|--help)       usage ;;
    *) red "unknown argument: $1"; usage ;;
  esac
done

[ -n "$REVIEW_FILE" ] && [ -f "$REVIEW_FILE" ] || fail "--review-file 缺失或文件不存在：$REVIEW_FILE"
[ -n "$TITLE" ]                                || fail "--title 不能为空"
[ -n "$TARGET_BRANCH" ] || TARGET_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main)"

command -v glab-api >/dev/null 2>&1 || fail "glab-api 不在 PATH 中"
command -v jq       >/dev/null 2>&1 || fail "需要 jq：brew install jq"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
[ -n "$CURRENT_BRANCH" ] || fail "不在 git 仓库中"
case "$CURRENT_BRANCH" in main|master) fail "不能从 $CURRENT_BRANCH 建 MR" ;; esac

# ── MR title length clamp (GitLab 255) ─────────────────────────────────────
if [ "${#TITLE}" -gt 255 ]; then
  cyan "⚠️  标题过长 ${#TITLE} → 截断至 252+…"
  TITLE="${TITLE:0:252}..."
fi

# ── Clamp review content to ~900KB (GitLab description ≤ 1MB) ──────────────
REVIEW_SIZE_KB="$(du -k "$REVIEW_FILE" | cut -f1)"
if [ "$REVIEW_SIZE_KB" -gt 900 ]; then
  cyan "⚠️  review 文件 ${REVIEW_SIZE_KB}KB 接近 GitLab 上限，截断至 900KB"
  TRUNC="$REVIEW_FILE.truncated"
  head -c 900000 "$REVIEW_FILE" > "$TRUNC"
  printf '\n\n⚠️ **内容过长已截断**\n' >> "$TRUNC"
  REVIEW_FILE="$TRUNC"
fi

REVIEW_CONTENT="$(cat "$REVIEW_FILE")"

# ── Build the anchored review block ────────────────────────────────────────
ANCHORED_BLOCK="$(printf '%s\n%s\n%s\n' "$REVIEW_BEGIN" "$REVIEW_CONTENT" "$REVIEW_END")"

# ── Step 1: push ───────────────────────────────────────────────────────────
cyan "━━━ 1/2  推送分支 $CURRENT_BRANCH → origin/$CURRENT_BRANCH ━━━"
if ! git push --force-with-lease -u origin "$CURRENT_BRANCH"; then
  fail "推送失败。检查网络/权限，或 git fetch 后重试。"
fi

# ── Step 2: find existing open MR for this source branch ───────────────────
cyan "━━━ 2/2  查找是否已有 open MR ━━━"
EXISTING="$(glab-api mr-find-by-source "$CURRENT_BRANCH" 2>/dev/null || echo '[]')"
EXISTING_IID="$(printf '%s' "$EXISTING" | jq -r '.[0].iid // empty')"

if [ -n "$EXISTING_IID" ]; then
  EXISTING_URL="$(printf '%s' "$EXISTING" | jq -r '.[0].web_url')"
  EXISTING_DESC="$(printf '%s' "$EXISTING" | jq -r '.[0].description // ""')"
  EXISTING_TITLE="$(printf '%s' "$EXISTING" | jq -r '.[0].title')"
  cyan "ℹ️  已存在 MR !$EXISTING_IID：$EXISTING_TITLE"

  # Replace anchored section inside description; if missing, append
  NEW_DESC="$(printf '%s' "$EXISTING_DESC" | awk -v begin="$REVIEW_BEGIN" -v end="$REVIEW_END" -v block="$ANCHORED_BLOCK" '
    BEGIN { in_block = 0; replaced = 0 }
    {
      if (index($0, begin) > 0) { in_block = 1; print block; replaced = 1; next }
      if (in_block && index($0, end) > 0) { in_block = 0; next }
      if (!in_block) print
    }
    END { if (!replaced) { if (NR > 0) print ""; print block } }
  ')"

  BODY_FILE="$(mktemp)"
  trap 'rm -f "$BODY_FILE"' EXIT
  jq -n --arg title "$TITLE" --arg desc "$NEW_DESC" '{title: $title, description: $desc, squash: true}' > "$BODY_FILE"

  if [ "$EXISTING_DESC" = "$NEW_DESC" ] && [ "$EXISTING_TITLE" = "$TITLE" ]; then
    green "✅ MR 描述无变化，跳过更新"
    green "🔗 MR !$EXISTING_IID: $EXISTING_URL"
    exit 0
  fi

  RESP="$(glab-api mr-update "$EXISTING_IID" "$BODY_FILE")"
  URL="$(printf '%s' "$RESP" | jq -r '.web_url')"
  green "✅ MR 已更新"
  green "🔗 MR !$EXISTING_IID: $URL"
  exit 0
fi

# ── Create new MR ──────────────────────────────────────────────────────────
DESC="$ANCHORED_BLOCK"
BODY_FILE="$(mktemp)"
trap 'rm -f "$BODY_FILE"' EXIT
jq -n \
  --arg title "$TITLE" \
  --arg desc "$DESC" \
  --arg source "$CURRENT_BRANCH" \
  --arg target "$TARGET_BRANCH" \
  '{title: $title, description: $desc, source_branch: $source, target_branch: $target, remove_source_branch: true, squash: true}' \
  > "$BODY_FILE"

RESP="$(glab-api mr-create "$BODY_FILE")"
URL="$(printf '%s' "$RESP" | jq -r '.web_url')"
IID="$(printf '%s' "$RESP" | jq -r '.iid')"

green "✅ MR 创建成功"
green "🔗 MR !$IID: $URL"
