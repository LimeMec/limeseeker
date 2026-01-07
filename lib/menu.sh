#!/usr/bin/env bash

main_menu() {
    local choice
    local status
    local module

    # -------------
    # Modulstatus
    # -------------
    declare -A MODULE_STATUS=(
        [local_inventory]="– not run"
        [local_security]="– not run"
        [network_vulnerability]="– not run"
        [wifi_discovery]="– not run"
    )

    # --------------------------------
    # Visa sammanfattning, UI + logg
    # --------------------------------
    show_summary_report() {
        ui_echo
        ui_echo "${CYAN}${BOLD}LimeSeeker Summary Report${NC}"
        ui_echo "${CYAN}$(date)${NC}"
        ui_echo

        for module in local_inventory local_security network_vulnerability wifi_discovery; do
            ui_echo "$(printf "%-30s : %s" "$module" "${MODULE_STATUS[$module]}")"
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

    # -------
    # Start
    # -------
    show_intro

    while true; do
        log_pause
        
	ui_echo
        ui_echo "${BOLD}${CYAN}Choose scan:${NC}"
        ui_echo "1) Local inventory scan        [${MODULE_STATUS[local_inventory]}]"
        ui_echo "2) Local security scan         [${MODULE_STATUS[local_security]}]"
        ui_echo "3) Network vulnerability scan  [${MODULE_STATUS[network_vulnerability]}]"
        ui_echo "4) Wireless scan               [${MODULE_STATUS[wifi_discovery]}]"
        ui_echo "5) Run all scans"
        ui_echo "6) Quit"
        ui_echo

        ui_read -rp "Select option [1-6]: " choice
        ui_echo

        log_resume

        case "$choice" in
            1) module=local_inventory ;;
            2) module=local_security ;;
            3) module=network_vulnerability ;;
            4) module=wifi_discovery ;;
            5) run_all_scans ;;
            6)
                ui_echo "${YELLOW}Quitting LimeSeeker...${NC}"
                log_event "User exited LimeSeeker"
                log_footer
                return 0
                ;;
            *)
                ui_echo "${RED}Invalid choice${NC}"
                continue
                ;;
        esac
	# ----------------------------------------
        # Kör vald modul, men inte run_all_scans
	# ----------------------------------------
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

