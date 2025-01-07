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

interpret_description() {
  local description="$1"
  
  RESPONSE=$(gemini-cli prompt "Interpret the following instruction into search keywords for finding a file or directory on the system. Return just the keywords that will be used for searching:
  Instruction: $description" 2>&1)

  if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
    echo "$RESPONSE" | sed '/^\s*$/d' | sed '/^\[.*\]$/d'
  else
    echo "Error: Unable to interpret description into search keywords."
  fi
}

find_files() {
  local search_keyword="$1"
  echo "Searching for '$search_keyword' in the current directory and subdirectories..."

  search_results=$(find . -type f -iname "*$search_keyword*" -print)

  if [ -z "$search_results" ]; then
    echo "No files found matching '$search_keyword'."
    return
  fi

  echo "$search_results"
}

select_file() {
  local files="$1"
  
  selected_item=$(echo "$files" | fzf --preview "cat {}" --height 40% --border)

  if [ -n "$selected_item" ]; then
    if [ -d "$selected_item" ]; then
      echo -e "${CYAN}Navigating to directory: $selected_item${RESET}"
      cd "$selected_item" || echo "Failed to navigate to $selected_item"
    elif [ -f "$selected_item" ]; then
      echo -e "${CYAN}Inspecting file contents of $selected_item:${RESET}"
      cat "$selected_item" 2>&1 || echo "Error: Failed to read file $selected_item"

      read -p "Do you want to open this file with nano to edit? (yes / no): " edit_choice
      if [[ "$edit_choice" == "yes" ]]; then
        echo -e "${CYAN}Opening file with nano: $selected_item${RESET}"
        nano "$selected_item" || echo "Failed to open $selected_item with nano"
      else
        echo "File not opened."
      fi
    else
      echo "Invalid path. Either the directory or file doesn't exist."
    fi
  else
    echo "No file selected."
  fi
}

auto_find() {
  if [ -z "$1" ]; then
    echo "Usage: auto-find <search-description>"
    exit 1
  fi

  local search_description="$1"
  
  local search_keywords
  search_keywords=$(interpret_description "$search_description")

  if [ -z "$search_keywords" ]; then
    echo "Error: No valid search keywords generated from description."
    exit 1
  fi

  local search_results
  search_results=$(find_files "$search_keywords")

  if [ -n "$search_results" ]; then
    echo ""
    echo -e "${CYAN}✨Search Results:${RESET}"
    echo -e "${YELLOW}$search_results${RESET}"

    select_file "$search_results"
  else
    echo "No files or directories found matching '$search_keywords'."
  fi
}

auto_find "$1"
