#!/bin/bash
# Claude Code status line; reads session JSON on stdin.
# Left: box status, model, git branch, rate limits.
# Right: keyboard hints, project directory.

input=$(cat)
# Keep the last input around for debugging
mkdir -p ~/.cache && printf '%s\n' "$input" >~/.cache/claude-statusline.json
field() { jq -r "$1 // empty" <<<"$input"; }

bold=$'\e[1m' dim=$'\e[2m' red=$'\e[1;31m' yellow=$'\e[1;33m' warn=$'\e[33m' ok=$'\e[32m' white=$'\e[97m' reset=$'\e[0m'

# Display width in terminal cells (emoji count as two)
vis_width() { printf '%s' "$1" | wc -L; }

# Each segment is kept as plain text (for width) and styled text (for output)
left_plain=() left=()
add() {
  left_plain+=("$1")
  left+=("${2:-$1}")
}

if [ -n "${BOX_ACTIVE:-}" ]; then
  add "📦 BOX" "$yellow📦 BOX$reset"
else
  add "🚨 NOT BOXED" "$red🚨 NOT BOXED$reset"
fi

model=$(field .model.display_name)
[ -n "$model" ] && add "🤖 $model" "🤖 $bold$model$reset"

cwd=$(field .workspace.current_dir)
cwd=${cwd:-$PWD}
branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
[ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
[ -n "$branch" ] && add "🌿 $branch"

pct() {
  local p
  p=$(field "$2")
  [ -z "$p" ] && return
  p=$(printf '%.0f' "$p")
  if [ "$p" -ge 80 ]; then
    add "$1 $p%" "$1 $red$p%$reset"
  elif [ "$p" -ge 50 ]; then
    add "$1 $p%" "$1 $warn$p%$reset"
  else
    add "$1 $p%" "$1 $ok$p%$reset"
  fi
}
pct 세션 .rate_limits.five_hour.used_percentage
pct 주간 .rate_limits.seven_day.used_percentage

sep=" · "
join() {
  local IFS=$'\x1f' s
  s="$*"
  printf '%s' "${s//$'\x1f'/$sep}"
}
lstyled=$(join "${left[@]}")
left_w=$(vis_width "$(join "${left_plain[@]}")")

# Where the session was started, which stays put if Claude cd's around
dir=$(field .workspace.project_dir)
dir=${dir:-$cwd}
[[ $dir == "$HOME" || $dir == "$HOME"/* ]] && dir="~${dir#"$HOME"}"
hints="? shortcuts · esc interrupt"

cols=${COLUMNS:-80}
# Claude Code indents the status line by a couple of columns; leave slack
width=$((cols - 4))
right="$dim$hints$reset  $white$dir$reset"
right_w=$(vis_width "$hints  $dir")
if [ $((left_w + right_w + 2)) -gt "$width" ]; then
  right="$white$dir$reset" right_w=$(vis_width "$dir")
fi

gap=$((width - left_w - right_w))
[ "$gap" -lt 2 ] && gap=2
printf '%s%*s%s' "$lstyled" "$gap" "" "$right"
