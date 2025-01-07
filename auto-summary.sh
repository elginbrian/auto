#!/bin/bash

CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

if ! command -v gemini-cli &> /dev/null; then
  echo "Error: gemini-cli is not installed or not in your PATH."
  echo "Please install gemini-cli first by running: go install github.com/eliben/gemini-cli@latest"
  exit 1
fi

if [ -z "$GEMINI_API_KEY" ]; then
  echo "Error: GEMINI_API_KEY is not set."
  echo "Please export your API key by running: export GEMINI_API_KEY=your_api_key_here"
  exit 1
fi

get_system_info() {
  HOSTNAME=$(hostname)
  KERNEL=$(uname -r)
  UPTIME=$(uptime -p)
  LAST_REBOOT=$(who -b | awk '{print $3, $4}')
  PUBLIC_IP=$(curl -s ifconfig.me || echo "Unavailable")
  USERS=$(who | wc -l)
  CURRENT_USER=$(whoami)
  ARCHITECTURE=$(uname -m)
  LOAD_AVERAGES=$(uptime | awk -F'load average:' '{ print $2 }')

  CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {usage=100-$8; printf "%.2f", usage}')
  MEM_INFO=$(free -h | awk '/Mem:/ {print $3 "/" $2 " (" $3/$2*100 "% used)"}')
  SWAP_INFO=$(free -h | awk '/Swap:/ {if ($2 > 0) print $3 "/" $2 " (" $3/$2*100 "% used)"; else print "No Swap"}')
  DISK_USAGE=$(df -h --output=source,pcent | awk '/^\/dev/ {print $1 " " $2}')
  STORAGE_DETAILS=$(lsblk -o NAME,FSTYPE,SIZE | grep -E '^(sd|nvme)')

  if command -v lspci &> /dev/null; then
    GPU_INFO=$(lspci | grep -i 'vga\|3d\|2d' | awk -F ': ' '{print $2}')
  elif command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader)
  else
    GPU_INFO="GPU information unavailable."
  fi

  NETWORK_INTERFACE=$(ip -o -4 addr show | awk '{print $2, $4}')
  NETWORK_SPEED=$(command -v speedtest-cli &> /dev/null && speedtest-cli --simple | grep -E 'Download|Upload' || echo "Network speed test unavailable.")
  DOCKER_CONTAINERS=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | column -t || echo "No Docker containers running.")
  ACTIVE_PORTS=$(netstat -tuln | awk '{print $4}' | grep -Eo '[0-9]+$' | sort -n | uniq || echo "No active ports.")
  SYSTEM_PROCESSES=$(ps aux --sort=-%cpu | head -n 10)
  MEMORY_PROCESSES=$(ps aux --sort=-%mem | head -n 5)
  CPU_TEMP=$(command -v sensors &> /dev/null && sensors | awk '/Core 0/ {print $3}' || echo "Temperature data unavailable.")
  FIREWALL_STATUS=$(ufw status verbose 2>/dev/null || echo "Firewall not configured.")
  TOTAL_PACKAGES=$(dpkg -l 2>/dev/null | wc -l || echo "Package count unavailable.")

  echo -e "Hostname: $HOSTNAME\nKernel: $KERNEL\nUptime: $UPTIME\nLast Reboot: $LAST_REBOOT\nPublic IP: $PUBLIC_IP\nUsers: $USERS\nCurrent User: $CURRENT_USER\nArchitecture: $ARCHITECTURE\nLoad Averages: $LOAD_AVERAGES\nCPU Usage: $CPU_USAGE%\nRAM Usage: $MEM_INFO\nSwap Usage: $SWAP_INFO\nDisk Usage: $DISK_USAGE\nStorage Details: $STORAGE_DETAILS\nGPU Info: $GPU_INFO\nNetwork Interfaces: $NETWORK_INTERFACE\nNetwork Speed: $NETWORK_SPEED\nDocker Containers:\n$DOCKER_CONTAINERS\nActive Ports: $ACTIVE_PORTS\nTop Processes:\n$SYSTEM_PROCESSES\nTop Memory-Consuming Processes:\n$MEMORY_PROCESSES\nCPU Temp: $CPU_TEMP\nFirewall Status: $FIREWALL_STATUS\nTotal Installed Packages: $TOTAL_PACKAGES"
}

get_summary_from_gemini() {
  local prompt="$1"
  RESPONSE=$(gemini-cli prompt "$prompt" 2>&1)

  if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
    echo -e "${CYAN}✨ Gemini's System Summary:${RESET}"
    echo -e "${YELLOW}$RESPONSE${RESET}"
  else
    echo "Error: Unable to retrieve a summary from Gemini."
  fi
}

process_command() {
  if [ -z "$1" ]; then
    echo "Usage: asm <question>"
    exit 1
  fi

  local user_query="$1"

  system_info=$(get_system_info)

  full_prompt="The following system information is available:\n$system_info\n\nUser query: $user_query\n\nPlease provide a short summary (1 paragraph) based on the user's query."

  get_summary_from_gemini "$full_prompt"
}

process_command "$@"