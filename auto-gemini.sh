#!/bin/bash

CYAN='\033[1;36m'
YELLOW='\033[1;33m'
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

show_help() {
  echo -e "${CYAN}Gemini CLI Helper Script${RESET}"
  echo "Usage: $0 ask [format] <your question>"
  echo
  echo "Formats (default is -shs):"
  echo "  -prg  : Answer in a single paragraph."
  echo "  -blp  : Answer as a list of bullet points."
  echo "  -cod  : Provide code only, without comments or explanation."
  echo "  -shs  : Answer in one short, concise sentence."
  echo "  -exa  : Provide a clear example to illustrate the answer."
  echo "  -exp  : Provide a detailed and thorough explanation."
  echo "  -sum  : Provide a concise summary in 2–3 sentences."
  echo "  -qna  : Answer in a question-and-answer format."
  echo
  echo "Example: $0 ask -prg \"What are the benefits of exercise?\""
  echo "Ensure GEMINI_API_KEY is set and gemini-cli is installed."
  exit 0
}

if [[ "$1" == "ask" && ("$2" == "--help" || "$2" == "-h") ]]; then
  show_help
fi

if [ "$1" == "ask" ]; then
  FORMAT="-shs" 

  if [[ "$2" =~ ^- ]]; then
    FORMAT="$2"
    shift 2
  else
    shift 1
  fi

  if [ -z "$1" ]; then
    echo "Error: No question provided."
    echo "Usage: $0 ask [format] <your question>"
    exit 1
  fi

  QUESTION="$*"

  case "$FORMAT" in
    -prg)
      PROMPT_SUFFIX="Please provide a clear and concise answer in one paragraph, in plain text."
      ;;
    -blp)
      PROMPT_SUFFIX="Please list the key points as bullet points, using plain text without symbols."
      ;;
    -cod)
      PROMPT_SUFFIX="Please provide only the code necessary to answer the question, without any formatting or comments."
      ;;
    -shs)
      PROMPT_SUFFIX="Please provide a concise answer in one short sentence, in plain text."
      ;;
    -exa)
      PROMPT_SUFFIX="Please provide a specific example to illustrate the answer clearly, in plain text."
      ;;
    -exp)
      PROMPT_SUFFIX="Please provide a detailed and thorough explanation of the topic, in plain text."
      ;;
    -sum)
      PROMPT_SUFFIX="Please summarize the answer in 2–3 concise sentences, in plain text."
      ;;
    -qna)
      PROMPT_SUFFIX="Please format the answer as a question-and-answer dialogue, in plain text."
      ;;
    *)
      echo "Warning: Unknown format '$FORMAT'. Using default format: -shs."
      PROMPT_SUFFIX="Please provide a concise answer in one short sentence, in plain text."
      ;;
  esac

  FULL_PROMPT="$QUESTION ($PROMPT_SUFFIX)"
  RESPONSE=$(gemini-cli prompt "$FULL_PROMPT" 2>&1)

  if [ $? -eq 0 ]; then
    PLAIN_RESPONSE=$(echo "$RESPONSE" | sed -E 's/[*`]+//g')
    echo -e "\n${CYAN}✨ Gemini >> ${YELLOW}$PLAIN_RESPONSE${RESET}\n"
  else
    echo -e "Error: Unable to process the request.\nResponse: $RESPONSE"
  fi
else
  echo "Error: Invalid command."
  echo "Usage: $0 ask [format] <your question>"
  echo "Use ask --help for more details."
  exit 1
fi