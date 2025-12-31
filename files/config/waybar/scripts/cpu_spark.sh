#!/usr/bin/env bash
set -euo pipefail

# spark chars (low->high)
SPARK=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
HIST_LEN=16
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/waybar-sparks"
CPU_STATE="$STATE_DIR/cpu_hist"

mkdir -p "$STATE_DIR"
touch "$CPU_STATE"

# Read total CPU usage from /proc/stat
read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
prev="$(cat "$STATE_DIR/cpu_prev" 2>/dev/null || true)"

cur_total=$((user+nice+system+idle+iowait+irq+softirq+steal))
cur_idle=$((idle+iowait))

if [[ -n "${prev}" ]]; then
  prev_total="${prev%% *}"
  prev_idle="${prev##* }"
  diff_total=$((cur_total - prev_total))
  diff_idle=$((cur_idle - prev_idle))

  if (( diff_total > 0 )); then
    usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
  else
    usage=0
  fi
else
  usage=0
fi

printf "%s %s\n" "$cur_total" "$cur_idle" > "$STATE_DIR/cpu_prev"

# Update history
hist="$(tr -cd '0-9 ' < "$CPU_STATE")"
hist="${hist} ${usage}"
# Trim to HIST_LEN numbers
hist="$(echo "$hist" | awk -v n="$HIST_LEN" '{for(i=NF-n+1;i<=NF;i++) if(i>0) printf $i (i==NF?ORS:OFS)}')"
echo "$hist" > "$CPU_STATE"

# Build sparkline
spark=""
for v in $hist; do
  idx=$(( v * 7 / 100 ))
  spark+="${SPARK[$idx]}"
done

# JSON output for Waybar
printf '{"text":"󰻠  %s %3d%%"}\n' "$spark" "$usage"
