#!/usr/bin/env bash
set -Eeuo pipefail

# Usage: ./scripts/system_health.sh [log_file]
LOG_FILE="${1:-health_log.txt}"
DISK_WARNING_THRESHOLD=80

timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

# Linux CPU utilization: sample /proc/stat twice and calculate busy percentage.
read_cpu_counters() {
    awk '/^cpu / {
        idle = $5 + $6
        total = 0
        # Count user through steal. Guest counters are already included in user/nice.
        for (i = 2; i <= 9; i++) total += $i
        print total, idle
        exit
    }' /proc/stat
}

read -r total1 idle1 < <(read_cpu_counters)
sleep 1
read -r total2 idle2 < <(read_cpu_counters)

total_delta=$((total2 - total1))
idle_delta=$((idle2 - idle1))
if (( total_delta > 0 )); then
    cpu_usage="$(awk -v t="$total_delta" -v i="$idle_delta" \
        'BEGIN { printf "%.1f", (t-i)*100/t }')"
else
    cpu_usage="0.0"
fi

memory_usage="$(free | awk '/^Mem:/ {
    if ($2 > 0) printf "%.1f", (($2-$7)/$2)*100;
    else print "0.0"
}')"

disk_usage="$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')"

{
    printf 'Timestamp: %s\n' "$timestamp"
    printf 'CPU Usage: %s%%\n' "$cpu_usage"
    printf 'Memory Usage: %s%%\n' "$memory_usage"
    printf 'Disk Usage (/): %s%%\n' "$disk_usage"

    if (( disk_usage > DISK_WARNING_THRESHOLD )); then
        printf '[WARNING] Disk space high!\n'
    fi
    printf '%s\n' '----------------------------------------'
} | tee -a "$LOG_FILE"
