#!/usr/bin/env bash

# --------------------
# Script metadata
# --------------------
SCRIPT_NAME="LimeSeeker"
SCRIPT_VERSION="1.3.2"
SCRIPT_AUTHOR="LimeMec / Markus Carlsson"

show_help() {
    clear
    echo
    echo "  LimeSeeker | Linux & Network Vulnerability Scanner"
    echo "  --------------------------------------------------"
    echo
    echo "  LimeSeeker is an interactive system and network"
    echo "  scanning tool designed for local security auditing."
    echo
    echo "  Requirements:"
    echo "    • Must be run with sudo privileges"
    echo "    • Linux system with standard utilities installed"
    echo
    echo
    echo "  Options:"
    echo "    -h, --help       Show this help message and exit"
    echo "    -v, --version    Show script version and author"
    echo
    echo "  Examples:"
    echo "    ./limeseeker.sh"
    echo "    ./limeseeker.sh -h"
    echo "    ./limeseeker.sh --version"
    echo
    exit 0
}

show_version() {
    clear
    echo
    echo "  LimeSeeker | Linux & Network Vulnerability Scanner"
    echo "  --------------------------------------------------"
    echo
    echo "  Version : $SCRIPT_VERSION"
    echo "  Author  : $SCRIPT_AUTHOR"
    echo
    exit 0
}

case "$1" in
    -h|--help)
        show_help
        ;;
    -v|--version)
        show_version
        ;;
esac

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

#------------------
# Säkerställ sudo
# -----------------
source lib/colors.sh
source lib/privileges.sh
source "$BASE_DIR/lib/privileges.sh"
require_sudo "$@"
trap cleanup EXIT
show_intro
main_menu

#------------------------------------------
# Skapa katalog och fil för loggrapporten
# -----------------------------------------
REPORT_DIR="$BASE_DIR/reports"
mkdir -p "$REPORT_DIR"
export REPORT_FILE="$REPORT_DIR/LimeSeeker_$(date +%Y%m%d_%H%M%S).txt"

#--------------------
# Starta loggning
#--------------------
exec > >(tee -a "$REPORT_FILE") 2>&1

#-------------------
# Rubrik för logg
# ------------------
echo "==========================================================="
echo "      LimeSeeker Report: $(date)"
echo "==========================================================="

#--------------------------
# Ladda biblioteksfilerna
# -------------------------
source "$BASE_DIR/lib/colors.sh"
source "$BASE_DIR/lib/logging.sh"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/lib/menu.sh"

#----------------
# Ladda moduler
#----------------
shopt -s nullglob
for module in "$BASE_DIR"/modules/*.sh; do
    source "$module"
done
shopt -u nullglob

trap 'ui_echo "\n${YELLOW}Exiting LimeSeeker...${NC}"' SIGINT

require_bash

show_intro
main_menu

