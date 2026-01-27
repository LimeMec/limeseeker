#!/usr/bin/env bash

# ---------------------------------------
# Network scan profiles (environment)
# ---------------------------------------
: "${NETWORK_PROFILE:=home}"   # home|office|iot|lab

# These variables are derived from the profile
: "${NETWORK_TIMING:=T3}"        # T2/T3/T4
: "${NETWORK_TOP_PORTS:=1000}"   # 100/1000/-- (empty means full)
: "${NETWORK_ENABLE_UDP:=0}"     # 0/1
: "${NETWORK_VULN_SCRIPTS:=safe}" # safe|vuln|safe+vuln

network_apply_profile() {
    local p="$1"
    NETWORK_PROFILE="$p"

    case "$p" in
        home)
            NETWORK_TIMING="T3"
            NETWORK_TOP_PORTS=1000
            NETWORK_ENABLE_UDP=0
            NETWORK_VULN_SCRIPTS="safe"
            ;;
        office)
            NETWORK_TIMING="T3"
            NETWORK_TOP_PORTS=1000
            NETWORK_ENABLE_UDP=0
            NETWORK_VULN_SCRIPTS="safe"
            ;;
        iot)
            NETWORK_TIMING="T2"
            NETWORK_TOP_PORTS=1000
            NETWORK_ENABLE_UDP=1
            NETWORK_VULN_SCRIPTS="safe+vuln"
            ;;
        lab)
            NETWORK_TIMING="T4"
            NETWORK_TOP_PORTS=""
            NETWORK_ENABLE_UDP=1
            NETWORK_VULN_SCRIPTS="safe+vuln"
            ;;
        *)
            NETWORK_PROFILE="home"
            NETWORK_TIMING="T3"
            NETWORK_TOP_PORTS=1000
            NETWORK_ENABLE_UDP=0
            NETWORK_VULN_SCRIPTS="safe"
            ;;
    esac

    export NETWORK_PROFILE NETWORK_TIMING NETWORK_TOP_PORTS NETWORK_ENABLE_UDP NETWORK_VULN_SCRIPTS
}

network_profile_display() {
    echo "Profile: ${BOLD}${NETWORK_PROFILE}${NC}  •  Timing: ${NETWORK_TIMING}  •  Top ports: ${NETWORK_TOP_PORTS:-all}  •  UDP: ${NETWORK_ENABLE_UDP}  •  NSE: ${NETWORK_VULN_SCRIPTS}"
}

network_set_profile_menu() {
    local choice

    ui_clear
    ui_echo
    ui_echo "${BOLD}${CYAN}Network profile selection${NC}"
    ui_echo "------------------------------------------------------------"
    ui_status_block
    ui_echo
    ui_echo "${DIM}$(network_profile_display)${NC}"
    ui_echo
    ui_echo "1) home    (balanced, safe scripts)"
    ui_echo "2) office  (balanced, safe scripts)"
    ui_echo "3) iot     (slower, includes UDP + more scripts)"
    ui_echo "4) lab     (fast/aggressive, full ports, UDP, more scripts)"
    ui_echo
    ui_echo "q) Back"
    ui_echo
    ui_echo

    if ! ui_read -rp "Select option: " choice; then
        return 1
    fi

    case "$choice" in
        1) network_apply_profile "home" ;;
        2) network_apply_profile "office" ;;
        3) network_apply_profile "iot" ;;
        4) network_apply_profile "lab" ;;
        q|Q) return 0 ;;
        *) ui_echo "${RED}Invalid choice${NC}"; sleep 1; return 1 ;;
    esac

    ui_echo "${GREEN}[OK]${NC} Profile applied: $NETWORK_PROFILE"
    log_event "Network profile set: $NETWORK_PROFILE"
    sleep 1
    return 0
}

# Apply default profile on load
network_apply_profile "${NETWORK_PROFILE}"
