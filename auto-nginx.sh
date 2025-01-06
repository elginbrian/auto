#!/bin/bash

SERVICE="nginx"
LOGFILE="/var/log/service_restart.log"
EMAIL="elginbrian49@gmail.com"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Checking status of $SERVICE..." >> $LOGFILE

if ! systemctl is-active --quiet $SERVICE; then
    echo "$CURRENT_DATE - $SERVICE is not running. Restarting..." >> $LOGFILE
    sudo systemctl restart $SERVICE >> $LOGFILE 2>&1
    if systemctl is-active --quiet $SERVICE; then
        echo "$CURRENT_DATE - $SERVICE has been successfully restarted." >> $LOGFILE
        echo "$SERVICE has been restarted successfully." | mail -s "$SERVICE Restarted" $EMAIL
    else
        echo "$CURRENT_DATE - Failed to restart $SERVICE." >> $LOGFILE
        echo "Failed to restart $SERVICE. Please check the logs for more details." | mail -s "$SERVICE Restart Failed" $EMAIL
    fi
else
    echo "$CURRENT_DATE - $SERVICE is already running." >> $LOGFILE
    echo "$SERVICE is already running."
fi

echo "$CURRENT_DATE - Service check completed." >> $LOGFILE
