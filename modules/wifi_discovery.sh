#!/usr/bin/env bash

# ----------------
# Module metadata
# ----------------
wifi_discovery_NAME="WiFi discovery"
wifi_discovery_DESC="
Performs an extensive passive wireless scan and stores raw data.

Highlights:
• SSID/BSSID, signal, channel/band
• Security capabilities, ciphers, WPS, PMF, PHY hints
• Saves raw+metadata for analysis and historical comparison

This module performs NO analysis and NO active attacks.
"

wifi_discovery() {

    ui_clear
    ui_echo "${CYAN}${BOLD}Collecting wireless scan data...${NC}"
    log_to_file "▶ WiFi discovery started"
    echo

    if ! command -v iw &>/dev/null; then
        ui_echo "${YELLOW}[INFO]${NC} iw not installed – skipping WiFi discovery"
        log_to_file "[INFO] iw not installed – skipping WiFi discovery"
        return 0
    fi

    WLAN_IFACES=$(iw dev | awk '$1=="Interface"{print $2}')
    [[ -z "$WLAN_IFACES" ]] && {
        ui_echo "${YELLOW}[INFO]${NC} No wireless interfaces detected"
        log_to_file "[INFO] No wireless interfaces detected"
        return 0
    }

    WIFI_RAW_DIR="$BASE_DIR/reports/limeseeker_wifi"
    mkdir -p "$WIFI_RAW_DIR"

    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    for IFACE in $WLAN_IFACES; do
        ui_echo "${GREEN}${BOLD}▶ Interface:${NC} $IFACE"
        log_to_file "▶ WiFi interface: $IFACE"

        ip link set "$IFACE" up 2>/dev/null

        RAW_FILE="$WIFI_RAW_DIR/${IFACE}_${TIMESTAMP}.raw"
        META_FILE="$WIFI_RAW_DIR/${IFACE}_${TIMESTAMP}.meta"

        iw dev "$IFACE" scan 2>/dev/null > "$RAW_FILE"

        {
            echo "timestamp=$TIMESTAMP"
            echo "interface=$IFACE"
            echo "hostname=$(hostname)"
            echo "kernel=$(uname -r)"
        } > "$META_FILE"

        ui_echo "  → Raw scan saved: $RAW_FILE"
        ui_echo "  → Metadata saved: $META_FILE"
        log_to_file "Raw scan saved: $RAW_FILE"
    done

    echo
    ui_echo "${CYAN}${BOLD}WiFi discovery completed.${NC}"
    log_to_file "✔ WiFi discovery completed"

    return 0
}

