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
    read -rp "Press Enter to continue..."
}


