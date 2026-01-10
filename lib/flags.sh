#!/usr/bin/env bash

# ------------
# Flaggstatus
# ------------
FLAG_HANDLED=false

# ---------
# Parsning
# ---------
parse_flags() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                FLAG_HANDLED=true
                exit 0
                ;;
            -v|--version)
                show_version
                FLAG_HANDLED=true
                exit 0
                ;;
            -m|--modules)
                show_modules
                FLAG_HANDLED=true
                exit 0
                ;;
	    -l|--legal)
                show_legal
		FLAG_HANDLED=true
		exit 0
		;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for available options"
                exit 1
                ;;
        esac
        shift
    done
}

# ----------------
# Help, -h/--help
# ----------------
show_help() {
    clear
    echo
    echo -e "     ${BOLD}LimeSeeker | Linux & Network Vulnerability Scanner${NC}"
    echo "-------------------------------------------------------------"
    echo
    echo "LimeSeeker is a interactive Linux and network vulnerability"
    echo "scanning tool."
    echo
    echo
    echo -e "${BOLD}Features:${NC}"
    echo
    echo "  • Modular scans"
    echo "  • Safe signal handling"
    echo "  • Detailed loggin"
    echo
    echo
    echo -e "${BOLD}Requirements:${NC}"
    echo
    echo "  • Must be run with sudo privileges"
    echo "  • Linux system with standard utilities"
    echo
    echo
    echo -e "${BOLD}Options:${NC}"
    echo
    echo "  -h, --help       show this help message and exit"
    echo "  -v, --version    show script version and author"
    echo "  -m, --modules    list available modules and descriptions"
    echo
    echo
}

# ----------------------
# Version, -v/--version
# ----------------------
show_version() {
    clear
    echo
    echo -e "     ${BOLD}LimeSeeker | Linux & Network Vulnerability Scanner${NC}"
    echo "-------------------------------------------------------------"
    echo
    echo -e "${BOLD}Version :${NC} ${LIMESEEKER_VERSION}"
    echo
    echo -e "${BOLD}Author  :${NC} ${LIMESEEKER_AUTHOR}"
    echo
    echo
}

# ----------------------
# Modules, -m/--modules
# ----------------------
show_modules() {
    clear
    echo
    echo -e "     ${BOLD}LimeSeeker | Linux & Network Vulnerability Scanner${NC}"
    echo "-------------------------------------------------------------"
    echo
    echo -e "${BOLD}Modules:${NC}"
    echo

    for module in local_inventory local_security network_vulnerability wifi_discovery; do
        DESC="${module}_DESC"
        CATEGORY="${module}_CATEGORY"
	COMMANDS="${module}_COMMANDS"
	OUTPUT="${module}_OUTPUT"

	out_name="${module//_/ }"
	out_name="${out_name^}"

        echo "  • ${out_name}"
        [[ -n "${!CATEGORY}" ]] && echo "    Category     : ${!CATEGORY}"
        [[ -n "${!DESC}" ]] && echo "    Description  : ${!DESC}"
	[[ -n "${!COMMANDS}" ]] && echo "    Commands     : ${!COMMANDS}"
	[[ -n "${!OUTPUT}" ]] && echo "    Output       : ${!OUTPUT}"
        echo
    done
}

# -----------------
# Legal, -l/--legal
# -----------------
show_legal() {
    clear
    echo
    echo -e "     ${BOLD}LimeSeeker | Linux & Network Vulnerability Scanner${NC}"
    echo "-------------------------------------------------------------"
    echo
    echo "This tool performs:"
    echo
    echo "  • Passive inspection"
    echo "  • Active scanning (nmap)"
    echo "  • No exploitation"
    echo
    echo "Use only on systems you own or have permission to test."
    echo
    echo
}

