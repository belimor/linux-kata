#!/usr/bin/bash

set -e  # Exit on any error

TARGET_FILE="/usr/local/bin/linux-kata"
TARGET_DIR="/var/lib/linux-kata"
LK_INDEX="$TARGET_DIR/index"

# Function to confirm before deletion
confirm() {
    read -p "Are you sure you want to delete $1? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipped $1"
        return 1
    fi
    return 0
}

# Remove the target file if it exists
if [ -f "$TARGET_FILE" ]; then
    confirm "$TARGET_FILE" && rm -f "$TARGET_FILE" && echo "Removed $TARGET_FILE."
else
    echo "$TARGET_FILE does not exist. No changes made."
fi

# Remove the target directory if it exists
if [ -d "$TARGET_DIR" ]; then
    confirm "$TARGET_DIR" && rm -rf "$TARGET_DIR" && echo "Removed $TARGET_DIR."
else
    echo "$TARGET_DIR does not exist. No changes made."
fi
