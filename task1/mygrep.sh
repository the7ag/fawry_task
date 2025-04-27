#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 PATTERN FILE"
    exit 1
fi

searchingPattern="$1"
filePath="$2"
echo "Searching for '$searchingPattern' in '$filePath'"