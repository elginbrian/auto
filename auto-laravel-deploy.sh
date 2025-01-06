#!/bin/bash

LOGFILE="/var/log/laravel_deployment.log"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting Laravel deployment..." >> $LOGFILE

git pull origin master >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Code pulled successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Failed to pull code." >> $LOGFILE
    exit 1
fi

php artisan migrate --force >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Laravel migrations completed." >> $LOGFILE

php artisan config:clear >> $LOGFILE 2>&1
php artisan cache:clear >> $LOGFILE 2>&1
php artisan route:clear >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Laravel caches cleared." >> $LOGFILE

php artisan queue:restart >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Laravel queues restarted." >> $LOGFILE

echo "$CURRENT_DATE - Laravel deployment completed." >> $LOGFILE
