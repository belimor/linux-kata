#!/bin/bash

BASHRC="$HOME/.bashrc"
LINE='PROMPT_COMMAND="/usr/local/bin/linux-kata"'
COMMENTED_LINE='#PROMPT_COMMAND="/usr/local/bin/linux-kata"'

if grep -Fxq "$COMMENTED_LINE" "$BASHRC"; then
    echo "Line already exists in ~/.bashrc. No changes made."
elif grep -Fxq "$LINE" "$BASHRC"; then
    sed -i "s|$LINE|$COMMENTED_LINE|" "$BASHRC"
    echo "Commented existing line in ~/.bashrc."
elif grep -q '^PROMPT_COMMAND=' "$BASHRC"; then
    sed -i 's|^PROMPT_COMMAND=.*|#&|' "$BASHRC"
    echo "$COMMENTED_LINE" >> "$BASHRC"
    echo "Existing PROMPT_COMMAND was commented, and new line added to ~/.bashrc."
else
    echo "$COMMENTED_LINE" >> "$BASHRC"
    echo "Added line to ~/.bashrc."
fi

exec bash
