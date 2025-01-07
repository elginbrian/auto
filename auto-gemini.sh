#!/bin/bash

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

if [ "$1" == "ask" ]; then
  if [ -z "$2" ]; then
    echo "Usage: ask <your question>"
    exit 1
  fi

  QUESTION="${*:2}"
  
  RESPONSE=$(gemini-cli prompt "$QUESTION" 2>&1)
  if [ $? -eq 0 ]; then
    echo "Gemini Response:"
    echo "$RESPONSE"
  else
    echo "Error: $RESPONSE"
  fi
else
  echo "Usage: ask <your question>"
fi
