#!/usr/bin/env bash

# ---------------------------------------
# Network target state (auto or manual)
# ---------------------------------------
: "${NETWORK_TARGET_MODE:=auto}"     # auto | manual
: "${NETWORK_TARGET_VALUE:=}"        # manual target e.g. 192.168.1.0/24

# Return current default interface
network_default_iface() {
    ip route 2>/dev/null | awk '/default/ {print $5; exit}'
}

# Return auto-detected CIDR for the default interface (e.g. 192.168.1.0/24)
network_auto_cidr() {
    local iface ipcidr
    iface="$(network_default_iface)"
    [[ -z "$iface" ]] && return 1

    ipcidr="$(ip -o -f inet addr show "$iface" 2>/dev/null | awk '{print $4; exit}')"
    [[ -z "$ipcidr" ]] && return 1

    echo "$ipcidr"
}

# Safety: allow only private IP ranges for ranges/cidrs/hosts (basic check)
network_is_private_target() {
    local t="$1"

    # allow single IP or CIDR in private ranges
    [[ "$t" =~ ^10\. ]] && return 0
    [[ "$t" =~ ^192\.168\. ]] && return 0
    [[ "$t" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]] && return 0

    return 1
}

# Get active target depending on mode
network_get_target() {
    local t
    if [[ "$NETWORK_TARGET_MODE" == "manual" && -n "$NETWORK_TARGET_VALUE" ]]; then
        echo "$NETWORK_TARGET_VALUE"
        return 0
    fi
    t="$(network_auto_cidr)" || return 1
    echo "$t"
}

# Pretty line for menus
network_target_display() {
    local iface t
    iface="$(network_default_iface)"
    t="$(network_get_target 2>/dev/null)"
    [[ -z "$iface" ]] && iface="unknown"
    [[ -z "$t" ]] && t="(no target)"

    if [[ "$NETWORK_TARGET_MODE" == "manual" ]]; then
        echo "Target: ${BOLD}${t}${NC}  ${DIM}(manual)${NC}  •  Interface: ${iface}"
    else
        echo "Target: ${BOLD}${t}${NC}  ${DIM}(auto)${NC}    •  Interface: ${iface}"
    fi
}

# Menu to set target
network_set_target_menu() {
    local choice manual

    ui_clear
    ui_echo
    ui_echo "${BOLD}${CYAN}Network target settings${NC}"
    ui_echo "------------------------------------------------------------"
    ui_status_block
    ui_echo
    ui_echo "${DIM}$(network_target_display)${NC}"
    ui_echo
    ui_echo "1) Auto target (detect from default interface)"
    ui_echo "2) Manual target (IP / CIDR / range)"
    ui_echo
    ui_echo "q) Back"
    ui_echo

    if ! ui_read -rp "Select option [1-2]: " choice; then
        return 1
    fi

    case "$choice" in
        1)
            NETWORK_TARGET_MODE="auto"
            NETWORK_TARGET_VALUE=""
            export NETWORK_TARGET_MODE NETWORK_TARGET_VALUE
            ui_echo "${GREEN}[OK]${NC} Target set to auto"
            log_event "Network target set to auto"
            sleep 1
            ;;
        2)
            ui_echo
            if ! ui_read -rp "Enter manual target (example 192.168.1.0/24): " manual; then
                return 1
            fi
            manual="${manual//[[:space:]]/}"
            [[ -z "$manual" ]] && { ui_echo "${RED}Invalid target${NC}"; sleep 1; return 1; }

            if ! network_is_private_target "$manual"; then
                ui_echo "${RED}[ERROR]${NC} Only private IP ranges are allowed (RFC1918)"
                log_event "Blocked manual network target (non-private): $manual"
                sleep 2
                return 1
            fi

            NETWORK_TARGET_MODE="manual"
            NETWORK_TARGET_VALUE="$manual"
            export NETWORK_TARGET_MODE NETWORK_TARGET_VALUE
            ui_echo "${GREEN}[OK]${NC} Manual target set: $manual"
            log_event "Network target set to manual: $manual"
            sleep 1
            ;;
        q|Q) return 0 ;;
        *) ui_echo "${RED}Invalid choice${NC}"; sleep 1 ;;
    esac
}
