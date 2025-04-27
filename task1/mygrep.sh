#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <PATTERN> <FILE>"
    exit 1
fi

searchingPattern="$1"
filePath="$2"

if [ ! -f "$filePath" ]; then
    echo "Error: file '$filePath' does not exist"
    exit 1
fi

patternLower=$(echo "$searchingPattern" | tr '[:upper:]' '[:lower:]')

while read line; do
    lineLower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    if [[ "$lineLower" == *"$patternLower"* ]]; then
        echo "$line"
    fi
done < "$filePath"
exit 0
