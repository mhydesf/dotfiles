#!/usr/bin/env bash
set -euo pipefail

SPARK=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
HIST_LEN=6
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/waybar-sparks"
MEM_STATE="$STATE_DIR/mem_hist"

mkdir -p "$STATE_DIR"
touch "$MEM_STATE"

# MemAvailable is the best “free-ish” measure on Linux
mem_total_kb="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)"
mem_avail_kb="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)"

used_kb=$((mem_total_kb - mem_avail_kb))
usage=$(( (100 * used_kb) / mem_total_kb ))

hist="$(tr -cd '0-9 ' < "$MEM_STATE")"
hist="${hist} ${usage}"
hist="$(echo "$hist" | awk -v n="$HIST_LEN" '{for(i=NF-n+1;i<=NF;i++) if(i>0) printf $i (i==NF?ORS:OFS)}')"
echo "$hist" > "$MEM_STATE"

spark=""
for v in $hist; do
  idx=$(( v * 7 / 100 ))
  spark+="${SPARK[$idx]}"
done

printf '{"text":"󱤓  %s %3d%%"}\n' "$spark" "$usage"
