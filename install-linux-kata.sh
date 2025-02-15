#!/usr/bin/bash

set -e  # Exit on any error

TARGET_FILE="/usr/local/bin/linux-kata"
TARGET_DIR="/var/lib/linux-kata"
LOCAL_FILE="./linux-kata.sh"
LK_INDEX="$TARGET_DIR/index"
KATAS_SRC="./katas"

if [ ! -f "$LOCAL_FILE" ]; then
    echo "Error: $LOCAL_FILE does not exist."
    exit 1
fi

if [ ! -f "$TARGET_FILE" ]; then
    cp "$LOCAL_FILE" "$TARGET_FILE"
    echo "Copied $LOCAL_FILE to $TARGET_FILE."
else
    echo "$TARGET_FILE already exists. No changes made."
fi

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    echo "Created directory $TARGET_DIR."
else
    echo "$TARGET_DIR already exists. No changes made."
fi

if [ ! -f "$LK_INDEX" ]; then
    echo "0" > $LK_INDEX
    echo "$LK_INDEX created"
else
    echo "$LK_INDEX already exists. No changes made."
fi

cp ./katas/*.* /var/lib/linux-kata/
if [ -d "$KATAS_SRC" ] && [ "$(ls -A "$KATAS_SRC")" ]; then
    cp "$KATAS_SRC"/* "$TARGET_DIR"/
    echo "Copied kata files to $TARGET_DIR."
else
    echo "Warning: $KATAS_SRC does not exist or is empty. No files copied."
fi
