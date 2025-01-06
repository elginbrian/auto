#!/bin/bash

LOGFILE="/var/log/system_update.log"
EMAIL="elginbrian49@gmail.com"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting system update and upgrade process..." >> $LOGFILE

# Update package lists
sudo apt update >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Package lists updated successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Failed to update package lists." >> $LOGFILE
    echo "Failed to update package lists. Please check the logs for more details." | mail -s "System Update Failed" $EMAIL
    exit 1
fi

# Upgrade packages
sudo apt upgrade -y >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Packages upgraded successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Failed to upgrade packages." >> $LOGFILE
    echo "Failed to upgrade packages. Please check the logs for more details." | mail -s "System Upgrade Failed" $EMAIL
    exit 1
fi

# Remove unused packages
sudo apt autoremove -y >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Unused packages removed successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Failed to remove unused packages." >> $LOGFILE
    echo "Failed to remove unused packages. Please check the logs for more details." | mail -s "Package Cleanup Failed" $EMAIL
    exit 1
fi

echo "$CURRENT_DATE - System update and upgrade process completed successfully." >> $LOGFILE
echo "System update completed successfully." | mail -s "System Update Completed" $EMAIL