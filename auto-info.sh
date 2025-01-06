#!/bin/bash 

declare -A ALIASES=( 
    ["ai"]="auto-info (Displays shortcut info for system commands) ~/auto/auto-info.sh"
    ["au"]="auto-update (Updates system packages and removes unnecessary ones) ~/auto/auto-update.sh"
    ["ac"]="auto-check (Checks system health: disk, memory, and services) ~/auto/auto-check.sh"
    ["ax"]="auto-nginx (Restarts Nginx service to apply changes) ~/auto/auto-nginx.sh"
    ["ar"]="auto-restart (Restarts the system to apply updates or fix issues) ~/auto/auto-restart.sh"
    ["asl"]="auto-ssl (Renews SSL certificates and reloads Nginx) ~/auto/auto-ssl.sh"
    ["acl"]="auto-clean (Cleans temporary files and frees up disk space) ~/auto/auto-clean.sh"
    ["adc"]="auto-docker-compose (Builds and starts Docker Compose containers) ~/auto/auto-docker-compose.sh"
    ["adk"]="auto-docker (Builds and deploys a Docker container for a project) ~/auto/auto-docker.sh"
    ["ago"]="auto-go (Builds and tests a Go project) ~/auto/auto-go.sh"
    ["alv"]="auto-laravel (Runs common Laravel Artisan commands) ~/auto/auto-laravel.sh"
    ["anp"]="auto-npm (Updates npm dependencies and runs tests) ~/auto/auto-npm.sh"
    ["ald"]="auto-laravel-deploy (Deploys a Laravel app with migrations and cache clearing) ~/auto/auto-laravel-deploy.sh"
    ["agd"]="auto-go-docker (Builds and deploys a Go project in Docker) ~/auto/auto-go-docker.sh"
)

echo
echo "=== Alias Shortcut ==="
echo

for alias_name in "${!ALIASES[@]}"; do
    entry="${ALIASES[$alias_name]}"

    script_name=$(echo "$entry" | cut -d'(' -f1)
    description=$(echo "$entry" | cut -d'(' -f2 | cut -d')' -f1)
    file_path=$(echo "$entry" | cut -d')' -f2 | sed 's/^ *//')

    echo "$alias_name --> $script_name ($description)"
done

echo

