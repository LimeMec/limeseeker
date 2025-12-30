#!/usr/bin/env bash

show_intro() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "======================================================================="
    echo "                LimeSeeker - Modular Security Scanner"
    echo "======================================================================="
    echo -e "${RED}   IMPORTANT:${NC}${CYAN} Only scan networks you own or have permission to test.${NC}"
    echo
    echo -e "${GREEN}${BOLD}Date:${NC} $(date)"
    echo -e "${GREEN}${BOLD}Logged in user:${NC} ${SUDO_USER:-$USER}"
    echo -ne "${GREEN}${BOLD}Root status: ${NC}"; if [ $(id -u) -eq 0 ]; then echo -e "${YELLOW}Running as root${NC}"; else echo -e "${GREEN}Not running as root${NC}"; fi
    echo
}

