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
    ui_echo
    ui_echo "${YELLOW}${BOLD}[!] Elevated privileges required${NC}"
    ui_echo
    ui_echo "LimeSeeker requires elevated privileges to perform local security
inspection and analysis.

By continuing, you confirm that:
• You are authorized to assess this system and its environment
• You understand that some modules perform network and wireless scanning
• You accept responsibility for how this tool is used
• You understand that scan results may be logged locally

Unauthorized use against systems or networks you do not own or
explicitly have permission to assess may be illegal.

If you do NOT agree, terminate the script now.

Proceeding indicates acceptance of these terms."
    ui_echo
    ui_echo
    ui_echo "Continue by enter your sudo password:"
        
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

