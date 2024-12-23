#!/bin/bash

# Set the working directory based on the input parameter
working_dir="${1:-.}"  # Use the first parameter or default to the current directory

# Check if the specified directory exists
if [[ ! -d "$working_dir" ]]; then
    echo "Error: Directory '$working_dir' does not exist."
    exit 1
fi

paths_file="paths"                                            # Files to save outputs
functions_file="functions"

> "$paths_file"                                               # Clears the output files if they exist
> "$functions_file"

echo "SOURCES = \\" > "$paths_file"                           # Adds the Makefile header to the paths file

                                                              # Finds all .c files in the specified directory
c_files=($(find "$working_dir" -type f -name "*.c"))          # Stores files in an array
file_count=${#c_files[@]}                                     # Gets the total number of files
counter=0

for input_file in "${c_files[@]}"; do
    counter=$((counter + 1))                                  # Save the relative path to the paths file
    file_name=$(basename "$input_file")                      # Extract just the file name using basename

    # Add relative path to the Makefile
    relative_path="${input_file#$working_dir/}"              # Calculate relative path from the working directory
    if [[ $counter -lt $file_count ]]; then
        echo "    $relative_path \\" >> "$paths_file"         # Add a backslash for non-final lines
    else
        echo "    $relative_path" >> "$paths_file"            # No backslash for the last line
    fi

                                                              # Extract matching lines (not starting with "//" but
                                                              # preceded by a "//" comment) to the functions file
    awk -v file="$file_name" '                                # Pass only the file name
        BEGIN { first_function = 1; }                         # Check if the previous line starts with "//"
                                                              # the current line does not start with "//" and
                                                              # is not empty
        prev_comment && !/^\s*\/\// && $0 !~ /^\s*$/ {
            if (first_function) {
                print "\n" "//" file ":";                     # Print the file name only once
                first_function = 0;
            }
            print $0 ";";                                     # Print the current line, appending ";"
        }
                                                              # Update the comment flag
        {
            prev_comment = /^\s*\/\//;
        }
    ' "$input_file" >> "$functions_file"

done

echo "--- Paths File ---"                                     # Print the content of both files, separated by
echo ""                                                       # 3 blank lines
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
