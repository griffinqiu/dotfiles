#!/usr/bin/env bash
# post_inline.sh: batch-post inline discussions + summary note to a GitLab MR.
#
# Usage:
#   post_inline.sh --iid <mr-iid> --payload <payload.json>
#
# Payload schema:
#   {
#     "diff_refs": {"base_sha":"...","start_sha":"...","head_sha":"..."},
#     "inline": [{"file":..,"line":..,"severity":..,"category":..,"title":..,"description":..,"suggestion":..}],
#     "summary": {"positives":[...],"recommendations":[...],"context_notes":[{"file":..,"note":..}]}
#   }

set -euo pipefail

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
cyan()  { printf '\033[36m%s\033[0m\n' "$*"; }
fail()  { red "❌ $*"; exit 1; }

usage() {
  cat <<EOF
Usage: $0 --iid <mr-iid> --payload <payload.json>
EOF
  exit 1
}

IID=""
PAYLOAD=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --iid)     IID="${2:-}"; shift 2 ;;
    --payload) PAYLOAD="${2:-}"; shift 2 ;;
    -h|--help) usage ;;
    *) red "unknown: $1"; usage ;;
  esac
done

[ -n "$IID" ] || fail "--iid 必填"
[ -n "$PAYLOAD" ] && [ -f "$PAYLOAD" ] || fail "--payload 文件不存在：$PAYLOAD"

command -v glab-api >/dev/null 2>&1 || fail "glab-api 不在 PATH"
command -v jq       >/dev/null 2>&1 || fail "需要 jq"

jq -e '.diff_refs.base_sha and .diff_refs.start_sha and .diff_refs.head_sha' "$PAYLOAD" >/dev/null \
  || fail "payload 缺少 diff_refs.{base,start,head}_sha"

BASE_SHA="$(jq -r '.diff_refs.base_sha'  "$PAYLOAD")"
START_SHA="$(jq -r '.diff_refs.start_sha' "$PAYLOAD")"
HEAD_SHA="$(jq -r '.diff_refs.head_sha'  "$PAYLOAD")"

INLINE_COUNT="$(jq '.inline | length' "$PAYLOAD")"
SUCCESS=0
FAILED=0

if [ "$INLINE_COUNT" -gt 0 ]; then
  cyan "━━━ 发送 $INLINE_COUNT 条 inline discussions ━━━"

  for i in $(seq 0 $((INLINE_COUNT - 1))); do
    file="$(jq -r ".inline[$i].file" "$PAYLOAD")"
    line="$(jq -r ".inline[$i].line" "$PAYLOAD")"
    severity="$(jq -r ".inline[$i].severity" "$PAYLOAD")"
    category="$(jq -r ".inline[$i].category // \"\"" "$PAYLOAD")"
    title="$(jq -r ".inline[$i].title // \"\"" "$PAYLOAD")"
    desc="$(jq -r ".inline[$i].description" "$PAYLOAD")"
    sugg="$(jq -r ".inline[$i].suggestion // \"\"" "$PAYLOAD")"

    body="$(printf '<!-- ai-mr-inline -->\n**[%s]** %s%s\n\n%s' \
      "$severity" \
      "$([ -n "$category" ] && printf '%s · ' "$category")" \
      "$title" \
      "$desc")"
    if [ -n "$sugg" ]; then
      body="$(printf '%s\n\n```suggestion:-0+0\n%s\n```' "$body" "$sugg")"
    fi

    body_file="$(mktemp)"
    jq -n \
      --arg body "$body" \
      --arg base "$BASE_SHA" --arg start "$START_SHA" --arg head "$HEAD_SHA" \
      --arg file "$file" --argjson line "$line" \
      '{
         body: $body,
         position: {
           base_sha: $base, start_sha: $start, head_sha: $head,
           position_type: "text",
           old_path: $file, new_path: $file, new_line: $line
         }
       }' > "$body_file"

    if glab-api mr-post-discussion "$IID" "$body_file" >/dev/null 2>&1; then
      green "  ✓ #$((i+1)) $file:$line [$severity] $title"
      SUCCESS=$((SUCCESS + 1))
    else
      red "  ✗ #$((i+1)) $file:$line — 发送失败（可能是行不在 diff 中，会进 summary）"
      FAILED=$((FAILED + 1))
    fi
    rm -f "$body_file"
  done
fi

# ── summary note ───────────────────────────────────────────────────────────
HAS_POSITIVES="$(jq '.summary.positives | length // 0' "$PAYLOAD")"
HAS_RECO="$(jq '.summary.recommendations | length // 0' "$PAYLOAD")"
HAS_CTX="$(jq '.summary.context_notes | length // 0' "$PAYLOAD")"

if [ "$HAS_POSITIVES" -gt 0 ] || [ "$HAS_RECO" -gt 0 ] || [ "$HAS_CTX" -gt 0 ] || [ "$INLINE_COUNT" -gt 0 ]; then
  cyan "━━━ 发送 summary note ━━━"
  summary=""
  summary="$(printf '<!-- ai-mr-inline --> **🤖 AI Review 总结**\n')"

  if [ "$INLINE_COUNT" -gt 0 ]; then
    summary="$(printf '%s\n已发 %d 条 inline 关注点（成功 %d / 失败 %d）。\n' \
      "$summary" "$INLINE_COUNT" "$SUCCESS" "$FAILED")"
  fi

  if [ "$HAS_POSITIVES" -gt 0 ]; then
    summary="$(printf '%s\n### ✅ 做得好\n' "$summary")"
    while IFS= read -r item; do
      summary="$(printf '%s- %s\n' "$summary" "$item")"
    done < <(jq -r '.summary.positives[]' "$PAYLOAD")
  fi

  if [ "$HAS_RECO" -gt 0 ]; then
    summary="$(printf '%s\n### 💡 跨文件建议\n' "$summary")"
    while IFS= read -r item; do
      summary="$(printf '%s- %s\n' "$summary" "$item")"
    done < <(jq -r '.summary.recommendations[]' "$PAYLOAD")
  fi

  if [ "$HAS_CTX" -gt 0 ]; then
    summary="$(printf '%s\n### 📎 上下文相关（未绑行）\n' "$summary")"
    while IFS= read -r line; do
      f="$(printf '%s' "$line" | jq -r '.file')"
      n="$(printf '%s' "$line" | jq -r '.note')"
      summary="$(printf '%s- **%s** — %s\n' "$summary" "$f" "$n")"
    done < <(jq -c '.summary.context_notes[]' "$PAYLOAD")
  fi

  if glab-api mr-note "$IID" "$summary" >/dev/null 2>&1; then
    green "  ✓ summary note 已发送"
  else
    red "  ✗ summary note 发送失败"
  fi
fi

URL="$(glab-api mr-view "$IID" | jq -r '.web_url')"
green ""
green "✅ 完成：inline 成功 $SUCCESS / 失败 $FAILED"
green "🔗 $URL"
