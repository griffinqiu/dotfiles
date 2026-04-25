#!/usr/bin/env bash
# fetch_threads.sh: fetch unresolved inline threads for a GitLab MR.
#
# Usage:
#   fetch_threads.sh --iid <mr-iid>
#
# Output (stdout): JSON with { iid, web_url, threads: [...] } — only resolvable+unresolved.

set -euo pipefail

red()   { printf '\033[31m%s\033[0m\n' "$*" >&2; }
fail()  { red "❌ $*"; exit 1; }

usage() {
  echo "Usage: $0 --iid <mr-iid>" >&2
  exit 1
}

IID=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --iid)     IID="${2:-}"; shift 2 ;;
    -h|--help) usage ;;
    *) red "unknown: $1"; usage ;;
  esac
done

[ -n "$IID" ] || fail "--iid required"

command -v glab-api >/dev/null 2>&1 || fail "glab-api 不在 PATH"
command -v jq       >/dev/null 2>&1 || fail "需要 jq"

MR="$(glab-api mr-view "$IID")"
DISCUSSIONS="$(glab-api mr-discussions "$IID")"

# Filter: discussions that have at least one resolvable+unresolved note with position (inline).
# Shape each remaining thread.
jq -n \
  --argjson mr "$MR" \
  --argjson discussions "$DISCUSSIONS" \
  '{
     iid: $mr.iid,
     web_url: $mr.web_url,
     threads: [
       $discussions[]
       | select(
           (.notes // []) | any(.resolvable == true and .resolved == false and (.position != null))
         )
       | . as $disc
       | ($disc.notes[0]) as $first
       | {
           discussion_id: $disc.id,
           is_inline: true,
           file: ($first.position.new_path // $first.position.old_path // ""),
           line: ($first.position.new_line // $first.position.old_line // 0),
           first_note_id: $first.id,
           reviewer: ($first.author.username // $first.author.name // "unknown"),
           thread_body: ($first.body // ""),
           thread_history: [
             $disc.notes[] | {author: (.author.username // .author.name // "unknown"), body: .body}
           ]
         }
     ]
   }'
