#!/bin/bash

showLineNumber=false
invertMatch=false
searchingPattern=""
filePath=""

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

while getopts ":nv" opt; do
    case $opt in
        n) showLineNumber=true ;;
        v) invertMatch=true ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))


if [ "$#" -ne 2 ]; then
    if [ "$#" -eq 1 ]; then
        echo "Error: Missing search pattern or filename." 1>&2
    else
        echo "Error: Incorrect number of arguments" 1>&2
    fi
    usage
    exit 1
fi

searchingPattern="$1"
filePath="$2"

if [ -z "$searchingPattern" ]; then
    echo "Error: Missing search pattern" 1>&2
    usage
    exit 1
fi

if [ ! -f "$filePath" ]; then
    echo "Error: file '$filePath' does not exist" 1>&2
    exit 1
fi
if [ ! -r "$filePath" ]; then
    echo "Error: file '$filePath' is not readable" 1>&2
    exit 1
fi

patternLower=$(echo "$searchingPattern" | tr '[:upper:]' '[:lower:]')
lineNumber=0

while read line; do
    lineNumber=$((lineNumber + 1))
    lineLower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    match=false
    if [[ "$lineLower" == *"$patternLower"* ]]; then
        match=true;
    fi

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

    if [ "$printLine" = true ]; then
        if [ "$showLineNumber" = true ]; then   
            echo "$lineNumber: $line"
        else
            echo "$line"
        fi
    fi
done < "$filePath"

exit 0
