#!/bin/bash

showLineNumber=false
invertMatch=false
searchingPattern=""
filePath=""

usage() {
    echo "Usage: $0 [-n] [-v] <PATTERN> <FILE>"
    echo "Search for PATTERN in FILE."
    echo ""
    echo "options:"
    echo "  -n: Show line numbers"
    echo "  -v: Invert match"
    echo "--help: Show this help message and exit"
    echo ""
    echo "examples:"
    echo "  $0 hello file.txt"
    echo "  $0 -n hello file.txt"
    echo "  $0 -vn hello file.txt"
    echo "  $0 -n -v hello file.txt"
    exit 1
}

if [ "$1" == "--help" ]; then
    usage
fi

while [[ "$1" == -* ]]; do 
  if [[ "$1" == *"n"* ]]; then 
      showLineNumber=true
  fi
  if [[ "$1" == *"v"* ]]; then 
      invertMatch=true
  fi
  shift
done

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [-n] [-v] <PATTERN> <FILE>"
    exit 1
fi

searchingPattern="$1"
filePath="$2"

if [ ! -f "$filePath" ]; then
    echo "Error: file '$filePath' does not exist"
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
