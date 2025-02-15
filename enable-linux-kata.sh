#!/bin/bash

BASHRC="$HOME/.bashrc"
LINE='PROMPT_COMMAND="/usr/local/bin/linux-kata"'
COMMENTED_LINE='#PROMPT_COMMAND="/usr/local/bin/linux-kata"'

if grep -Fxq "$LINE" "$BASHRC"; then
    echo "Line already exists in ~/.bashrc. No changes made."
elif grep -Fxq "$COMMENTED_LINE" "$BASHRC"; then
    sed -i "s|$COMMENTED_LINE|$LINE|" "$BASHRC"
    echo "Uncommented existing line in ~/.bashrc."
elif grep -q '^PROMPT_COMMAND=' "$BASHRC"; then
    sed -i 's|^PROMPT_COMMAND=.*|#&|' "$BASHRC"
    echo "$LINE" >> "$BASHRC"
    echo "Existing PROMPT_COMMAND was commented, and new line added to ~/.bashrc."
else
    echo "$LINE" >> "$BASHRC"
    echo "Added line to ~/.bashrc."
fi

exec bash
