#!/bin/bash

# ──────────────────────────────────────────
#  WHAT THIS SCRIPT DOES:
#  Schedules health_check.sh to run every hour automatically
# ──────────────────────────────────────────


# Step 1: Get the full path of health_check.sh
SCRIPT="$(pwd)/health_check.sh"

# Step 2: Make it executable
chmod +x "$SCRIPT"

# Step 3: Define the cron schedule
# Format:  minute  hour  day  month  weekday  command
#            0      *     *     *       *      = every hour at :00
CRON_JOB="0 * * * * $SCRIPT"

# Step 4: Add the job only if it's not already there (avoid duplicates)
if crontab -l 2>/dev/null | grep -q "$SCRIPT"; then
    echo "Cron job already exists. Nothing changed."
else
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Done! health_check.sh will now run every hour."
fi

# Step 5: Show current cron jobs so you can confirm
echo ""
echo "Your cron jobs:"
crontab -l
