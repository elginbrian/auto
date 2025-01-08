#!/bin/bash

CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

LOG_FILE="/tmp/terminal_output.log"
PID_FILE="/tmp/awc_pid"

check_gemini_cli() {
  if ! command -v gemini-cli &> /dev/null; then
    echo -e "${RED}Error: gemini-cli is not installed or not in PATH.${RESET}"
    echo "Please install gemini-cli first using: go install github.com/eliben/gemini-cli@latest"
    exit 1
  fi
}

check_gemini_api_key() {
  if [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${RED}Error: GEMINI_API_KEY is not set.${RESET}"
    echo "Please export your API key using: export GEMINI_API_KEY=your_api_key_here"
    exit 1
  fi
}

start_capturing() {
  if [ -f "$PID_FILE" ]; then
    echo -e "${YELLOW}Watcher is already running. Stop it first with: awc -s${RESET}"
    exit 1
  fi

  echo -e "${CYAN}Starting terminal output capture...${RESET}"
  rm -f "$LOG_FILE"
  script -q -c bash "$LOG_FILE" &
  echo $! > "$PID_FILE"
  echo -e "${CYAN}All terminal output is being logged to $LOG_FILE.${RESET}"
}

stop_capturing() {
  if [ ! -f "$PID_FILE" ]; then
    echo -e "${RED}No active watcher found.${RESET}"
    exit 1
  fi

  PID=$(cat "$PID_FILE")
  kill "$PID" 2>/dev/null
  rm -f "$PID_FILE"
  echo -e "${CYAN}Stopped terminal output capture.${RESET}"
}

analyze_log() {
  if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}No log file found. Start capturing with: awc -c${RESET}"
    exit 1
  fi

  echo -e "${CYAN}Analyzing terminal output...${RESET}"

  LOG_CONTENT=$(cat "$LOG_FILE")

  if [ -z "$LOG_CONTENT" ]; then
    echo -e "${YELLOW}Log file is empty. Nothing to analyze.${RESET}"
    exit 0
  fi

  PROMPT="Here is the terminal output I captured:\n$LOG_CONTENT\nCan you analyze it and provide any suggestions, insights, or improvements?"
  query_gemini_with_context "$PROMPT"
}

query_gemini_with_context() {
  PROMPT="$1"
  RESPONSE=$(gemini-cli prompt "$PROMPT" 2>&1)

  if [ $? -eq 0 ]; then
    PLAIN_RESPONSE=$(echo "$RESPONSE" | sed -E 's/[*`]+//g')
    echo -e "\n${CYAN}✨ Gemini Suggestion >> ${YELLOW}$PLAIN_RESPONSE${RESET}\n"
  else
    echo -e "${RED}Error: Unable to process the request.${RESET}\nResponse: $RESPONSE"
  fi
}

case "$1" in
  -c)
    check_gemini_cli
    start_capturing
    ;;
  -s)
    stop_capturing
    ;;
  -a)
    check_gemini_cli
    check_gemini_api_key
    analyze_log
    ;;
  *)
    echo -e "${YELLOW}Usage:${RESET}"
    echo "  awc -c   Start capturing terminal output (removes old log)."
    echo "  awc -s   Stop capturing terminal output."
    echo "  awc -a   Analyze captured log and provide suggestions."
    exit 1
    ;;
esac