#!/bin/bash

LOGFILE="/var/log/go_build_test.log"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting Go build and test process..." >> $LOGFILE

go build -o myapp >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Go project built successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Go build failed." >> $LOGFILE
    exit 1
fi

go test ./... >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Go tests passed successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Go tests failed." >> $LOGFILE
    exit 1
fi

echo "$CURRENT_DATE - Go build and test process completed successfully." >> $LOGFILE
