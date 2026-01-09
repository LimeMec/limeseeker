#!/usr/bin/env bash

# --------------------
# Metadata
# --------------------
SCRIPT_NAME="LimeSeeker"
SCRIPT_VERSION="1.3.2"
SCRIPT_AUTHOR="LimeMec / Markus Carlsson"

BOLD="\033[1m"
NC="\033[0m"  

# ------------
# CLI flaggor
#-------------
show_help() {
    clear
    echo
    echo -e "${BOLD}LimeSeeker | Linux & Network Vulnerability Scanner${NC}"
    echo "--------------------------------------------------"
    echo
    echo "An interactive system and network security scanner."
    echo
    echo
    echo -e "${BOLD}Requirements:${NC}"
    echo "  • Must be run with sudo privileges"
    echo "  • Linux system with standard utilities"
    echo
    echo
    echo -e "${BOLD}Options:${NC}"
    echo "  -h, --help       Show this help message and exit"
    echo "  -v, --version    Show script version and author"
    echo
    echo -e "${BOLD}Examples:${NC}"
    echo "  ./limeseeker.sh"
    echo "  ./limeseeker.sh -h"
    echo "  ./limeseeker.sh --version"
    echo
    echo
    echo
    echo -e "${BOLD}Available modules:${NC}"
    echo

    for module in "${MODULES[@]}"; do
        DESC="${module}_DESC"
        CATEGORY="${module}_CATEGORY"
        SAFETY="${module}_SAFETY"

        echo -e "  ${BOLD}${module}${NC}"
        echo "    Description : ${!DESC}"
        echo "    Category    : ${!CATEGORY}"

        if [[ -n "${!SAFETY}" ]]; then
            echo "    Safety      : ${!SAFETY}"
        fi
        echo
    done

    exit 0
}

show_version() {
    clear
    echo
    echo -e ${BOLD}"LimeSeeker | Linux & Network Vulnerability Scanner${NC}"
    echo "--------------------------------------------------"
    echo
    echo "An interactive system and network security scanner."
    echo
    echo
    echo -e "${BOLD}Version :${NC} $SCRIPT_VERSION"
    echo
    echo -e "${BOLD}Author  :${NC} $SCRIPT_AUTHOR"
    echo
    exit 0
}

# -----------
# Baskatalog
# -----------
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# --------------
# Ladda moduler
# --------------
shopt -s nullglob
for module in "$BASE_DIR/modules/"*.sh; do
    source "$module"
done
shopt -u nullglob

# -------------------
# Lista över moduler
# -------------------
MODULES=(
    local_inventory
    local_security
    network_vulnerability
    wifi_discovery
)

# ---------------
# Anropa flaggor
# ---------------
case "$1" in
    -h|--help)
        show_help
        ;;
    -v|--version)
        show_version
        ;;
esac

#--------------------------
# Ladda biblioteksfilerna
# -------------------------
source "$BASE_DIR/lib/privileges.sh"
source "$BASE_DIR/lib/colors.sh"
source "$BASE_DIR/lib/logging.sh"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/lib/menu.sh"

# --------------
# Logghantering
# --------------
REPORT_DIR="$BASE_DIR/reports"
mkdir -p "$REPORT_DIR"
export REPORT_FILE="$REPORT_DIR/LimeSeeker_$(date +%Y%m%d_%H%M%S).txt"

exec > >(tee -a "$REPORT_FILE") 2>&1

# -----------------
#  Rubrik för logg
#  ----------------
echo "==========================================================="
echo "      LimeSeeker Report: $(date)"
echo "==========================================================="

#-------------
# Tvinga sudo
# ------------
sudo -k
require_sudo "$@"

# ----------------
# Signalhantering
# ----------------
trap 'ui_echo "\n${YELLOW}Exiting LimeSeeker...${NC}"; sudo -k; exit 0' SIGINT SIGTERM

require_bash

# --------------
# Starta script
# --------------
show_intro
main_menu

