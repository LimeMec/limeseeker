#!/usr/bin/env bash

main_menu() {
    local choice
    local status
    local module

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
        local status="$1"
        case "$status" in
            "– not run") echo -e "${YELLOW}${status}${NC}" ;;
            "✔ done")    echo -e "${GREEN}${status}${NC}"  ;;
            "✖ failed")  echo -e "${RED}${status}${NC}"    ;;
            *)           echo "$status" ;;
        esac
    }

    # -------------------------------
    # Visa sammanfattning, UI + logg
    # -------------------------------
    show_summary_report() {
        ui_echo
        ui_echo "${CYAN}${BOLD}LimeSeeker Summary Report${NC}"
        ui_echo "${CYAN}$(date)${NC}"
        ui_echo

        for module in local_inventory local_security network_vulnerability wifi_discovery; do
            ui_echo "$(printf "%-30s : %s" "$module" "$(status_color "${MODULE_STATUS[$module]}")")"
            log_summary "$module" "${MODULE_STATUS[$module]}"
        done

        ui_echo
    }

    # -----------------
    # Kör alla moduler
    # -----------------
    run_all_scans() {
        local modules=(local_inventory local_security network_vulnerability wifi_discovery)

        for module in "${modules[@]}"; do
            ui_echo
            ui_echo "${CYAN}${BOLD}▶ Running $module...${NC}"
            log_section "Running module: $module"

            $module
            status=$?

            MODULE_STATUS["$module"]=$([[ $status -eq 0 ]] && echo "✔ done" || echo "✖ failed")

            if [[ $status -eq 0 ]]; then
                ui_echo "${GREEN}✔ $module completed successfully${NC}"
                log_event "[OK] $module completed successfully"
            else
                ui_echo "${RED}✖ $module failed or aborted${NC}"
                log_event "[FAIL] $module failed or aborted"
            fi

            sleep 1
        done

        show_summary_report
        pause
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
        local choice
        local module

        while true; do
            ui_clear
            ui_echo
            ui_echo
            ui_echo "${BOLD}${CYAN}        LimeSeeker | Module information${NC}"
            ui_echo "${BOLD}${CYAN}-----------------------------------------------${NC}"
            ui_echo
            ui_echo "1) Local inventory"
            ui_echo "2) Local security"
            ui_echo "3) Network vulnerability"
            ui_echo "4) Wireless discovery"
            ui_echo "5) Back to main menu"
            ui_echo

            ui_read -rp "Select module [1-5]: " choice
            ui_echo

            case "$choice" in
                1) module="local_inventory" ;;
                2) module="local_security" ;;
                3) module="network_vulnerability" ;;
                4) module="wifi_discovery" ;;
                5) return 0 ;;
                *) ui_echo "${RED}Invalid choice${NC}"
                   sleep 1
                   continue
                   ;;
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
        ui_echo "1) Local inventory        [$(status_color "${MODULE_STATUS[local_inventory]}")]"
        ui_echo "2) Local security         [$(status_color "${MODULE_STATUS[local_security]}")]"
        ui_echo "3) Network vulnerability  [$(status_color "${MODULE_STATUS[network_vulnerability]}")]"
        ui_echo "4) WiFi discovery         [$(status_color "${MODULE_STATUS[wifi_discovery]}")]"
        ui_echo "5) Run all modules"
        ui_echo "6) Info about modules"
        ui_echo "7) Quit"
        ui_echo

        ui_read -rp "Select option [1-7]: " choice
        ui_echo

        log_resume

        case "$choice" in
            1) module=local_inventory ;;
            2) module=local_security ;;
            3) module=network_vulnerability ;;
            4) module=wifi_discovery ;;
            5) run_all_scans ;;
            6) info_menu ;;
            7)
                ui_echo "${YELLOW}Quitting LimeSeeker...${NC}"
                log_event "User exited LimeSeeker"
                log_footer
                return 0
                ;;
            *) ui_echo "${RED}Invalid choice${NC}"
               continue
               ;;
        esac

        # ----------------
        # Kör vald modul
        # ----------------
        if [[ "$choice" =~ ^[1-4]$ ]]; then
            log_section "Running module: $module"
            $module
            status=$?

            MODULE_STATUS["$module"]=$([[ $status -eq 0 ]] && echo "✔ done" || echo "✖ failed")

            if [[ $status -eq 0 ]]; then
                log_event "[OK] $module completed"
            else
                log_event "[FAIL] $module failed"
            fi

            show_summary_report
            pause
        fi

        log_pause
        declare -F ui_clear >/dev/null && ui_clear
        show_intro
    done
}

