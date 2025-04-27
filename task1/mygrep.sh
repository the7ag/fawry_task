#!/bin/bash

# Default flags
showLineNumber=false
invertMatch=false
searchingPattern=""
filePath=""


# Print usage information
usage() {
    cat <<EOF
Usage: $0 [-n] [-v] <PATTERN> <FILE>
Search for PATTERN in FILE.

options:
    -n: Show line numbers
    -v: Invert match
    --help: Show this help message and exit

examples:
    $0 hello file.txt
    $0 -n hello file.txt
    $0 -vn hello file.txt
    $0 -n -v hello file.txt
EOF
    exit 1
}

# Old Logic for handling options
# if [ "$1" == "--help" ]; then
#     usage
# fi

# while [[ "$1" == -* ]]; do 
#   if [[ "$1" == *"n"* ]]; then 
#       showLineNumber=true
#   fi
#   if [[ "$1" == *"v"* ]]; then 
#       invertMatch=true
#   fi
#   shift
# done

# New Logic for handling options using getopts
# This loop will continue as long as it finds an option
# OPTIND is the index of the next argument to be processed
# opt contains the option character
# OPTARG is the argument provided to the option

while getopts ":nv" opt; do
    case $opt in
        n) showLineNumber=true ;;
        v) invertMatch=true ;;
        *) echo "Invalid option: -$OPTARG" 1>&2
           usage ;;
    esac
done

# Shift the arguments to the left by the number of options processed
# This will move the positional parameters to the left
# OPTIND - 1 is the number of options processed
# $# is the number of positional parameters
shift $((OPTIND - 1))

# Arguments validation
if [ "$#" -ne 2 ]; then
    if [ "$#" -eq 1 ]; then
        echo "Error: Missing search pattern or filename." 1>&2
    else
        echo "Error: Incorrect number of arguments" 1>&2
    fi
    usage
    exit 1
fi

# Assign the arguments to the variables
searchingPattern="$1"
filePath="$2"

# Check if the search pattern is empty -Shouldn't happen with the validation above-
if [ -z "$searchingPattern" ]; then
    echo "Error: Missing search pattern" 1>&2
    usage
    exit 1
fi

# Check if the file exists and is readable
if [ ! -f "$filePath" ]; then
    echo "Error: file '$filePath' does not exist" 1>&2
    exit 1
fi
if [ ! -r "$filePath" ]; then
    echo "Error: file '$filePath' is not readable" 1>&2
    exit 1
fi


# Main Processing Logic
# Convert the search pattern to lowercase
patternLower=$(echo "$searchingPattern" | tr '[:upper:]' '[:lower:]')

# Initialize the line number
lineNumber=0

# Read the file line by line
while read line; do
    lineNumber=$((lineNumber + 1))
    lineLower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    # Check if the line matches the search pattern
    match=false
    if [[ "$lineLower" == *"$patternLower"* ]]; then
        match=true;
    fi

    # Determine if the line should be printed
    printLine=false
    if [ "$invertMatch" = true ]; then
        if [ ! "$match" = true ]; then
            printLine=true
        fi
    else
        if [ "$match" = true ]; then
            printLine=true
        fi
    fi

    # Print the line if it should be printed
    if [ "$printLine" = true ]; then
        if [ "$showLineNumber" = true ]; then   
            echo "$lineNumber: $line"
        else
            echo "$line"
        fi
    fi
done < "$filePath"

exit 0
