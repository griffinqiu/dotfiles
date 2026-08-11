#!/usr/bin/env bash
# reply_resolve.sh: apply a batch of reply/resolve actions against MR discussions.
#
# Usage:
#   reply_resolve.sh --iid <mr-iid> --payload <actions.json>
#
# Payload:
#   {
#     "actions": [
#       {"discussion_id":"abc","action":"reply_and_resolve","body":"..."},
#       {"discussion_id":"def","action":"reply_only","body":"..."},
#       {"discussion_id":"ghi","action":"resolve_only"}
#     ]
#   }
#
# Every reply body gets a leading `<!-- ai-resolve -->` marker.

set -euo pipefail

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
cyan()  { printf '\033[36m%s\033[0m\n' "$*"; }
fail()  { red "❌ $*"; exit 1; }

usage() {
  echo "Usage: $0 --iid <mr-iid> --payload <actions.json>" >&2
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

[ -n "$IID" ] || fail "--iid required"
[ -n "$PAYLOAD" ] && [ -f "$PAYLOAD" ] || fail "payload 文件不存在：$PAYLOAD"

command -v glab-api >/dev/null 2>&1 || fail "glab-api 不在 PATH"
command -v jq       >/dev/null 2>&1 || fail "需要 jq"

COUNT="$(jq '.actions | length' "$PAYLOAD")"
[ "$COUNT" -gt 0 ] || { cyan "payload.actions 为空，无事可做"; exit 0; }

OK=0
FAIL=0

for i in $(seq 0 $((COUNT - 1))); do
  disc="$(jq -r ".actions[$i].discussion_id" "$PAYLOAD")"
  action="$(jq -r ".actions[$i].action" "$PAYLOAD")"
  body="$(jq -r ".actions[$i].body // \"\"" "$PAYLOAD")"

  [ -n "$disc" ] && [ "$disc" != "null" ] || { red "  ✗ #$((i+1)) discussion_id 缺失"; FAIL=$((FAIL+1)); continue; }

  case "$action" in
    reply_and_resolve)
      [ -n "$body" ] || { red "  ✗ #$((i+1)) reply_and_resolve 缺 body"; FAIL=$((FAIL+1)); continue; }
      marked="$(printf '<!-- ai-resolve -->\n%s' "$body")"
      if glab-api mr-reply "$IID" "$disc" "$marked" >/dev/null 2>&1 \
         && glab-api mr-resolve "$IID" "$disc" >/dev/null 2>&1; then
        green "  ✓ #$((i+1)) reply+resolve ($disc)"
        OK=$((OK+1))
      else
        red "  ✗ #$((i+1)) reply_and_resolve 失败 ($disc)"
        FAIL=$((FAIL+1))
      fi
      ;;
    reply_only)
      [ -n "$body" ] || { red "  ✗ #$((i+1)) reply_only 缺 body"; FAIL=$((FAIL+1)); continue; }
      marked="$(printf '<!-- ai-resolve -->\n%s' "$body")"
      if glab-api mr-reply "$IID" "$disc" "$marked" >/dev/null 2>&1; then
        green "  ✓ #$((i+1)) reply ($disc)"
        OK=$((OK+1))
      else
        red "  ✗ #$((i+1)) reply 失败 ($disc)"
        FAIL=$((FAIL+1))
      fi
      ;;
    resolve_only)
      if glab-api mr-resolve "$IID" "$disc" >/dev/null 2>&1; then
        green "  ✓ #$((i+1)) resolve ($disc)"
        OK=$((OK+1))
      else
        red "  ✗ #$((i+1)) resolve 失败 ($disc)"
        FAIL=$((FAIL+1))
      fi
      ;;
    *)
      red "  ✗ #$((i+1)) 未知 action: $action"
      FAIL=$((FAIL+1))
      ;;
  esac
done

URL="$(glab-api mr-view "$IID" | jq -r '.web_url')"
green ""
green "完成：成功 $OK / 失败 $FAIL"
green "🔗 $URL"

[ "$FAIL" -eq 0 ] || exit 3
