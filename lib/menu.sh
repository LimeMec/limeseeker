#!/usr/bin/env bash

main_menu() {

    # ---------------
    # Hantera Ctrl+C
    # ---------------
    handle_sigint() {
        ui_echo
        ui_echo "${YELLOW}Exiting LimeSeeker...${NC}"
        log_event "User aborted LimeSeeker (Ctrl+C)"
        sudo -k
        exit 0
    }
    trap handle_sigint SIGINT

    # ---------------
    # Hantera Ctrl+Z
    # ---------------
    handle_sigtstp() {
        ui_echo
        ui_echo "${RED}Ctrl+Z is disabled for security reasons. Exiting.${NC}"
        log_event "User attempted Ctrl+Z (SIGTSTP)"
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

    # -------------------------
    # Reset modulstatus (c)
    # -------------------------
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

        if [[ "$confirm" == "YES" ]]; then
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

    # ------------------------
    # Visa modulkontrakt-info
    # ------------------------
    show_module_info() {
        local module="$1"

	local DESC="${module}_DESC"
        local CATEGORY="${module}_CATEGORY"
        local COMMANDS="${module}_COMMANDS"
        local INPUT="${module}_INPUT"
        local OUTPUT="${module}_OUTPUT"
        local SIDEFFECTS="${module}_SIDEFFECTS"
        local SAFETY="${module}_SAFETY"

        ui_clear
        ui_echo
        ui_echo "${CYAN}${BOLD}        LimeSeeker | Module ${module//_/ }${NC}"
        ui_echo "${CYAN}-----------------------------------------------${NC}"
        ui_echo
        ui_echo "${BOLD} Description :${NC} ${!DESC}"
        ui_echo "${BOLD} Category    :${NC} ${!CATEGORY}"
        ui_echo "${BOLD} Commands    :${NC} ${!COMMANDS}"
        ui_echo "${BOLD} Input       :${NC} ${!INPUT}"
        ui_echo "${BOLD} Output      :${NC} ${!OUTPUT}"
        ui_echo "${BOLD} Side effects:${NC} ${!SIDEFFECTS}"

        if [[ -n "${!SAFETY}" ]]; then
            ui_echo "${BOLD} Safety      :${NC} ${!SAFETY}"
        fi

        ui_echo
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
            ui_echo
            ui_echo "1) Local inventory"
            ui_echo "2) Local security"
            ui_echo "3) Network vulnerability"
            ui_echo "4) Wireless discovery"
            ui_echo "5) Return to main menu"
            ui_echo

            ui_read -rp "Select option: " choice

            case "$choice" in
                1) module="local_inventory" ;;
                2) module="local_security" ;;
                3) module="network_vulnerability" ;;
                4) module="wifi_discovery" ;;
                5) return ;;
                *) ui_echo "${RED}Invalid choice${NC}"; sleep 1; continue ;;
            esac

            show_module_info "$module"
        done
    }

    # ------
    # Start
    # ------
    show_intro

    while true; do
        log_pause
        ui_echo
        ui_echo "${BOLD}${CYAN}Choose module scan:${NC}"
        ui_echo "1) Local inventory         $(status_color "${MODULE_STATUS[local_inventory]}")"
        ui_echo "2) Local security          $(status_color "${MODULE_STATUS[local_security]}")"
        ui_echo "3) Network vulnerability   $(status_color "${MODULE_STATUS[network_vulnerability]}")"
        ui_echo "4) WiFi discovery          $(status_color "${MODULE_STATUS[wifi_discovery]}")"
        ui_echo "5) Run all modules"
        ui_echo
        ui_echo "i) Module information"
        ui_echo "c) Clear module status"
        ui_echo "q) Quit"
        ui_echo

        ui_read -rp "Select option: " choice || handle_sigint
        log_resume

        case "$choice" in
            1) module=local_inventory ;;
            2) module=local_security ;;
            3) module=network_vulnerability ;;
            4) module=wifi_discovery ;;
            5) run_all_scans ;;
            i|I) info_menu ;;
            c|C) reset_module_status ;;
            q|Q)
                ui_echo "${YELLOW}Quitting LimeSeeker...${NC}"
                log_event "User exited LimeSeeker"
                sudo -k
                return 0
                ;;
            *) ui_echo "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac

        if [[ "$choice" =~ ^[1-4]$ ]]; then
            log_section "Running module: $module"
            $module
            status=$?
            MODULE_STATUS["$module"]=$([[ $status -eq 0 ]] && echo "✔ done" || echo "✖ failed")
            pause
        fi

        ui_clear
        show_intro
    done
}

