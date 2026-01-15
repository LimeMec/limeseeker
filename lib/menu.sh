#!/usr/bin/env bash

main_menu() {
        
    local modules_to_run=()
	
    # ---------------
    # Hantera Ctrl+C
    # ---------------
    handle_sigint() {
    echo -e "\n${YELLOW}Ctrl+C detected. Exiting LimeSeeker...${NC}" > /dev/tty
    echo -e "${YELLOW}Cleraring sudo privileges...${NC}" > /dev/tty
    log_event "User aborted LimeSeeker (Ctrl+C)"
    sudo -k
    exit 0
}
    trap handle_sigint SIGINT
    
    # ----------------
    # Hanterar Ctrl+D
    # ----------------
    handle_eof() {
    echo -e "\n${YELLOW}Ctrl+D detected. Exiting LimeSeeker...${NC}" > /dev/tty
    echo -e "${YELLOW}Clearing sudo privileges...${NC}"
    log_event "User exited LimeSeeker via Ctrl+D (EOF)"
    sudo -k
    exit 0
}
    
    # ----------------
    # Hanterar ctrl+Z
    # ----------------
    handle_sigtstp() {
    echo -e "\n${YELLOW}Ctrl+Z detected. Exiting for security...${NC}" > /dev/tty
    echo -e "${YELLOW}Clearing sudo privileges${NC}" > /dev/tty
    log_event "User attempted to suspend script"
    sudo -k
    exit 1
}

    trap handle_sigtstp SIGTSTP

    local choice status module

    # ------------
    # Modulstatus
    # ------------
    declare -A MODULE_STATUS=(
        [local_inventory]="– not run"
        [local_security]="– not run"
        [network_vulnerability]="– not run"
        [wifi_discovery]="– not run"
    )

    # ----------------
    # Status med färg
    # ----------------
    status_color() {
        case "$1" in
            "– not run")
                echo -e "${DIM}[ ] not run${NC}"
                ;;
            "✔ done")
                echo -e "[${GREEN}✔${NC}] ${GREEN}done${NC}"
                ;;
            "✖ failed")
                echo -e "[${RED}✖${NC}] ${RED}failed${NC}"
                ;;
            *)
                echo "$1"
                ;;
        esac
    }

    # ----------------------
    # Nollställ modulstatus
    # ----------------------
    reset_module_status() {
        ui_clear
        ui_echo
        ui_echo "${BOLD}${YELLOW}Reset module status${NC}"
        ui_echo
        ui_echo "This will mark all modules as '${DIM}not run${NC}'."
        ui_echo "No scans will be executed."
        ui_echo "Log files will NOT be deleted."
        ui_echo
        ui_read -rp "Type YES to confirm: " confirm

        if [[ "${confirm,,}" == "yes" ]]; then
            for module in "${!MODULE_STATUS[@]}"; do
                MODULE_STATUS["$module"]="– not run"
            done
            ui_echo
            ui_echo "${GREEN}Module status reset successfully.${NC}"
            log_event "Module status reset by user"
            sleep 1
        else
            ui_echo
            ui_echo "${YELLOW}Reset cancelled.${NC}"
            sleep 1
        fi
    }

    # ---------------
    # Visa modulinfo
    # --------------
    show_module_info() {
    local module="$1"

    local NAME_VAR="${module}_NAME"
    local DESC_VAR="${module}_DESC"
    local SAFETY_VAR="${module}_SAFETY"

    ui_clear
    ui_echo
    ui_echo "${CYAN}${BOLD}        LimeSeeker | ${!NAME_VAR}${NC}"
    ui_echo "${CYAN}-----------------------------------------------------------${NC}"
    ui_status_block
    ui_echo "${!DESC_VAR}"
    ui_echo

    if [[ -n "${!SAFETY_VAR}" ]]; then
        ui_echo "${YELLOW}${BOLD}Safety notice:${NC}"
        ui_echo "${!SAFETY_VAR}"
        ui_echo
    fi

    ui_read -rp "Press ENTER to return"
}

    # ----------
    # Info-meny
    # ----------
    info_menu() {
        local choice module

        while true; do
            ui_clear
            ui_echo
            ui_echo "${BOLD}${CYAN}        LimeSeeker | Module information${NC}"
            ui_echo "${CYAN}-----------------------------------------------${NC}"
	    ui_status_block
            ui_echo
            ui_echo "1) Local inventory"
            ui_echo "2) Local security"
            ui_echo "3) Network vulnerability"
            ui_echo "4) WiFi discovery"
	    ui_echo
            ui_echo "q) Back to main menu"
            ui_echo
	    ui_echo

            ui_read -rp "Select option: " choice

            case "$choice" in
                1) module="local_inventory" ;;
                2) module="local_security" ;;
                3) module="network_vulnerability" ;;
                4) module="wifi_discovery" ;;
		q|Q) return ;;
                *) ui_echo "${RED}Invalid choice${NC}"; sleep 1; continue ;;
            esac

            show_module_info "$module"
        done
    }

    # ---------
    # Modulval
    # ---------
    show_intro

    while true; do
        modules_to_run=()
	ui_clear
	show_intro
	log_pause
        ui_echo
        ui_echo "${BOLD}${CYAN}Choose module scan:${NC}"
        ui_echo "1) Local inventory         $(status_color "${MODULE_STATUS[local_inventory]}")"
        ui_echo "2) Local security          $(status_color "${MODULE_STATUS[local_security]}")"
        ui_echo "3) Network vulnerability   $(status_color "${MODULE_STATUS[network_vulnerability]}")"
        ui_echo "4) WiFi discovery          $(status_color "${MODULE_STATUS[wifi_discovery]}")"
        ui_echo "5) Scanning all modules"
        ui_echo
	ui_echo
        ui_echo "i) Module information"
        ui_echo "c) Clear module status"
	ui_echo
        ui_echo "q) Quit"
        ui_echo
	ui_echo
        
	if ! ui_read -rp "Select option [1-5]: " choice; then 
		handle_eof
        fi 

        case "$choice" in
		1) modules_to_run=(local_inventory) ;;
                2) modules_to_run=(local_security) ;;
                3) modules_to_run=(network_vulnerability) ;;
                4) modules_to_run=(wifi_discovery) ;;
                5) modules_to_run=(local_inventory local_security network_vulnerability wifi_discovery) ;;
     
   	        i|I) 
			 info_menu 
			 continue
			 ;;
                c|C) 
			 reset_module_status 
			 continue
			 ;;
                q|Q)
			 ui_echo "${YELLOW}Exiting LimeSeeker...${NC}"
		         ui_echo "${YELLOW}Clearing sudo privileges...${NC}"
                         log_event "User exited LimeSeeker"
                         sudo -k
                         return 0
                         ;;
                *) ui_echo "${RED}Invalid choice${NC}"; sleep 1; continue ;;
        esac

         for module in "${modules_to_run[@]}"; do
		 log_section "Running module: $module"
		 $module
                 status=$?

         if [[ $status -eq 0 ]]; then
                 MODULE_STATUS["$module"]="✔ done"
                 ui_echo
                 ui_echo "[${GREEN}✔${NC}] ${GREEN}${module//_/ } completed successfully${NC}"
                 log_event "[OK] $module completed successfully"
         else
                  MODULE_STATUS["$module"]="✖ failed"
                  ui_echo
                  ui_echo "[${RED}✖${NC}] ${RED}${module//_/ } failed or was aborted${NC}"
                  log_event "[FAIL] $module failed or aborted"
         fi
        done

        ui_echo
        pause
done
}      
