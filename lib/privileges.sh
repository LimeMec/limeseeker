#!/usr/bin/env bash

# -------------------------------------------
# Information och krav för att starta script
# -------------------------------------------

require_sudo() {

    clear
    echo
    echo -e "${CYAN}${BOLD}===========================================================${NC}"
    echo -e "${CYAN}${BOLD}      LimeSeeker | Linux & Network Vulnerability Scanner   ${NC}"
    echo -e "${CYAN}${BOLD}===========================================================${NC}"
    echo
    echo -e "${YELLOW}${BOLD}[!] Elevated privileges required${NC}"
    echo
    echo "LimeSeeker performs local system inspection and"
    echo "network-related security scans that require sudo access."
    echo
    echo "Requirements:"
    echo " • Sudo privileges on this system"
    echo " • Explicit user authorization"
    echo " • Use only on systems and networks you own or manage"
    echo
    echo "You will now be prompted for your sudo password."
    echo
    
    #---------------------------
    # Tvinga ange sudo-lösenord
    # --------------------------
    if sudo -v; then
        echo
        echo -e "${GREEN}${BOLD}✔ Sudo authentication successful${NC}"
        sleep 1
        clear
        return 0
    else
        echo
        echo -e "${RED}${BOLD}✖ Sudo authentication failed${NC}"
        echo -e "${RED}Exiting LimeSeeker.${NC}"
        exit 1
    fi
}

# -----------------------
# Rensar sudo-behörighet
# -----------------------
cleanup() {
    sudo -k >/dev/null 2>&1

    ui_echo "${YELLOW}Clearing privileges...${NC}"
}

