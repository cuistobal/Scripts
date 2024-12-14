#!/bin/bash

# Check if at least one file is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 file1 [file2 ...]"
    exit 1
fi

# Loop through all provided files
for input_file in "$@"; do
    # Check if the file exists and is readable
    if [ -f "$input_file" ]; then
#        echo "Processing file: $input_file"

        # Process the file with awk
        awk '
            # Check if the previous line starts with "//" and the current line does not start with "//"
            prev_comment && !/^\s*\/\// {
                print
            }
            # Update the flag for whether the current line starts with "//"
            {
                prev_comment = /^\s*\/\//
            }
        ' "$input_file"

#        echo "-----------------------------------"
#    else
#        echo "File not found or not readable: $input_file"
    fi
done
