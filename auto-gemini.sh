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
  echo "Usage: $0 ask <format> <your question>"
  echo "Formats:"
  echo "  -prg  : One paragraph."
  echo "  -blp  : Bullet points."
  echo "  -cod  : Code only, no comments."
  echo "  -shs  : One short sentence."
  echo "  -exa  : Provide an example."
  echo "  -exp  : Detailed explanation."
  echo "  -sum  : Concise summary (2–3 sentences)."
  echo "  -qna  : Question and answer format."
  echo "Example: $0 ask -prg \"What are the benefits of exercise?\""
  echo "Ensure GEMINI_API_KEY is set and gemini-cli is installed."
  exit 0
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
fi

if [ "$1" == "ask" ]; then
  if [ -z "$2" ]; then
    echo "Error: No format specified."
    echo "Usage: $0 ask <format> <your question>"
    exit 1
  fi

  FORMAT="$2"
  shift 2

  if [ -z "$1" ]; then
    echo "Error: No question provided."
    echo "Usage: $0 ask <format> <your question>"
    exit 1
  fi

  QUESTION="$*"

  case "$FORMAT" in
    -prg)
      PROMPT_SUFFIX="Please answer in one paragraph."
      ;;
    -blp)
      PROMPT_SUFFIX="Please answer in bullet points."
      ;;
    -cod)
      PROMPT_SUFFIX="Please provide code only, without any comments or explanation."
      ;;
    -shs)
      PROMPT_SUFFIX="Please answer in one short sentence."
      ;;
    -exa)
      PROMPT_SUFFIX="Please provide an example to illustrate the answer."
      ;;
    -exp)
      PROMPT_SUFFIX="Please provide a detailed explanation."
      ;;
    -sum)
      PROMPT_SUFFIX="Please provide a concise summary in 2 or 3 sentences."
      ;;
    -qna)
      PROMPT_SUFFIX="Please answer in a question-and-answer format."
      ;;
    *)
      PROMPT_SUFFIX="Please answer in one paragraph."
      ;;
  esac

  FULL_PROMPT="$QUESTION ($PROMPT_SUFFIX)"
  RESPONSE=$(gemini-cli prompt "$FULL_PROMPT" 2>&1)

  if [ $? -eq 0 ]; then
    echo -e "\n${CYAN}✨ Gemini >> ${YELLOW}$RESPONSE${RESET}\n"
  else
    echo -e "Error: Unable to process the request.\nResponse: $RESPONSE"
  fi
else
  echo "Error: Invalid command."
  echo "Usage: $0 ask <format> <your question>"
  echo "Use --help for more details."
  exit 1
fi