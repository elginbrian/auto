#!/bin/bash

LOGFILE="/var/log/docker_cleanup.log"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting Docker cleanup..." >> $LOGFILE

docker container prune -f >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Stopped containers removed." >> $LOGFILE

docker image prune -a -f >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Unused Docker images removed." >> $LOGFILE

docker volume prune -f >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Unused Docker volumes removed." >> $LOGFILE

docker network prune -f >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Unused Docker networks removed." >> $LOGFILE

echo "$CURRENT_DATE - Docker cleanup completed." >> $LOGFILE