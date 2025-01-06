#!/bin/bash

THRESHOLD=80
EMAIL="elginbrian49@gmail.com"
LOGFILE="/var/log/disk_space_alert.log"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

DISK_USAGE=$(df -h | awk 'NR>1 {print $1, $5, $6}' | while read fs usage mount; do
    usage_num=$(echo $usage | sed 's/%//')
    if [ $usage_num -gt $THRESHOLD ]; then
        echo "$CURRENT_DATE - ALERT: $fs on $mount is at $usage usage" >> $LOGFILE
        echo -e "Warning: The filesystem $fs mounted on $mount is at $usage usage.\n\nFilesystem: $fs\nUsage: $usage\nMount Point: $mount\nDate: $CURRENT_DATE" | mail -s "Disk Space Alert: $fs on $mount" $EMAIL
    fi
done)

if [ -z "$DISK_USAGE" ]; then
    echo "$CURRENT_DATE - INFO: Disk space usage is normal." >> $LOGFILE
    echo "Disk space usage is normal at all filesystems."
else
    echo "Disk space usage alerts have been sent."
fi