#!/bin/bash

compare_files() {
    echo "Comparing $1 and $2"
    if diff -w "$1" "$2" > /dev/null; then
        echo "OK: File is ready for implementation."
    else
        echo "KO: Please do further checks, they are still some differences between the 2 files."
    fi
}

compare_files "$1" "$2"
