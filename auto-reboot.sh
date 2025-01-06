#!/bin/bash
# Auto-reboot check script

if [ -f /var/run/reboot-required ]; then
    echo "Reboot required. Rebooting now..."
    sudo reboot
else
    echo "No reboot required."
fi
