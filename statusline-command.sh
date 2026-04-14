#!/bin/sh
# Claude Code status line script
# Shows: current directory, git branch, model name, context usage

# ── Color name helper ─────────────────────────────────────────────────────────
# Usage: color_code <name>  → outputs the ANSI escape sequence for that color
# Supported names: black, red, green, yellow, blue, magenta, cyan, white,
#                  bright_black (gray), bright_red, bright_green, bright_yellow,
#                  bright_blue, bright_magenta, bright_cyan, bright_white, reset
color_code() {
  case "$1" in
    black)          printf '\033[30m' ;;
    red)            printf '\033[31m' ;;
    green)          printf '\033[32m' ;;
    yellow)         printf '\033[33m' ;;
    blue)           printf '\033[34m' ;;
    magenta)        printf '\033[35m' ;;
    cyan)           printf '\033[36m' ;;
    white)          printf '\033[37m' ;;
    bright_black|gray|grey) printf '\033[90m' ;;
    bright_red)     printf '\033[91m' ;;
    bright_green)   printf '\033[92m' ;;
    bright_yellow)  printf '\033[93m' ;;
    bright_blue)    printf '\033[94m' ;;
    bright_magenta) printf '\033[95m' ;;
    bright_cyan)    printf '\033[96m' ;;
    bright_white)   printf '\033[97m' ;;
    reset|*)        printf '\033[0m'  ;;
  esac
}

# Convenience variables for frequently used colors
C_RESET=$(color_code reset)
C_DIR=$(color_code blue)
C_BRANCH=$(color_code yellow)
C_MODEL=$(color_code cyan)
C_GREEN=$(color_code bright_green)
C_YELLOW=$(color_code yellow)
C_RED=$(color_code red)
C_GRAY=$(color_code gray)

input=$(cat)

# Current working directory (shortened: replace $HOME with ~)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
short_cwd=$(echo "$cwd" | sed "s|^$HOME|~|")

# Git branch (skip optional locks to avoid contention)
git_branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Context usage percentage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Rate limit usage
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ── Line 1: directory, git branch, model, context usage ──────────────────────
line1=$(printf '%s%s%s' "$C_DIR" "$short_cwd" "$C_RESET")

if [ -n "$git_branch" ]; then
  line1=$(printf '%s %s(%s)%s' "$line1" "$C_BRANCH" "$git_branch" "$C_RESET")
fi

if [ -n "$model" ]; then
  line1=$(printf '%s %s%s%s' "$line1" "$C_MODEL" "$model" "$C_RESET")
fi

if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  # Color: green < 50%, yellow 50-80%, red > 80%
  if [ "$used_int" -ge 80 ]; then
    ctx_color=$C_RED
  elif [ "$used_int" -ge 50 ]; then
    ctx_color=$C_YELLOW
  else
    ctx_color=$C_GREEN
  fi
  line1=$(printf '%s %sctx:%d%%%s' "$line1" "$ctx_color" "$used_int" "$C_RESET")
fi

# ── Line 2: session usage (5-hour) and week usage (7-day) ────────────────────
line2=""

if [ -n "$five_hour_pct" ]; then
  five_int=$(printf '%.0f' "$five_hour_pct")
  usage_remaining=$((100 - five_int))

  # Calculate time remaining percentage (5-hour window = 18000 seconds total)
  # Default to 50 (neutral) when resets_at is missing
  time_remaining_pct=50
  if [ -n "$five_hour_resets" ]; then
    now=$(date +%s)
    secs_left=$((five_hour_resets - now))
    if [ "$secs_left" -lt 0 ]; then
      secs_left=0
    fi
    # time_remaining_pct = secs_left / 18000 * 100, computed with integer arithmetic
    time_remaining_pct=$((secs_left * 100 / 18000))
    if [ "$time_remaining_pct" -gt 100 ]; then
      time_remaining_pct=100
    fi
  fi

  # Urgency block color via composite score:
  #   urgency_score = used_pct × time_remaining_pct / 100
  #   < 25  → GREEN   (low usage or plenty of time left)
  #   25-40 → YELLOW
  #   > 40  → RED     (high usage with significant time remaining)
  urgency_score=$((five_int * time_remaining_pct / 100))
  if [ "$urgency_score" -gt 40 ]; then
    urgency_color=$C_RED
  elif [ "$urgency_score" -ge 25 ]; then
    urgency_color=$C_YELLOW
  else
    urgency_color=$C_GREEN
  fi

  # Session usage color (existing per-usage coloring kept for the text)
  if [ "$five_int" -ge 80 ]; then
    five_color=$C_RED
  elif [ "$five_int" -ge 50 ]; then
    five_color=$C_YELLOW
  else
    five_color=$C_GREEN
  fi

  line2=$(printf '%s█ %d%s %ssession:%d%%%s' "$urgency_color" "$urgency_score" "$C_RESET" "$five_color" "$five_int" "$C_RESET")

  # Append reset time if available (Unix timestamp → local HH:MM)
  if [ -n "$five_hour_resets" ]; then
    reset_time=$(date -r "$five_hour_resets" '+%H:%M' 2>/dev/null)
    if [ -n "$reset_time" ]; then
      line2=$(printf '%s %s↺%s%s' "$line2" "$C_GRAY" "$reset_time" "$C_RESET")
    fi
  fi
fi

if [ -n "$seven_day_pct" ]; then
  seven_int=$(printf '%.0f' "$seven_day_pct")
  if [ "$seven_int" -ge 80 ]; then
    week_color=$C_RED
  elif [ "$seven_int" -ge 50 ]; then
    week_color=$C_YELLOW
  else
    week_color=$C_GREEN
  fi
  week_str=$(printf '%sweek:%d%%%s' "$week_color" "$seven_int" "$C_RESET")
  if [ -n "$line2" ]; then
    line2=$(printf '%s %s' "$line2" "$week_str")
  else
    line2="$week_str"
  fi
fi

# ── Output ────────────────────────────────────────────────────────────────────
if [ -n "$line2" ]; then
  printf '%s\n%s' "$line1" "$line2"
else
  printf '%s' "$line1"
fi
