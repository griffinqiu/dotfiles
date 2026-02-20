#!/bin/bash
# Claude Code statusLine - lualine flat style, Tokyo Night Storm

read -r -d '' input < /dev/stdin

eval "$(echo "$input" | jq -r '
  "cwd=" + (.workspace.current_dir // .cwd | @sh),
  "model=" + (.model.display_name // "" | @sh),
  "used_pct=" + ((.context_window.used_percentage // 0) | floor | tostring),
  "lines_added=" + ((.cost.total_lines_added // 0) | tostring),
  "lines_removed=" + ((.cost.total_lines_removed // 0) | tostring)
')"

reset=$'\033[0m'

BLUE=$'\033[38;2;122;162;247m'
PURP=$'\033[38;2;187;154;247m'
TEAL=$'\033[38;2;26;188;156m'
GRN=$'\033[38;2;158;206;106m'
RED=$'\033[38;2;247;118;142m'
ORNG=$'\033[38;2;255;158;100m'
SEP_CLR=$'\033[38;2;86;95;137m'

SEP=" ${SEP_CLR}|${reset} "

left="${BLUE}󰉋 $(basename "$cwd")${reset}"

short_model=$(echo "$model" | sed 's/^Claude //; s/ [0-9].*//')

if [ "$used_pct" -ge 80 ]; then
    pct_color=$RED
elif [ "$used_pct" -ge 50 ]; then
    pct_color=$ORNG
else
    pct_color=$TEAL
fi

diff_seg=""
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
    diff_seg="${SEP}${GRN}+${lines_added} ${RED}-${lines_removed}${reset}"
fi

printf "%s%s%s%s%s%s%s%s\n" \
    "$left" \
    "$diff_seg" \
    "$SEP" "${PURP}󰚩 ${short_model}${reset}" \
    "$SEP" "${pct_color}󰍛 ${used_pct}%${reset}"
