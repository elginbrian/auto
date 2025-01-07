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

get_tree_structure() {
  local tree_output
  tree_output=$(tree -C)

  local description="$1"
  RESPONSE=$(gemini-cli prompt "Based on the following directory structure, provide the 5 most relevant files or directories for the description.
Description: $description
Tree Structure: 
$tree_output" 2>&1)

  if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
    echo "$RESPONSE"
  else
    echo "Error: Unable to get relevant files or directories from Gemini."
  fi
}

select_file_or_directory() {
  local response="$1"
  echo -e "${CYAN}✨ Relevant Results from Gemini:${RESET}"
  echo -e "${YELLOW}$response${RESET}"

  echo "Select a file or directory to open by number (1-5), or type '?' to inspect them."

  read -p "Enter your choice: " choice

  if [[ "$choice" == "?" ]]; then
    inspect_files "$response"
  elif [[ "$choice" =~ ^[1-5]$ ]]; then
    selected_item=$(echo "$response" | sed -n "${choice}p")
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
      echo "Invalid selection."
    fi
  else
    echo "Invalid choice, please select a number between 1-5 or type '?' to inspect."
  fi
}

inspect_files() {
  local response="$1"
  echo -e "${CYAN}Inspecting contents of the 5 most relevant files or directories...${RESET}"

  while read -r item; do
    echo -e "${CYAN}Contents of $item:${RESET}"
    if [ -f "$item" ]; then
      cat "$item" || echo "Error: Failed to read file $item"
    elif [ -d "$item" ]; then
      ls -l "$item" || echo "Error: Failed to list contents of directory $item"
    fi
    echo ""
  done <<< "$response"

  echo "Reanalyzing based on the content of the selected directories/files..."
  get_tree_structure "$response"
}

auto_find() {
  if [ -z "$1" ]; then
    echo "Usage: auto-find <search-description>"
    exit 1
  fi

  local search_description="$1"

  local search_results
  search_results=$(get_tree_structure "$search_description")

  if [ -n "$search_results" ]; then
    select_file_or_directory "$search_results"
  else
    echo "No relevant files or directories found."
  fi
}

auto_find "$1"