#!/usr/bin/env bash

require_sudo() {

    #-------------------------------
    # Rensa terminalen, inte logg 
    # ------------------------------
    if [[ $EUID -eq 0 ]]; then
	return 0
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
    echo "The user is responsible for ensuring that scans are run only on"
    echo "systems and networks they own or are authorized to test."
    echo
    echo
    echo "Requirements:"
    echo
    echo " • Sudo privileges on this system"
    echo " • Explicit user authorization"
    echo
    echo
    echo
    echo
    echo "You will now be prompted for your sudo password."
        
    #---------------------------
    # Tvinga ange sudo-lösenord
    # --------------------------
    if sudo -v; then
	exec sudo "$SCRIPT_PATH" "$@"  
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

