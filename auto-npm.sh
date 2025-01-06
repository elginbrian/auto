#!/bin/bash

LOGFILE="/var/log/npm_update.log"
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "$CURRENT_DATE - Starting npm dependency update..." >> $LOGFILE

npm update >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - npm dependencies updated successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Failed to update npm dependencies." >> $LOGFILE
    exit 1
fi

npm test >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    echo "$CURRENT_DATE - Tests passed successfully." >> $LOGFILE
else
    echo "$CURRENT_DATE - Tests failed." >> $LOGFILE
    exit 1
fi

echo "$CURRENT_DATE - npm update and test process completed successfully." >> $LOGFILE