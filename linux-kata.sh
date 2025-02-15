#!/usr/bin/bash

# Function to show help message
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, help          Show this help message."
    echo "  enable            Enable a feature."
    echo "  disable           Disable a feature."
    echo "  list              List available items."
    echo "  change <file>     Change to the specified file (default: $DEFAULT_FILE)."
    echo "  (no arguments)    Run the script as usual."
    exit 0
}

# Function to enable a feature
enable_feature() {
    echo "Linux-kata enabled"
    source enable.sh
}

# Function to disable a feature
disable_feature() {
    echo "Linux-kata disabled"
    source disable.sh
}

case "$1" in
    -h|help)
        show_help
        ;;
    enable)
        enable_feature
        ;;
    disable)
        disable_feature
        ;;
    list)
        list_items
        ;;
    change)
        if [[ -z "$2" ]]; then
            echo "Error: Missing file name for 'change' command."
            exit 1
        fi
        change_file "$2"
        ;;
    "")
        echo "Running script as usual..."
        # Place your usual script logic here
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo "Use '$0 -h' or '$0 help' for usage information."
        exit 1
        ;;
esac

# File containing the list of blocks
COMMANDS_FILE="commands.txt"

# File to store the index of the last used block
LAST_INDEX_FILE="index.txt"

# Ensure the commands file exists
if [[ ! -f $COMMANDS_FILE ]]; then
    echo "Error: $COMMANDS_FILE not found. Please create the file with jinja blocks."
    exit 1
fi

# Variables to store extracted block names and contents
inside_block=false
block_name=""
declare -a JINJA_BLOCKS
declare -A BLOCK_CONTENTS
current_content=""

# Read the file line by line
while IFS= read -r line; do
    if [[ $line =~ ^\{\%\ block\ ([a-zA-Z0-9_]+)\ \%\}$ ]]; then
        # Start a new block
        block_name="${BASH_REMATCH[1]}"
        JINJA_BLOCKS+=("$block_name")  # Store block name
        current_content=""  # Reset content storage
        inside_block=true
    elif [[ $line =~ ^\{\%\ endblock\ \%\}$ ]]; then
        # End of block
        inside_block=false
        BLOCK_CONTENTS["$block_name"]="$current_content"  # Save block content
    elif $inside_block; then
        # Append line to block content
        current_content+="$line"$'\n'
    fi
done < "$COMMANDS_FILE"

# Ensure at least one block was found
if [[ ${#JINJA_BLOCKS[@]} -eq 0 ]]; then
    echo "Error: No Jinja blocks found in $COMMANDS_FILE."
    exit 1
fi

# Determine the last used index
if [[ -f $LAST_INDEX_FILE ]]; then
    LAST_INDEX=$(<"$LAST_INDEX_FILE")
else
    LAST_INDEX=-1
fi

# Calculate the next index (wrap around if needed)
NEXT_INDEX=$(( (LAST_INDEX + 1) % ${#JINJA_BLOCKS[@]} ))

# Get the block name
NEXT_BLOCK="${JINJA_BLOCKS[$NEXT_INDEX]}"

# Output only the content of the selected block
echo "${BLOCK_CONTENTS[$NEXT_BLOCK]}"

# Save the current index for the next execution
echo "$NEXT_INDEX" > "$LAST_INDEX_FILE"


