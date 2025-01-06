#!/bin/bash
# System update script

# Update package list and upgrade packages
sudo apt update && sudo apt upgrade -y

# Clean up unnecessary packages
sudo apt autoremove -y

# Print a success message
echo "System update completed successfully."
