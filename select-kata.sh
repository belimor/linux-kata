#!/usr/bin/bash

set -e  # Exit on any error

TARGET_FILE="/var/lib/linux-kata/kata"

# Validate arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 kata <kata_name>"
    exit 1
fi

if [ "$1" != "kata" ]; then
    echo "Error: The first argument must be 'kata'."
    exit 1
fi

KATA_NAME="$2"

# Ensure the target directory exists
#mkdir -p "$(dirname "$TARGET_FILE")"

# Store the argument in the file
echo "$KATA_NAME" > "$TARGET_FILE"

echo "Selected kata '$KATA_NAME' stored in $TARGET_FILE."
