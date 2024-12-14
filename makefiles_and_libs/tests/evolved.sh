#!/bin/bash

# Files to save outputs
paths_file="paths"
functions_file="functions"

# Clear the output files if they exist
> "$paths_file"
> "$functions_file"

# Find all C files in the current directory
for input_file in $(find . -type f -name "*.c"); do
    # Save the relative path to the paths file
    echo "${input_file#./}" >> "$paths_file"

    # Extract matching lines (not starting with "//" but preceded by a "//" comment) to the functions file
    awk '
        # Check if the previous line starts with "//" and the current line does not start with "//"
        prev_comment && !/^\s*\/\// {
            # Print the function line with a semicolon at the end
            print $0 ";"
        }
        # Update the flag for whether the current line starts with "//"
        {
            prev_comment = /^\s*\/\//
        }
    ' "$input_file" >> "$functions_file"
done

# Confirmation of saved results
#echo "Relative paths to files have been saved to '$paths_file'."
#echo "Extracted functions (terminated with ;) have been saved to '$functions_file'."
