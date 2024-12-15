#!/bin/bash

# Files to save outputs
paths_file="paths"
functions_file="functions"

# Clear the output files if they exist
> "$paths_file"
> "$functions_file"

# Add the Makefile header to the paths file
echo "SOURCES = \\" > "$paths_file"

# Find all C files in the current directory
c_files=($(find . -type f -name "*.c")) # Store files in an array
file_count=${#c_files[@]} # Get the total number of files
counter=0

for input_file in "${c_files[@]}"; do
    counter=$((counter + 1))
    # Save the relative path to the paths file
    if [[ $counter -lt $file_count ]]; then
        echo "    ${input_file#./} \\" >> "$paths_file" # Add a backslash for non-final lines
    else
        echo "    ${input_file#./}" >> "$paths_file" # No backslash for the last line
    fi

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
echo "--- Paths File ---"
echo ""
cat "$paths_file"
echo ""
echo ""
echo "--- Functions File ---"
cat "$functions_file"
echo ""

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
