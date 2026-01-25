#!/usr/bin/env bash

# -----------------------
# Disable ESC key output
# -----------------------
disable_esc() {
    stty -echoctl 2>/dev/null
}

#----------------------------
# Clear terminal, not stdout
# ---------------------------
ui_clear() {
    clear > /dev/tty
}

#----------------------
# Terminal text colour
# ---------------------
ui_echo() {
    printf "%b\n" "$*" > /dev/tty 2>&1
}

#----------------
# Input terminal
# ---------------
ui_read() {
    read -r "$@" < /dev/tty
}

# ---------------------------
# Sudo-/loggning status menu
# ---------------------------
ui_sudo_status() {
    if [[ $EUID -eq 0 ]]; then
        ui_echo "[${GREEN}✔${NC}] Sudo: Active"
    else
        ui_echo "[${RED}✖i${NC}] Sudo: Not active"
    fi
}
ui_logging_status() {
    if [[ "$LOGGING_ENABLED" == "false" ]]; then
        ui_echo "[${RED}✖${NC}] Logging: Disabled"
    else
        ui_echo "[${GREEN}✔${NC}] Logging: Enabled"
    fi
}
ui_status_block() {
    ui_sudo_status
    ui_logging_status
}

#-------------
# Main header
# ------------
show_intro() {
    ui_clear

    ui_echo "${CYAN}${BOLD}"
    ui_echo "        _____ _______ _______ _______ _______ _______ _     _ _______  ______"
    ui_echo " |        |   |  |  | |______ |______ |______ |______ |____/  |______ |_____/"
    ui_echo " |_____ __|__ |  |  | |______ ______| |______ |______ |    \_ |______ |    \_"
    ui_echo "        Linux & Network Vulnerability Scanner                  version ${LIMESEEKER_VERSION}" 
    ui_echo "-----------------------------------------------------------------------------${NC}"
    ui_status_block
    ui_echo
    ui_echo "${GREEN}${BOLD}Hostname:${NC} $(hostname)"
    ui_echo "${GREEN}${BOLD}User:${NC} ${SUDO_USER:-$USER}"
    ui_echo "${GREEN}${BOLD}Date:${NC} $(date)"
    ui_echo
    ui_echo

}

