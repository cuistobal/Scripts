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
    awk -v file="${input_file#./}" '
        BEGIN { first_function = 1; }
        # Check if the previous line starts with "//" and the current line does not start with "//" and is not empty
        prev_comment && !/^\s*\/\// && $0 !~ /^\s*$/ {
            # Print a blank line between files if it is not the first function of the script
            if (first_function) {
                print "";
            }
            print $0 ";";
            first_function = 0;
        }
        # Update the flag for whether the current line starts with "//"
        {
            prev_comment = /^\s*\/\//
        }
    ' "$input_file" >> "$functions_file"

done

# Print the content of both files, separated by 3 blank lines
echo "--- Paths File ---\n"
cat "$paths_file"
echo "\n\n--- Functions File ---"
cat "$functions_file"
echo "\n"
# Ask the user if they want to copy the content of either file
read -p "Do you want to copy the content of 'functions', 'paths', or 'none' to the clipboard? (f/p/n): " copy_choice
case "$copy_choice" in
    f)
        cat "$functions_file" | xsel -b
        echo "Functions content copied to clipboard."
        ;;
    p)
        cat "$paths_file" | xsel -b
        echo "Paths content copied to clipboard."
        ;;
esac

# Ask the user if they want to remove the function and path files
read -p "Do you want to remove the 'functions' and 'paths' files ? (Y/N): " remove_choice
case "$remove_choice" in
    Y)
        rm "$functions_file"
        rm "$paths_file"
        echo "Files have been removed."
        ;;
    *)
        echo "Relative paths to files have been saved to '$paths_file'."
        echo "Extracted functions have been saved to '$functions_file'."
        ;;
esac
