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
    ui_echo
    ui_echo "${CYAN}${BOLD}_    _ _  _ ____ ____ ____ ____ _  _ ____ ____ ${NC}"
    ui_echo "${CYAN}${BOLD}|    | |\/| |___ [__  |___ |___ |_/  |___ |__/ ${NC}"
    ui_echo "${CYAN}${BOLD}|___ | |  | |___ ___] |___ |___ | \_ |___ |  \ ${NC}"
    ui_echo "${CYAN}${BOLD}     Linux & Network Vulnerability Scanner${NC}"
    ui_echo "${CYAN}${BOLD}-----------------------------------------------${NC}"
    # log_to_file "_    _ _  _ ____ ____ ____ ____ _  _ ____ ____ "
    # log_to_file "|    | |\/| |___ [__  |___ |___ |_/  |___ |__/"
    # log_to_file "|___ | |  | |___ ___] |___ |___ | \_ |___ |  \ "
    # log_to_file "     Linux & Network Vulnerability Scanner"
    # log_to_file "-----------------------------------------------"
    ui_echo
    ui_echo "${YELLOW}${BOLD}[!] Elevated privileges required${NC}"
    log_to_file "[!] Elevated privileges required"
    ui_echo
    ui_echo "The user is responsible for ensuring that scans are run only on"
    ui_echo "systems and networks they own or are authorized to test."
    ui_echo
    ui_echo
    ui_echo "Requirements:"
    ui_echo
    ui_echo " • Sudo privileges on this system"
    ui_echo " • Explicit user authorization"
    ui_echo
    ui_echo
    ui_echo
    ui_echo
    ui_echo "You will now be prompted for your sudo password."
        
    #---------------------------
    # Tvinga ange sudo-lösenord
    # --------------------------
    if sudo -v; then
	exec sudo "$SCRIPT_PATH" "$@"  
        ui_echo
        ui_echo "${GREEN}${BOLD}✔ Sudo authentication successful${NC}"
	# log_to_file "✔ Sudo authentication successful"
        sleep 1
        clear
        return 0
    else
        ui_echo
        ui_echo "${RED}${BOLD}✖ Sudo authentication failed${NC}"
	# log_to_file "✖ Sudo authentication failed"
        ui_echo "${RED}Exiting LimeSeeker.${NC}"
	# log_to_file "Exiting Limeseeker."
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

