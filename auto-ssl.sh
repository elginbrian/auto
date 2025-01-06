#!/bin/bash

LOGFILE="/var/log/certbot_renewal.log"
EMAIL="your-email@example.com"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting SSL certificate renewal process..." >> $LOGFILE

sudo certbot renew --quiet
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - SSL certificates renewed successfully." >> $LOGFILE
    sudo systemctl reload nginx
    if [ $? -eq 0 ]; then
        echo "$CURRENT_DATE - Nginx reloaded successfully." >> $LOGFILE
        echo "SSL certificates have been renewed and Nginx reloaded successfully." | mail -s "SSL Renewal and Nginx Reloaded" $EMAIL
    else
        echo "$CURRENT_DATE - Failed to reload Nginx." >> $LOGFILE
        echo "Failed to reload Nginx after SSL renewal. Please check the logs for more details." | mail -s "Nginx Reload Failed" $EMAIL
    fi
else
    echo "$CURRENT_DATE - Failed to renew SSL certificates." >> $LOGFILE
    echo "SSL certificate renewal failed. Please check the logs for more details." | mail -s "SSL Renewal Failed" $EMAIL
fi

echo "$CURRENT_DATE - SSL certificate renewal process completed." >> $LOGFILE
