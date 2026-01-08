#!/usr/bin/env bash

#------------------------------------
# Rensa terminalen – aldrig stdout
# -----------------------------------
ui_clear() {
    clear > /dev/tty
}

#--------------------------------
# Text till terminal med färger
# -------------------------------
ui_echo() {
    printf "%b\n" "$*" > /dev/tty 2>&1
}

#-----------------------
# Input från terminal
# ----------------------
ui_read() {
    read -r "$@" < /dev/tty
}

#---------------
# Huvudrubrik
# --------------
show_intro() {
    ui_clear

    ui_echo "${CYAN}${BOLD}"
    ui_echo "=================================================================="
    ui_echo "        LimeSeeker | Linux & Network Vulnerability Scanner"
    ui_echo "=================================================================="
    ui_echo "${RED}IMPORTANT:${NC} Only scan networks you own or have permission to test!"
    ui_echo
    #ui_echo "${GREEN}${BOLD}Date:${NC} $(date)"
    ui_echo "${GREEN}${BOLD}Logged in user:${NC} ${SUDO_USER:-$USER}"

    if [ "$(id -u)" -eq 0 ]; then
        ui_echo "${GREEN}${BOLD}Root status:${NC} Running as root"
    else
        ui_echo "${GREEN}${BOLD}Root status:${NC} Not running as root"
    fi
    
    ui_echo "${GREEN}${BOLD}Date:${NC} $(date)"

    ui_echo
}

