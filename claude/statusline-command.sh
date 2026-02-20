#!/bin/bash
# Claude Code statusLine - lualine flat style, Tokyo Night Storm

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

reset=$'\033[0m'

# Tokyo Night Storm colors
BLUE=$'\033[38;2;122;162;247m'      # #7aa2f7
PURP=$'\033[38;2;187;154;247m'      # #bb9af7
CYAN=$'\033[38;2;125;207;255m'      # #7dcfff
TEAL=$'\033[38;2;26;188;156m'       # #1abc9c
GRN=$'\033[38;2;158;206;106m'       # #9ece6a
RED=$'\033[38;2;247;118;142m'       # #f7768e
YLW=$'\033[38;2;224;175;104m'       # #e0af68
ORNG=$'\033[38;2;255;158;100m'      # #ff9e64
FG=$'\033[38;2;169;177;214m'        # #a9b1d6
SEP_CLR=$'\033[38;2;86;95;137m'     # #565f89

SEP=" ${SEP_CLR}|${reset} "

dir=$(basename "$cwd")

left="${BLUE}󰉋 ${dir}${reset}"

short_model=$(echo "$model" | sed 's/^Claude //; s/ [0-9].*//')

if [ "${used_pct:-0}" -ge 80 ] 2>/dev/null; then
    pct_color=$RED
elif [ "${used_pct:-0}" -ge 50 ] 2>/dev/null; then
    pct_color=$ORNG
else
    pct_color=$TEAL
fi

diff_seg=""
if [ "${lines_added:-0}" -gt 0 ] || [ "${lines_removed:-0}" -gt 0 ] 2>/dev/null; then
    diff_seg="${SEP}${GRN}+${lines_added} ${RED}-${lines_removed}${reset}"
fi

right="${diff_seg}${SEP}${PURP}󰚩 ${short_model}${reset}${SEP}${pct_color}󰍛 ${used_pct}%${reset}"

printf "%s%s\n" "$left" "$right"
