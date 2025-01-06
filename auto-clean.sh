#!/bin/bash
# Auto-cleanup script

echo "Cleaning up unused packages and logs..."
sudo apt autoremove -y
sudo apt autoclean -y
sudo journalctl --vacuum-time=7d
echo "Cleanup completed."
