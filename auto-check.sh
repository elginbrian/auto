#!/bin/bash
# Disk space check script

# Set the threshold (in percentage)
THRESHOLD=80

# Get the disk usage percentage
USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

# Compare the usage with the threshold
if [ $USAGE -gt $THRESHOLD ]; then
    echo "Warning: Disk space usage is at ${USAGE}%!" | mail -s "Disk Space Alert" your-email@example.com
else
    echo "Disk space usage is normal at ${USAGE}%."
fi
