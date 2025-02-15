#!/usr/bin/bash

set -e  # Exit on any error

TARGET_DIR="/var/lib/linux-kata"

# Check if the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: $TARGET_DIR does not exist."
    exit 1
fi

# Find and list all .kata files without the extension
kata_files=$(find "$TARGET_DIR" -type f -name "*.kata" | sed 's|.*/||' | sed 's/\.kata$//')

# Check if there are any .kata files
if [ -z "$kata_files" ]; then
    echo "No .kata files found in $TARGET_DIR."
    exit 0
fi

# Display the list using less
echo "$kata_files" | less -F
