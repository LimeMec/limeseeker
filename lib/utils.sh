#!/bin/bash

require_bash() {
    [[ -n "$BASH_VERSION" ]] || {
        echo "Run with bash"
        exit 1
    }
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This tool requires root"
        exit 1
    fi
}

pause() {
    if declare -F ui_read >/dev/null; then
        ui_read -rp "Press Enter to continue..."
    else
        read -rp "Press Enter to continue..."
    fi
}


