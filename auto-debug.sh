#!/bin/bash

CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

if ! command -v gemini-cli &> /dev/null; then
  echo "Error: gemini-cli is not installed or not in PATH."
  echo "Please install gemini-cli first using: go install github.com/eliben/gemini-cli@latest"
  exit 1
fi

if [ -z "$GEMINI_API_KEY" ]; then
  echo "Error: GEMINI_API_KEY is not set."
  echo "Please export your API key using: export GEMINI_API_KEY=your_api_key_here"
  exit 1
fi

query_gemini_with_context() {
  PROMPT="$1"
  RESPONSE=$(gemini-cli prompt "$PROMPT" 2>&1)

  if [ $? -eq 0 ]; then
    PLAIN_RESPONSE=$(echo "$RESPONSE" | sed -E 's/[*`]+//g')
    echo -e "\n${CYAN}✨ Gemini Suggestion >> ${YELLOW}$PLAIN_RESPONSE${RESET}\n"
  else
    echo -e "Error: Unable to process the request.\nResponse: $RESPONSE"
  fi
}

get_last_commands() {
  N=$1
  history | tail -n "$((N + 1))" | head -n "$N" | sed 's/^ *[0-9]* *//'
}

N_COMMANDS=${1:-1}

if ! [[ "$N_COMMANDS" =~ ^[0-9]+$ ]]; then
  echo -e "${RED}Error: Invalid number of commands specified. Please provide a positive integer.${RESET}"
  exit 1
fi

LAST_COMMANDS=$(get_last_commands "$N_COMMANDS")

if [ $? -ne 0 ]; then
  echo -e "${RED}⚠️  Detected an error in your recent commands:${RESET}"
  echo -e "${YELLOW}$LAST_COMMANDS${RESET}"
  
  PROMPT="I just ran these commands in my terminal:\n$LAST_COMMANDS\nOne of them returned an error. Can you suggest a solution or explain why it failed?"
  query_gemini_with_context "$PROMPT"
else
  echo -e "${CYAN}✅ Your recent commands were successful. No issues detected.${RESET}"
fi
