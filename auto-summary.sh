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
  PUBLIC_IP=$(curl -s ifconfig.me)
  USERS=$(who | wc -l)
  CURRENT_USER=$(whoami)
  ARCHITECTURE=$(uname -m)

  LOAD_AVERAGES=$(uptime | awk -F'load average:' '{ print $2 }')

  CPU_LOAD=$(top -bn1 | grep "load average:" | sed "s/.*, *\([0-9.]*\), *\([0-9.]*\), *\([0-9.]*\).*/\1, \2, \3/")
  CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

  MEM_INFO=$(free -h | grep Mem)
  RAM_USAGE=$(echo $MEM_INFO | awk '{print $3 "/" $2 " (" $3/$2*100 "% used)"}')
  SWAP_INFO=$(free -h | grep Swap)
  SWAP_USAGE=$(echo $SWAP_INFO | awk '{print $3 "/" $2 " (" $3/$2*100 "% used)"}')

  DISK_USAGE=$(df -h --output=source,pcent | grep -E '^/dev/' | awk '{print $1 " " $2}')
  STORAGE_DETAILS=$(lsblk -o NAME,FSTYPE,SIZE | grep -E '^(sd|nvme|mmcblk)')

  DISK_IO=$(iostat -d 1 2 | grep '^$' -A 1 | tail -n 1)

  if command -v lspci &> /dev/null; then
    GPU_INFO=$(lspci | grep -i 'vga\|3d\|2d' | awk -F ': ' '{print $2}')
  elif command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader)
  else
    GPU_INFO="GPU information unavailable."
  fi

  NETWORK_INTERFACE=$(ip -o -4 addr show | awk '{print $2, $4}')
  
  if command -v speedtest-cli &> /dev/null; then
    NETWORK_SPEED=$(speedtest-cli --simple | grep -E 'Download|Upload')
  else
    NETWORK_SPEED="Network speed test unavailable."
  fi

  DOCKER_CONTAINERS=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}")

  ACTIVE_PORTS=$(netstat -tuln | awk '{print $4}' | grep -Eo '[0-9]+$' | sort | uniq)

  SYSTEM_PROCESSES=$(ps aux --sort=-%cpu | head -n 10)
  MEMORY_PROCESSES=$(ps aux --sort=-%mem | head -n 5)

  if command -v sensors &> /dev/null; then
    CPU_TEMP=$(sensors | grep 'Core 0' | awk '{print $3}')
  else
    CPU_TEMP="Temperature data unavailable."
  fi

  FIREWALL_STATUS=$(ufw status verbose || echo "Firewall not configured")

  USER_SESSIONS=$(w)

  TOTAL_PACKAGES=$(dpkg -l | wc -l)

  echo "Hostname: $HOSTNAME, Kernel: $KERNEL, Uptime: $UPTIME, Last Reboot: $LAST_REBOOT, Public IP: $PUBLIC_IP, Users: $USERS, Current User: $CURRENT_USER, Architecture: $ARCHITECTURE, Load Averages: $LOAD_AVERAGES, CPU Load: $CPU_LOAD, CPU Usage: $CPU_USAGE%, RAM Usage: $RAM_USAGE, Swap Usage: $SWAP_USAGE, Disk Usage: $DISK_USAGE, Disk I/O: $DISK_IO, Storage Details: $STORAGE_DETAILS, GPU Info: $GPU_INFO, Network Interfaces: $NETWORK_INTERFACE, Network Speed: $NETWORK_SPEED, Docker Containers: $DOCKER_CONTAINERS, Active Ports: $ACTIVE_PORTS, System Processes: $SYSTEM_PROCESSES, Top Memory-Consuming Processes: $MEMORY_PROCESSES, CPU Temp: $CPU_TEMP, Firewall Status: $FIREWALL_STATUS, Active User Sessions: $USER_SESSIONS, Total Installed Packages: $TOTAL_PACKAGES"
}

get_summary_from_gemini() {
  local prompt="$1"
  RESPONSE=$(gemini-cli prompt "$prompt" 2>&1)

  if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
    echo ""
    echo -e "${CYAN}✨ Gemini's System Summary:${RESET}"
    echo -e "${YELLOW}$RESPONSE${RESET}"
    echo ""
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

  full_prompt="The following system information is available:
$system_info

User query: $user_query

Please provide a short summary (1 paragraph) based on the user's query."

  get_summary_from_gemini "$full_prompt"
}

process_command "$*"