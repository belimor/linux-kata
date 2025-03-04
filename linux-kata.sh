#!/usr/bin/bash

# Function to show help message
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, help          		Show this help message."
    echo "  enable            		Enable Linux-Kata."
    echo "  disable           		Disable Linux Kata."
    echo "  list              		List available katas."
    echo "  reset-index			Restart kata"
    echo "  select-kata <kata-name>	Change kata to the specified kata-name."
    echo "  (no arguments)    		Disaply next kata block."
    exit 0
}

# Function to enable Linux-Kata
enable_feature() {
    BASHRC="$HOME/.bashrc"
    LINE='PROMPT_COMMAND="/usr/local/bin/linux-kata"'
    COMMENTED_LINE='#PROMPT_COMMAND="/usr/local/bin/linux-kata"'

    if grep -Fxq "$LINE" "$BASHRC"; then
        echo "Line already exists in ~/.bashrc No changes made."
    elif grep -Fxq "$COMMENTED_LINE" "$BASHRC"; then
        sed -i "s|$COMMENTED_LINE|$LINE|" "$BASHRC"
        echo "Uncommented existing line in ~/.bashrc"
    elif grep -q '^PROMPT_COMMAND=' "$BASHRC"; then
        sed -i 's|^PROMPT_COMMAND=.*|#&|' "$BASHRC"
        echo "$LINE" >> "$BASHRC"
        echo "Existing PROMPT_COMMAND was commented, and new line added to ~/.bashrc"
    else
        echo "$LINE" >> "$BASHRC"
        echo "Added line to ~/.bashrc"
    fi
    exec bash
    echo "Linux-Kata enabled"
}

# Function to disable Linux-Kata
disable_feature() {
    BASHRC="$HOME/.bashrc"
    LINE='PROMPT_COMMAND="/usr/local/bin/linux-kata"'
    COMMENTED_LINE='#PROMPT_COMMAND="/usr/local/bin/linux-kata"'
    if grep -Fxq "$COMMENTED_LINE" "$BASHRC"; then
        echo "Line already exists in ~/.bashrc No changes made."
    elif grep -Fxq "$LINE" "$BASHRC"; then
        sed -i "s|$LINE|$COMMENTED_LINE|" "$BASHRC"
        echo "Commented existing line in ~/.bashrc"
    elif grep -q '^PROMPT_COMMAND=' "$BASHRC"; then
        sed -i 's|^PROMPT_COMMAND=.*|#&|' "$BASHRC"
        echo "$COMMENTED_LINE" >> "$BASHRC"
        echo "Existing PROMPT_COMMAND was commented, and new line added to ~/.bashrc"
    else
        echo "$COMMENTED_LINE" >> "$BASHRC"
        echo "Added line to ~/.bashrc"
    fi
    exec bash
    echo "Linux-kata disabled"
}

list_items() {
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
}

select_kata() {
    set -e  # Exit on any error
    TARGET_FILE="/var/lib/linux-kata/kata"

    # Validate arguments
    #if [ "$#" -ne 1 ]; then
    #    echo "Usage: $0 kata <kata_name>"
    #    exit 1
    #fi

    #if [ "$1" != "kata" ]; then
    #    echo "Error: The first argument must be 'kata'"
    #    exit 1
    #fi

    KATA_NAME="$1"

    # Ensure the target directory exists
    #mkdir -p "$(dirname "$TARGET_FILE")"

    # Store the argument in the file
    echo "$KATA_NAME" > "$TARGET_FILE"
    echo "Selected kata '$KATA_NAME' stored in $TARGET_FILE"

}

reset_index() {
    # File to store the index of the last used block
    LAST_INDEX_FILE="/var/lib/linux-kata/index"

    # Reset current index for the next execution
    echo "-1" > "$LAST_INDEX_FILE"
}

case "$1" in
    -h|help)
        show_help
	exit 0
        ;;
    enable)
        enable_feature
	exit 0
        ;;
    disable)
        disable_feature
	exit 0
        ;;
    list)
        list_items
        ;;
    reset-index)
	reset_index
	;;
    select-kata)
        if [[ -z "$2" ]]; then
            echo "Error: Missing kata-name for 'kata' command."
            exit 1
        fi
        select_kata "$2"
	exit 0
        ;;
    "")
        # echo "Running script as usual..."
        # File containing the list of blocks
        # COMMANDS_FILE="commands.txt"
        COMMANDS_FILE="/var/lib/linux-kata/$(< /var/lib/linux-kata/kata).kata"

        # File to store the index of the last used block
        LAST_INDEX_FILE="/var/lib/linux-kata/index"

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

	#echo "++++++++++++++++++++++++++"
	#echo "||| Linux-Kata ||| 001 |||"
	#echo "++++++++++++++++++++++++++"

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

        # Place your usual script logic here
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo "Use '$0 -h' or '$0 help' for usage information."
        exit 1
        ;;
esac


