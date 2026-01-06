#!/usr/bin/env bash

#-------------------
# Efterfråga sudo
#-------------------
require_sudo() {
    if [[ $EUID -ne 0 ]]; then
        # Gul text direkt (funkar alltid)
        echo -e "\033[33m[!] LimeSeeker requires sudo privileges\033[0m" > /dev/tty

        exec sudo -E bash "$0" "$@"
    fi
}

