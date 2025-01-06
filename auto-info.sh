#!/bin/bash 

# Define your aliases and their descriptions along with file paths
declare -A ALIASES=(
    ["ai"]="auto-info (Shows shortcut info) ~/auto/auto-info.sh"
    ["au"]="auto-update (Updates the system) ~/auto/auto-update.sh"
    ["ac"]="auto-check (Checks system health) ~/auto/auto-check.sh"
    ["ax"]="auto-nginx (Restarts Nginx service) ~/auto/auto-nginx.sh"
    ["ar"]="auto-restart (Restarts the system) ~/auto/auto-restart.sh"
    ["asl"]="auto-ssl (Updates SSL certificates) ~/auto/auto-ssl.sh"
    ["acl"]="auto-clean (Cleans temporary files) ~/auto/auto-clean.sh"
)

echo
echo "=== Alias Information ==="
echo

# Loop through each alias and provide details
for alias_name in "${!ALIASES[@]}"; do
    entry="${ALIASES[$alias_name]}"

    # Split the string by the first occurrence of '(' and ')'
    script_name=$(echo "$entry" | cut -d'(' -f1)
    description=$(echo "$entry" | cut -d'(' -f2 | cut -d')' -f1)
    file_path=$(echo "$entry" | cut -d')' -f2 | sed 's/^ *//')

    # Print alias with description and file path
    echo "$alias_name --> $script_name ($description)"
done

echo

