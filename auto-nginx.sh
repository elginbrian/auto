#!/bin/bash
# Service restart script

# Set the service name
SERVICE="nginx"

# Check if the service is running
if ! systemctl is-active --quiet $SERVICE; then
    # Restart the service
    sudo systemctl restart $SERVICE
    echo "$SERVICE has been restarted."
else
    echo "$SERVICE is already running."
fi
