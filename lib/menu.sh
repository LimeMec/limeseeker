main_menu() {
    local choice
    local status

    # ------------------------------
    # Initiera modulstatus
    # ------------------------------
    declare -A MODULE_STATUS
    MODULE_STATUS["local_inventory"]="– not run"
    MODULE_STATUS["local_security"]="– not run"
    MODULE_STATUS["network_vulnerability"]="– not run"
    MODULE_STATUS["wifi_discovery"]="– not run"
    
    #--------------
    # Visa intro
    # -------------
    show_intro

    while true; do
        log_pause

        # ----------------------------
        # Visa modulstatus i menyn
        # ----------------------------
        ui_echo "${BOLD}${GREEN}Choose scan:${NC}"
        ui_echo "1) Local inventory scan        [${MODULE_STATUS["local_inventory"]}]"
        ui_echo "2) Local security scan         [${MODULE_STATUS["local_security"]}]"
        ui_echo "3) Network vulnerability scan  [${MODULE_STATUS["network_vulnerability"]}]"
        ui_echo "4) Wireless scan               [${MODULE_STATUS["wifi_discovery"]}]"
        ui_echo "5) Quit"
        ui_echo

        ui_read -rp "Select option [1-5]: " choice
        ui_echo

        log_resume

        # ---------------------------------
        # Kör vald modul och spara status
        # ---------------------------------
        case "$choice" in
            1)
                local_inventory
                status=$?
                MODULE_STATUS["local_inventory"]=$([[ $status -eq 0 ]] && echo "✔ done" || echo "✖ failed")
                ;;
            2)
                local_security
                status=$?
                MODULE_STATUS["local_security"]=$([[ $status -eq 0 ]] && echo "✔ done" || echo "✖ failed")
                ;;
            3)
                network_vulnerability
                status=$?
                MODULE_STATUS["network_vulnerability"]=$([[ $status -eq 0 ]] && echo "✔ done" || echo "✖ failed")
                ;;
            4)
                wifi_discovery
                status=$?
                MODULE_STATUS["wifi_discovery"]=$([[ $status -eq 0 ]] && echo "✔ done" || echo "✖ failed")
                ;;
            5)
                ui_echo "${YELLOW}Quitting LimeSeeker...${NC}"
                log_to_file "Quitting LimeSeeker..."
                sleep 1
                return 0
                ;;
            *)
                ui_echo "${RED}Invalid choice${NC}"
                continue
                ;;
        esac

        # ------------------------------
        # Visa resultat i loggen
        # ------------------------------
        if [[ $status -eq 0 ]]; then
            ui_echo "${GREEN}✔ Module completed successfully${NC}"
            log_to_file "[OK] Module completed successfully"
        else
            ui_echo "${YELLOW}✖ Module aborted or failed${NC}"
            log_to_file "[FAIL] Module aborted or failed"
        fi

        # ------------------------------
        # Pausa mellan valen
        # ------------------------------
        log_pause
        pause
        log_resume

        # -------------------------------
        # Rensa och visa intro + meny
        # -------------------------------
        if declare -F ui_clear >/dev/null; then
            ui_clear
        fi
        show_intro
    done
}

