#!/bin/bash

# Check if the directory is provided as an argument
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Get the directory from the argument
directory="$1"

# If the directory is ".", set it to the current directory
if [ "$directory" == "." ]; then
    directory="."
fi

# Ensure the provided directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' does not exist."
    exit 2
fi

# Find all .c files in the specified directory and subdirectories
for input_file in $(find "$directory" -type f -name "*.c"); do
    # Print the file name being processed
    echo "Processing file: $input_file"

    # Process each file with awk
    awk '
        # Check if the previous line starts with "//" and the current line does not start with "//"
        prev_comment && !/^\s*\/\// {
            # Print the current line with a semicolon at the end
            print $0 ";"
        }
        # Update the flag for whether the current line starts with "//"
        {
            prev_comment = /^\s*\/\//
        }
    ' "$input_file"
done
