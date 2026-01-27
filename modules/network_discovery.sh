#!/usr/bin/env bash

# ----------------
# Module metadata
# ----------------
network_discovery_NAME="Network discovery"
network_discovery_DESC="
Finds reachable hosts on the selected target network (read-only discovery).


Highlights:
• Identifies live hosts before deeper scanning
• Produces a host list used by port/vulnerability steps


Use this as the first step in a network assessment workflow.
"
network_discovery_SAFETY="Explicit authorization required. Scans only private IP ranges unless manually configured."


network_discovery() {

    ui_clear
    ui_echo "${CYAN}${BOLD}Discovering active hosts...${NC}"
    log_to_file "▶ Network discovery started"
    echo

    if ! command -v nmap &>/dev/null; then
        ui_echo "${RED}[ERROR]${NC} nmap is not installed"
        log_to_file "[ERROR] nmap is not installed"
        return 1
    fi

    local target
    target="$(network_get_target)" || {
        ui_echo "${RED}[ERROR]${NC} Could not determine network target"
        log_to_file "[ERROR] Could not determine network target"
        return 1
    }

    if ! network_is_private_target "$target"; then
        ui_echo "${RED}[ERROR]${NC} Non-private target blocked: $target"
        log_to_file "[ERROR] Non-private target blocked: $target"
        return 1
    fi

    ui_echo "${GREEN}${BOLD}▶ Target:${NC} $target"
    log_to_file "▶ Target: $target"
    ui_echo "${DIM}$(network_profile_display)${NC}"
    log_to_file "Profile: $NETWORK_PROFILE (timing $NETWORK_TIMING)"

    local out_dir ts hosts_file
    out_dir="$BASE_DIR/reports/network"
    mkdir -p "$out_dir"
    ts="$(date +%Y%m%d_%H%M%S)"
    hosts_file="$out_dir/hosts_${ts}.txt"

    ui_echo
    ui_echo "${GREEN}${BOLD}▶ Running discovery (nmap -sn)...${NC}"
    log_to_file "▶ Running discovery (nmap -sn)"

    # Robust parse: grepable output, only Up hosts
    nmap -sn -"${NETWORK_TIMING}" -oG - "$target" 2>/dev/null \
        | awk '/Up$/{print $2}' \
        | sort -u \
        | tee "$hosts_file"

    if [[ ! -s "$hosts_file" ]]; then
        ui_echo
        ui_echo "${YELLOW}[INFO]${NC} No active hosts found"
        log_to_file "[INFO] No active hosts found"
        return 0
    fi

    ui_echo
    ui_echo "${GREEN}[OK]${NC} Host list saved: $hosts_file"
    log_to_file "[OK] Host list saved: $hosts_file"

    export NETWORK_LAST_HOSTS_FILE="$hosts_file"
    log_to_file "NETWORK_LAST_HOSTS_FILE=$NETWORK_LAST_HOSTS_FILE"

    return 0
}
