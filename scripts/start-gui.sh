#!/bin/bash

# Quick start script for Kubuntu Setup GUI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUI_SETUP_SCRIPT="$SCRIPT_DIR/../gui/scripts/setup-gui.sh"

# Check if GUI setup script exists
if [[ ! -f "$GUI_SETUP_SCRIPT" ]]; then
    echo "Error: GUI setup script not found!"
    echo "Expected location: $GUI_SETUP_SCRIPT"
    exit 1
fi

# Run the GUI setup script
exec "$GUI_SETUP_SCRIPT" "$@"