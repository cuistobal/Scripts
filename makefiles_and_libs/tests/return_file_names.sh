#!/bin/bash

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <absolute_path> [extensions...]"
  exit 1
fi

# Get the directory to search in
directory="$1"

# Shift to process the remaining arguments (extensions)
shift

# If no extensions are provided or the second parameter is ".", include all files
if [ "$#" -eq 0 ] || [ "$1" = "." ]; then
  extensions=()
else
  extensions=("$@")
fi

# Check if the directory exists
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' does not exist."
  exit 2
fi

# Function to find files with specific extensions
find_files_with_extensions() {
  local dir="$1"
  local -a exts=("${!2}")
  local hidden="$3"

  # Remove ./ prefix from the output by using sed
  if [ "${#exts[@]}" -eq 0 ]; then
    # If no extensions are specified, find all files
    if [ "$hidden" = "no" ]; then
      find "$dir" -type f \( ! -name ".*" \) | sed "s|^$dir/||"
    else
      find "$dir" -type f \( -name ".*" \) | sed "s|^$dir/||"
    fi
  else
    # Build the `find` command dynamically for specified extensions
    if [ "$hidden" = "no" ]; then
      find "$dir" -type f \( ! -name ".*" \) \( $(printf -- '-name *%s -o ' "${exts[@]}" | sed 's/ -o $//') \) | sed "s|^$dir/||"
    else
      find "$dir" -type f \( -name ".*" \) \( $(printf -- '-name *%s -o ' "${exts[@]}" | sed 's/ -o $//') \) | sed "s|^$dir/||"
    fi
  fi
}

# Find non-hidden files
non_hidden_files=$(find_files_with_extensions "$directory" extensions[@] "no")

# Find hidden files
hidden_files=$(find_files_with_extensions "$directory" extensions[@] "yes")

# Print non-hidden files if any
if [ -n "$non_hidden_files" ]; then
  echo "$non_hidden_files"
fi

# Print a blank line if both blocks have content
if [ -n "$non_hidden_files" ] && [ -n "$hidden_files" ]; then
  echo
fi

# Print hidden files if any
if [ -n "$hidden_files" ]; then
  echo "$hidden_files"
fi
