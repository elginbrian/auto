#!/bin/bash

LOGFILE="/var/log/docker_compose_setup.log"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting Docker Compose setup..." >> $LOGFILE

docker-compose build >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Docker containers built successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Failed to build Docker containers." >> $LOGFILE
    exit 1
fi

docker-compose up -d >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Docker containers started successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Failed to start Docker containers." >> $LOGFILE
    exit 1
fi

echo "$CURRENT_DATE - Docker Compose setup completed." >> $LOGFILE
