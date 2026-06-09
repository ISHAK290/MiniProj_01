#!/bin/bash

# ──────────────────────────────────────────
#  WHAT THIS SCRIPT DOES:
#  1. Checks how full your disk is
#  2. Checks how much RAM is being used
#  3. Checks if important services are running
#  4. Saves everything to a log file
# ──────────────────────────────────────────

LOG="health_log.txt"   # All results will be saved here

# ── Write a header with the current date/time ──
echo "==============================="  >> $LOG
echo "Report Time: $(date)"             >> $LOG
echo "==============================="  >> $LOG


# ── STEP 1: CHECK DISK SPACE ──
echo ""                                 >> $LOG
echo "-- DISK SPACE --"                 >> $LOG

# df -h shows disk usage in human-readable form (GB, MB)
# We skip the first line (header) using tail -n +2
df -h | tail -n +2 | while read LINE; do

    PERCENT=$(echo $LINE | awk '{print $5}' | tr -d '%')  # get usage number
    DRIVE=$(echo $LINE   | awk '{print $6}')               # get drive name

    if [ "$PERCENT" -ge 80 ]; then
        echo "WARNING: $DRIVE is $PERCENT% full"           >> $LOG
    else
        echo "OK: $DRIVE is $PERCENT% full"                >> $LOG
    fi

done


# ── STEP 2: CHECK RAM USAGE ──
echo ""                                 >> $LOG
echo "-- RAM USAGE --"                  >> $LOG

TOTAL=$(free | awk '/Mem/ {print $2}')   # total RAM in KB
USED=$(free  | awk '/Mem/ {print $3}')   # used  RAM in KB

# Calculate percentage: used / total * 100
PERCENT=$(( USED * 100 / TOTAL ))

# Convert KB to MB for easy reading
USED_MB=$(( USED  / 1024 ))
TOTAL_MB=$(( TOTAL / 1024 ))

if [ "$PERCENT" -ge 80 ]; then
    echo "WARNING: RAM is $PERCENT% used ($USED_MB MB / $TOTAL_MB MB)"  >> $LOG
else
    echo "OK: RAM is $PERCENT% used ($USED_MB MB / $TOTAL_MB MB)"       >> $LOG
fi


# ── STEP 3: CHECK IF SERVICES ARE RUNNING ──
echo ""                                 >> $LOG
echo "-- SERVICES --"                   >> $LOG

# List the services you want to monitor
SERVICES=("sshd" "cron" "nginx")

for SERVICE in "${SERVICES[@]}"; do

    # pgrep looks for a running process by name
    if pgrep -x "$SERVICE" > /dev/null; then
        echo "RUNNING: $SERVICE"        >> $LOG
    else
        echo "STOPPED: $SERVICE"        >> $LOG
    fi

done


# ── DONE ──
echo ""                                 >> $LOG
echo "--- done ---"                     >> $LOG
echo ""                                 >> $LOG

echo "Report saved to $LOG"   # print this to screen so you know it worked
