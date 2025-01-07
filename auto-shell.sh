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

get_linux_commands_from_gemini() {
  local question="$1"
  RESPONSE=$(gemini-cli prompt "$question
  Provide a list of Linux commands relevant to the question. Each command should be on a new line, with no comments, explanations, or additional formatting. Do not include code blocks, language markers, or any extra details. Ensure the commands are safe to run." 2>&1)

  if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
    echo "$RESPONSE" | sed '/^\s*$/d' | sed '/^\[.*\]$/d'  
  else
    echo "Error: Unable to retrieve commands or received an invalid response."
  fi
}

get_confidence_from_gemini() {
  local question="$1"
  RESPONSE=$(gemini-cli prompt "$question
  Provide a confidence score (0-100) indicating how likely these commands are to be safe and effective for the user's question. Don't be afraid to give a low score. Return only the score as a number, with no comments or extra formatting." 2>&1)

  if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
    echo "$RESPONSE" | sed '/^\s*$/d' | sed '/^\[.*\]$/d'  
  else
    echo "Error: Unable to retrieve confidence score or received an invalid response."
  fi
}

if [ "$1" == "ash" ]; then
  if [ -z "$2" ]; then
    echo "Usage: ash <your question>"
    exit 1
  fi

  QUESTION="${@:2}"
  COMMANDS=$(get_linux_commands_from_gemini "$QUESTION")
  
  if [ -n "$COMMANDS" ]; then
    echo ""
    echo -e "${CYAN}✨ Here are the suggested commands from Gemini:${RESET}"
    echo -e "${YELLOW}$COMMANDS${RESET}"
    echo ""

    CONFIDENCE=$(get_confidence_from_gemini "$QUESTION")

    echo -e "${CYAN}💡 Gemini's confidence score for these commands is: $CONFIDENCE%${RESET}"

    if [ "$CONFIDENCE" -ge 75 ]; then
      echo ""
      read -p "Do you want to run these commands automatically? (yes, I give my consent / no): " choice
      echo ""

      if [[ "$choice" == "yes, I give my consent" ]]; then
        echo -e "${CYAN}Running the following commands...${RESET}"
        echo "$COMMANDS" | while read -r command; do
          echo "Running: $command"
          eval "$command"
        done
      else
        echo "The commands were not run."
      fi
    else
      echo -e "${CYAN}⚠️ The confidence score is low ($CONFIDENCE%). The commands cannot be run automatically!${RESET}"
    fi

    echo ""
  else
    echo "No commands found for your question or the response was invalid."
  fi
else
  echo "Usage: ash <your question>"
fi