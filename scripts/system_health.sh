#!/usr/bin/env bash

# Simple server health check: CPU, RAM and Disk.

LOG_FILE="health_log.txt"
DISK_LIMIT=80

# 1. CPU usage (%). Reads the idle percentage from top.
CPU=$(top -bn1 | awk '/Cpu(s)/ {print int(100 - $8); exit}')

# 2. RAM usage (%).
RAM=$(free | awk '/Mem:/ {print int(($3 / $2) * 100)}')

# 3. Disk usage (%) of the root filesystem.
DISK=$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')

# Show the report and save it to a log file.
{
    echo "Server Health Report - $(date)"
    echo "------------------------------"
    echo "CPU Usage: ${CPU:-0}%"
    echo "Memory Usage: ${RAM:-0}%"
    echo "Disk Usage: ${DISK:-0}%"

    if [ "${DISK:-0}" -gt "$DISK_LIMIT" ]; then
        echo "WARNING: Disk usage is above 80%!"
    else
        echo "Status: HEALTHY"
    fi

    echo " "
} | tee -a "$LOG_FILE"
