#!/bin/bash

LOGFILE="/var/log/go_docker_deploy.log"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting Go Docker build and deploy..." >> $LOGFILE

go build -o myapp >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Go project built successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Go build failed." >> $LOGFILE
    exit 1
fi

docker build -t myapp:latest . >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Docker image built successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Docker image build failed." >> $LOGFILE
    exit 1
fi

docker run -d --name myapp myapp:latest >> $LOGFILE 2>&1
echo "$CURRENT_DATE - Docker container deployed successfully." >> $LOGFILE

echo "$CURRENT_DATE - Go Docker build and deploy completed." >> $LOGFILE
