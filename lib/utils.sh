#!/bin/bash


# -------------
# Krav på bash
# -------------
require_bash() {
    [[ -n "$BASH_VERSION" ]] || {
        echo "Run with bash"
        exit 1
    }
}

# ------
# Pause
# ------
pause() {
    if declare -F ui_read >/dev/null; then
        ui_read -rp "Press Enter to continue..."
    else
        read -rp "Press Enter to continue..."
    fi
}

