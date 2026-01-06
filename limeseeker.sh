#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

#------------------
# Säkerställ sudo
# -----------------
source "$BASE_DIR/lib/privileges.sh"
require_sudo "$@"

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

