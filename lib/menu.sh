main_menu() {
    while true; do
        log_pause    # Pausa loggning

        ui_echo "${BOLD}${GREEN}Choose scan:${NC}"
        ui_echo "1) Local inventory scan"
        ui_echo "2) Local security scan"
        ui_echo "3) Network vulnerability scan"
        ui_echo "4) Wireless scan"
        ui_echo "5) Quit"
        ui_echo

        ui_read -rp "Select option [1-5]: " choice
        ui_echo

        log_resume    # Återuppta loggning

        case "$choice" in
            1) local_inventory ;;
            2) local_security ;;
            3) network_vulnerability ;;
            4) wifi_discovery ;;
            5)
		ui_echo "${YELLOW}Quitting LimeSeeker...${NC}"
                log_to_file "Quitting LimeSeeker..."
                sleep 1
                exit 0
		echo
                ;;
            *) ui_echo "Invalid choice" ;;
        esac
        
	log_pause
        pause
        show_intro
	log_resume
    done
}

