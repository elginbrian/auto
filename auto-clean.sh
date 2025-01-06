#!/bin/bash

LOGFILE="/var/log/system_cleanup.log"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting system cleanup..." >> $LOGFILE

echo "Cleaning up unused packages and logs..."
sudo apt autoremove -y >> $LOGFILE 2>&1
sudo apt autoclean -y >> $LOGFILE 2>&1
sudo journalctl --vacuum-time=7d >> $LOGFILE 2>&1

echo "Removing old kernels..."
sudo apt-get purge $(dpkg --list | grep linux-image | awk '{ print $2 }' | grep -v $(uname -r)) -y >> $LOGFILE 2>&1

echo "Cleaning up orphaned packages..."
sudo deborphan | xargs sudo apt-get -y remove --purge >> $LOGFILE 2>&1

echo "Removing old Snap versions..."
sudo snap list --all | awk '/disabled/ {print $1, $3}' | while read snapname version; do
    sudo snap remove "$snapname" --revision="$version" >> $LOGFILE 2>&1
done

echo "Cleaning up old package cache..."
sudo rm -rf /var/cache/apt/archives/*.deb >> $LOGFILE 2>&1

echo "$CURRENT_DATE - System cleanup completed." >> $LOGFILE

echo "System cleanup completed."