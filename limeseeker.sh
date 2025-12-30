#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$BASE_DIR/lib/colors.sh"
source "$BASE_DIR/lib/logging.sh"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/lib/menu.sh"
source "$BASE_DIR/lib/privileges.sh"

# Load modules
for module in "$BASE_DIR"/modules/*.sh; do
    source "$module"
done

trap 'echo -e "\n${YELLOW}Exiting LimeSeeker...${NC}"; exit 0' SIGINT

require_bash
require_sudo "$@"

show_intro
main_menu

