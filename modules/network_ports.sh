#!/usr/bin/env bash

# ----------------
# Module metadata
# ----------------
network_ports_NAME="Network port scan"
network_ports_DESC="
Enumerates open ports and basic services on discovered hosts.

Highlights:
• TCP port scanning and service detection (where supported)
• Builds a service inventory per host

Use this to understand exposure and what services are reachable.
"
network_ports_SAFETY="Explicit authorization required. Scans only private IP ranges unless manually configured."

network_ports() {

    ui_clear
    ui_echo "${CYAN}${BOLD}Scanning ports & services...${NC}"
    log_to_file "▶ Network port scan started"
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
    ui_echo "${DIM}$(network_profile_display)${NC}"
    log_to_file "▶ Target: $target"
    log_to_file "Profile: $NETWORK_PROFILE"

    local out_dir ts out_base
    out_dir="$BASE_DIR/reports/network"
    mkdir -p "$out_dir"
    ts="$(date +%Y%m%d_%H%M%S)"
    out_base="$out_dir/ports_${ts}"

    # Build targets: prefer latest discovered hosts file if set and exists
    local scan_targets=()
    if [[ -n "$NETWORK_LAST_HOSTS_FILE" && -f "$NETWORK_LAST_HOSTS_FILE" && -s "$NETWORK_LAST_HOSTS_FILE" ]]; then
        mapfile -t scan_targets < "$NETWORK_LAST_HOSTS_FILE"
        ui_echo "${GREEN}[OK]${NC} Using discovered hosts list (${#scan_targets[@]} hosts)"
        log_to_file "[OK] Using discovered hosts list: $NETWORK_LAST_HOSTS_FILE"
    else
        scan_targets=("$target")
        ui_echo "${YELLOW}[INFO]${NC} No host list found; scanning target directly"
        log_to_file "[INFO] No host list found; scanning target directly"
    fi

    # Port scope
    local port_arg=""
    if [[ -n "$NETWORK_TOP_PORTS" ]]; then
        port_arg="--top-ports $NETWORK_TOP_PORTS"
    else
        port_arg="-p-"
    fi

    ui_echo
    ui_echo "${GREEN}${BOLD}▶ TCP scan:${NC} $port_arg"
    log_to_file "▶ TCP scan: $port_arg"

    nmap -sS -sV --open -"${NETWORK_TIMING}" $port_arg \
        -oN "${out_base}_tcp.txt" \
        "${scan_targets[@]}"

    log_to_file "Saved TCP results: ${out_base}_tcp.txt"

    if [[ "$NETWORK_ENABLE_UDP" -eq 1 ]]; then
        ui_echo
        ui_echo "${GREEN}${BOLD}▶ UDP scan:${NC} (top ports 100)"
        log_to_file "▶ UDP scan"

        nmap -sU --open -"${NETWORK_TIMING}" --top-ports 100 \
            -oN "${out_base}_udp.txt" \
            "${scan_targets[@]}"

        log_to_file "Saved UDP results: ${out_base}_udp.txt"
    fi

    ui_echo
    ui_echo "${CYAN}${BOLD}Port scan completed.${NC}"
    log_to_file "✔ Network port scan completed"

    export NETWORK_LAST_PORTS_BASE="$out_base"
    log_to_file "NETWORK_LAST_PORTS_BASE=$NETWORK_LAST_PORTS_BASE"

    return 0
}
