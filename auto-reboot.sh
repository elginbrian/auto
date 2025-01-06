#!/bin/bash

LOGFILE="/var/log/reboot_check.log"
EMAIL="elginbrian49@gmail.com"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Checking if reboot is required..." >> $LOGFILE

if [ -f /var/run/reboot-required ]; then
    echo "$CURRENT_DATE - Reboot required. Rebooting now..." >> $LOGFILE
    sudo reboot
    if [ $? -eq 0 ]; then
        echo "$CURRENT_DATE - Reboot initiated successfully." >> $LOGFILE
        echo "The system has been rebooted successfully." | mail -s "System Rebooted" $EMAIL
    else
        echo "$CURRENT_DATE - Failed to initiate reboot." >> $LOGFILE
        echo "Failed to reboot the system. Please check the logs for more details." | mail -s "Reboot Failed" $EMAIL
    fi
else
    echo "$CURRENT_DATE - No reboot required." >> $LOGFILE
    echo "No reboot required."
fi

echo "$CURRENT_DATE - Reboot check completed." >> $LOGFILE
