#!/bin/bash

CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

LOG_FILE="ash.log"

log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

if ! command -v gemini-cli &> /dev/null; then
  echo -e "${RED}Error: gemini-cli is not installed or not in your PATH.${RESET}"
  echo "Please install gemini-cli by running: go install github.com/eliben/gemini-cli@latest"
  log_message "gemini-cli not found in PATH."
  exit 1
fi

if [ -z "$GEMINI_API_KEY" ]; then
  echo -e "${RED}Error: GEMINI_API_KEY is not set.${RESET}"
  echo "Please export your API key by running: export GEMINI_API_KEY=your_api_key_here"
  log_message "GEMINI_API_KEY is not set."
  exit 1
fi

get_linux_commands_from_gemini() {
  local question="$1"
  local response

  response=$(gemini-cli prompt "$question
  Provide a list of Linux commands relevant to the question. Each command should be on a new line, with no comments, explanations, or additional formatting. Do not include code blocks, language markers, or any extra details. Ensure the commands are safe to run." 2>&1)

  if [ $? -ne 0 ]; then
    log_message "gemini-cli failed: $response"
    echo "Error: Unable to retrieve commands from Gemini."
    return 1
  fi

  echo "$response" | sed '/^\s*$/d' | sed '/^\[.*\]$/d' | sed 's/```//g' | sed 's/^#.*//g'
}

get_confidence_from_gemini() {
  local question="$1"
  local response

  response=$(gemini-cli prompt "$question
  Provide a confidence score (0-100) indicating how likely these commands are to be safe and effective for the user's question. Don't be afraid to give a low score. Return only the score as a number, with no comments or extra formatting." 2>&1)

  if [ $? -ne 0 ]; then
    log_message "gemini-cli failed: $response"
    echo "Error: Unable to retrieve confidence score from Gemini."
    return 1
  fi

  if [[ "$response" =~ ^[0-9]+$ ]] && [ "$response" -ge 0 ] && [ "$response" -le 100 ]; then
    echo "$response"
  else
    log_message "Invalid confidence score: $response"
    echo "Error: Received an invalid confidence score."
    return 1
  fi
}

if [ "$1" == "ash" ]; then
  if [ -z "$2" ]; then
    echo "Usage: ash <your question>"
    log_message "No question provided."
    exit 1
  fi

  QUESTION="${@:2}"
  log_message "Processing question: $QUESTION"

  COMMANDS=$(get_linux_commands_from_gemini "$QUESTION")
  if [ $? -ne 0 ] || [ -z "$COMMANDS" ]; then
    echo "No commands found or the response was invalid."
    log_message "Failed to retrieve commands for: $QUESTION"
    exit 1
  fi

  echo -e "\n${CYAN}✨ Suggested commands from Gemini:${RESET}"
  echo -e "${YELLOW}$COMMANDS${RESET}\n"

  CONFIDENCE=$(get_confidence_from_gemini "$QUESTION")
  if [ $? -ne 0 ]; then
    log_message "Failed to retrieve confidence score for: $QUESTION"
    exit 1
  fi

  echo -e "${CYAN}💡 Gemini's confidence score: $CONFIDENCE%${RESET}"

  if [ "$CONFIDENCE" -ge 75 ]; then
    echo ""
    read -p "Do you want to run these commands automatically? (yes / no / dry-run): " choice
    echo ""

    if [[ "$choice" == "yes" ]]; then
      echo -e "${CYAN}Running the following commands...${RESET}"
      echo "$COMMANDS" | while read -r command; do
        if [ -n "$command" ]; then
          echo "Running: $command"
          eval "$command" || log_message "Command failed: $command"
        fi
      done
    elif [[ "$choice" == "dry-run" ]]; then
      echo -e "${CYAN}Dry-run mode: Commands will not be executed.${RESET}"
      echo "$COMMANDS"
    else
      echo "The commands were not run."
    fi
  else
    echo -e "${CYAN}⚠️ Low confidence score ($CONFIDENCE%). Commands will not be run automatically.${RESET}"
  fi
else
  echo "Usage: ash <your question>"
  log_message "Invalid usage."
fi