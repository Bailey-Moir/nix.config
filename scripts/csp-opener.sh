#!/usr/bin/env bash
TIME_FILE="/tmp/eww/.csp_time"

mkdir -p $(dirname "$TIME_FILE") && touch $TIME_FILE

eww update cspEnum=$1

eww active-windows | grep -q "csp" || ~/.config/scripts/eww-open.sh csp

# Output time to TIME_FILE
echo $(date +%s%N) > $TIME_FILE

(
    sleep 1.5 && \
    [[ $(($(date +%s%N) - $(cat "$TIME_FILE"))) -ge 1500000000 ]] && \
    eww active-windows | \
    awk -F': ' '$2 == "csp" {print $1}' | \
    while read -r line; do
        eww close $line
    done
) &
