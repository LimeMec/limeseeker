#!/usr/bin/env bash

main_menu() {
    while true; do
        echo -e "${BOLD}Choose scan:${NC}"
	echo "1) Local inventory scan"
        echo "2) Local security scan"
        echo "3) Network vulnerability scan"
        echo "4) Wireless scan"
        echo "5) Quit"

	echo
        read -rp "Select option [1-5]:  " choice
        echo

        case "$choice" in
	    1) local_inventory ;;
            2) local_security ;;
            3) network_vulnerability ;;
            4) wifi_discovery ;;
            5) exit 0 ;;
            *) echo "Invalid choice" ;;
        esac

        pause
        show_intro
    done
}

