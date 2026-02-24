#!/bin/bash
# Claude Code statusLine - lualine flat style, everforest dark

read -r -d '' input </dev/stdin

eval "$(echo "$input" | jq -r '
  "cwd=" + (.workspace.current_dir // .cwd | @sh),
  "model=" + (.model.display_name // "" | @sh),
  "used_pct=" + ((.context_window.used_percentage // 0) | floor | tostring),
  "lines_added=" + ((.cost.total_lines_added // 0) | tostring),
  "lines_removed=" + ((.cost.total_lines_removed // 0) | tostring),
  "total_input=" + ((.context_window.total_input_tokens // 0) | tostring),
  "total_output=" + ((.context_window.total_output_tokens // 0) | tostring),
  "cost_usd=" + ((.cost.total_cost_usd // 0) | tostring),
  "version=" + (.version // "" | @sh)
')"

RESET=$'\033[0m'

# everforest dark medium - https://github.com/neanias/everforest-nvim
# switching themes: update hex values below
_hex() {
  local h="${1#'#'}"
  printf '\033[38;2;%d;%d;%dm' $((16#${h:0:2})) $((16#${h:2:2})) $((16#${h:4:2}))
}

BLUE=$(_hex "#7fbbb3")    # blue
PURP=$(_hex "#d699b6")    # purple
TEAL=$(_hex "#83c092")    # aqua
GRN=$(_hex "#a7c080")     # green
RED=$(_hex "#e67e80")     # red
ORNG=$(_hex "#e69875")    # orange
YLW=$(_hex "#dbbc7f")     # yellow
GRAY=$(_hex "#859289")    # grey1
SEP_CLR=$(_hex "#343f44") # bg1

SEP=" ${SEP_CLR}|${RESET} "

left="${BLUE}󰉋 $(basename "$cwd")${RESET}"

short_model=$(echo "$model" | sed 's/^Claude //; s/ [0-9].*//' | tr '[:upper:]' '[:lower:]')

if [ "$used_pct" -ge 75 ]; then
  pct_color=$RED
elif [ "$used_pct" -ge 50 ]; then
  pct_color=$ORNG
else
  pct_color=$TEAL
fi

total_tokens=$((total_input + total_output))
if [ "$total_tokens" -ge 1000000 ]; then
  token_display="$(awk "BEGIN{printf \"%.1f\", $total_tokens/1000000}")M"
elif [ "$total_tokens" -ge 1000 ]; then
  token_display="$(awk "BEGIN{printf \"%.1f\", $total_tokens/1000}")k"
else
  token_display="${total_tokens}"
fi

diff_seg=""
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
  if [ "$lines_added" -gt 0 ]; then
    diff_icon_color=$GRN
  else
    diff_icon_color=$RED
  fi
  diff_parts=""
  [ "$lines_added" -gt 0 ] && diff_parts="${GRN}${lines_added}${RESET}"
  if [ "$lines_removed" -gt 0 ]; then
    [ -n "$diff_parts" ] && diff_parts="${diff_parts} "
    diff_parts="${diff_parts}${RED}${lines_removed}${RESET}"
  fi
  diff_seg="${SEP}${diff_icon_color}󰦒${RESET} ${diff_parts}"
fi

cost_display=$(awk "BEGIN{printf \"%.3f\", $cost_usd}")
token_seg="${pct_color}󰍛 ${token_display}${RESET}"
token_seg="${token_seg} ${pct_color}\$${cost_display}${RESET}"

update_seg=""
if [ -n "$version" ]; then
  CACHE_FILE="/tmp/claude-statusline-latest-version"
  CACHE_MAX_AGE=1800

  latest=""
  if [ -f "$CACHE_FILE" ]; then
    cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ "$cache_age" -le "$CACHE_MAX_AGE" ]; then
      latest=$(cat "$CACHE_FILE")
    fi
  fi

  if [ -z "$latest" ]; then
    latest=$(npm view @anthropic-ai/claude-code version 2>/dev/null || echo "")
    [ -n "$latest" ] && echo "$latest" >"$CACHE_FILE"
  fi

  if [ -n "$latest" ] && [ "$latest" != "$version" ]; then
    update_seg="${SEP}${YLW}󰄾 ${latest}${RESET}"
  fi
fi

printf "%s%s%s%s%s%s%s%s%s\n" \
  "$left" \
  "$diff_seg" \
  "$SEP" "${PURP}󰚩 ${short_model}${RESET}" \
  "$SEP" "$token_seg" \
  "$SEP" "${pct_color}󰓌 ${used_pct}%${RESET}" \
  "$update_seg"
