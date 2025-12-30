#!/bin/bash

require_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}[!] LimeSeeker requires sudo privileges${NC}"
        sudo -v || exit 1
        exec sudo bash "$0" "$@"
    fi
}

