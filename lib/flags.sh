#!/usr/bin/env bash

# ------------
# Flaggstatus
# ------------
FLAG_HANDLED=false

# ---------------
# Loggning av/på
# ---------------
LIME_NO_LOG=0

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
	    -a|--about)
		show_about    
	        FLAG_HANDLED=true
                exit 0
                ;;		
	    -n|--no-log)
                LIME_NO_LOG=1
		shift
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
    echo "Use only on systems you own or have permission to test."
    echo
    echo
    echo -e "${BOLD}Features:${NC}"
    echo
    echo "  • Modular scans"
    echo "  • Safe signal handling"
    echo "  • Detailed logging"
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
    echo "  -h, --help       Show this help message and exit"
    echo "  -a, --about      Show the purpose and philosophy behind LimeSeeker"
    echo "  -v, --version    Show script version and author"
    echo "  -l, --leagl      Show legal notive and usage authorization"
    echo "  -m, --modules    List available modules and their descriptions"
    echo "  -n, --no-log     Run the script without creating a log file"
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
    echo -e "${BOLD}Disclaimer${NC}"
    echo
    echo "LimeSeeker is not an exploitation framework."
    echo "It does not perform active attacks or privilege escalation."
    echo "The user is solely responsible for ensuring that scans are"
    echo "conducted only on systems and networks they own or have" 
    echo "explicit authorization to test."
    echo
    echo
}
# ------------------
# About, a-/--about
# ------------------
show_about() {
    clear
    echo -e "     ${BOLD}LimeSeeker | Linux & Network Vulnerability Scanner${NC}"
    echo "-------------------------------------------------------------"
    echo
    echo "LimeSeeker is a modular Linux and network security scanning tool"
    echo "designed for reconnaissance, auditing, and situational awareness."
    echo
    echo "The tool provides a structured overview of a system’s configuration,"
    echo "security posture, network exposure, and wireless environment through"
    echo "a clean, menu-driven interface."
    echo
    echo
    echo -e "${BOLD}Purpose:${NC}"
    echo
    echo "LimeSeeker is intended to assist with:"
    echo
    echo "  • Local system reconnaissance"
    echo "  • Security posture assessment"
    echo "  • Network and service discovery"
    echo "  • Wireless environment mapping"
    echo "  • Pre-audit and post-installation checks"
    echo
    echo "It is suitable for:"
    echo "  • Security testing labs"
    echo "  • System hardening verification"
    echo "  • Educational use"
    echo "  • Controlled penetration testing environments"
    echo
    echo
    echo -e "${BOLD}Design Philosophy:${NC}"
    echo
    echo "LimeSeeker is designed to answer one fundamental question:"
    echo "What does this system and its environment look like from a security" 
    echo "perspective?"
    echo
    echo "It provides clarity, not exploitation, and serves as a foundation"
    echo "for informed security decisions."
    echo
    echo "LimeSeeker follows a few core principles:"
    echo
    echo "  • Modular: Each scan is self-contained and can be extended or replaced."
    echo "  • Transparent: Output is readable and logged without obfuscation."
    echo "  • Minimal assumptions: The tool does not exploit vulnerabilities,"
    echo "    but identifies conditions that may require attention."
    echo "  • Privilege-aware: Root access is only required where technically"
    echo "    necessary."
    echo
    echo
    echo -e "${BOLD}Disclaimer:${NC}"
    echo
    echo "LimeSeeker is not an exploitation framework."
    echo "It does not perform active attacks or privilege escalation."
    echo "The user is solely responsible for ensuring that scans are conducted only" 
    echo "on systems and networks they own or have explicit authorization to test" 
    echo 
    echo
}
