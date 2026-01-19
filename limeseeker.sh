#!/usr/bin/env bash

SCRIPT_PATH="$(readlink -f "$0")"
export SCRIPT_PATH

# ---------
# Metadata
# ---------
LIMESEEKER_NAME="LimeSeeker"
LIMESEEKER_VERSION="1.4.2"
LIMESEEKER_AUTHOR="//LimeMec, Markus Carlsson"

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
    system_hardening
    network_vulnerability
    wifi_discovery
)

# ------------------------
# Ladda biblioteksfilerna
# ------------------------
source "$BASE_DIR/lib/privileges.sh"
source "$BASE_DIR/lib/colors.sh"
source "$BASE_DIR/lib/logging.sh"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/lib/menu.sh"
source "$BASE_DIR/lib/flags.sh"

# --------------
# Loggning av/på
# --------------
LOGGING_ENABLED=true

# ----------------
# Läsa in flaggor
# ----------------
parse_flags "$@"

# -------------
# Krav på sudo
# -------------
sudo -k
require_sudo "$@"

# --------------
# Loggning på/av
# ------------- 
case "$1" in
    -n|--no-log)
        LOGGING_ENABLED=false
        ;;
esac

# --------------
# Logghantering
# --------------
REPORT_DIR="$BASE_DIR/reports"

if [[ "$LOGGING_ENABLED" == true ]]; then
    mkdir -p "$REPORT_DIR"
    export REPORT_FILE="$REPORT_DIR/LimeSeeker_$(date +%Y%m%d_%H%M%S).txt"

    exec > >(tee -a "$REPORT_FILE") 2>&1

    echo "        _____ _______ _______ _______ _______ _______ _     _ _______  ______"
    echo " |        |   |  |  | |______ |______ |______ |______ |____/  |______ |_____/ "
    echo " |_____ __|__ |  |  | |______ ______| |______ |______ |    \_ |______ |    \_ "
    echo " Report: $(date)"
    echo " ----------------------------------------------------------------------------"
else
    export REPORT_FILE=""
fi

# ----------------
# Signalhantering
# ----------------
trap 'ui_echo "\n${YELLOW}Exiting LimeSeeker...${NC}"; sudo -k; exit 0' SIGINT SIGTERM

# -------------
# Krav på bash
#--------------
require_bash

# --------------
# Starta script
# --------------
show_intro
main_menu
