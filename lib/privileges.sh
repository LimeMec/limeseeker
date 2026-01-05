#!/usr/bin/env bash

require_sudo() {
    if [[ $EUID -ne 0 ]]; then
        # UI-meddelande (ska INTE loggas)
        if declare -F ui_echo >/dev/null; then
            ui_echo "${YELLOW}[!] LimeSeeker requires sudo privileges${NC}"
        else
            echo "[!] LimeSeeker requires sudo privileges" > /dev/tty
        fi

        # Ersätt processen – ENDA körningen
        exec sudo -E bash "$0" "$@"
    fi
}


