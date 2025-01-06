#!/bin/bash

LOGFILE="/var/log/laravel_artisan.log"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting Laravel Artisan commands..." >> $LOGFILE

php artisan migrate --force >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Laravel migrations completed successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Laravel migrations failed." >> $LOGFILE
    exit 1
fi

php artisan cache:clear >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Laravel cache cleared." >> $LOGFILE

php artisan route:clear >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Laravel route cache cleared." >> $LOGFILE

php artisan config:clear >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Laravel config cache cleared." >> $LOGFILE

php artisan queue:restart >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Laravel queues restarted." >> $LOGFILE

echo "$CURRENT_DATE - Laravel Artisan commands completed." >> $LOGFILE