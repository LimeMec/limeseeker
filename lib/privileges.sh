#!/usr/bin/env bash

require_sudo() {

    #-------------------------------
    # Rensa terminalen, inte logg 
    # ------------------------------
    if declare -F ui_clear >/dev/null; then
        ui_clear
    fi

    # ------------------------------------------
    # Information och krav för att starta scipt
    # ------------------------------------------
    clear
    echo
    ui_echo "${CYAN}${BOLD}===========================================================${NC}"
    ui_echo "${CYAN}${BOLD}      LimeSeeker | Linux & Network Vulnerability Scanner   ${NC}"
    ui_echo "${CYAN}${BOLD}===========================================================${NC}"
    log_to_file "==========================================================="
    log_to_file "      LimeSeeker | Linux & Network Vulnerability Scanner"
    log_to_file "==========================================================="
    echo
    ui_echo "${YELLOW}${BOLD}[!] Elevated privileges required${NC}"
    log_to_file "[!] Elevated privileges required"
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
        ui_echo "${GREEN}${BOLD}✔ Sudo authentication successful${NC}"
	log_to_file "✔ Sudo authentication successful"
        sleep 1
        clear
        return 0
    else
        echo
        ui_echo "${RED}${BOLD}✖ Sudo authentication failed${NC}"
	log_to_file "✖ Sudo authentication failed"
        ui_echo "${RED}Exiting LimeSeeker.${NC}"
	log_to_file "Exiting Limeseeker."
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

