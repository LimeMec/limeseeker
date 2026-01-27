#!/usr/bin/env bash

# ----------------
# Module metadata
# ----------------
wifi_history_NAME="WiFi history"
wifi_history_DESC="
Compares the latest WiFi scan against previous scans.

Highlights:
• Detects new/missing APs and notable changes over time
• Helps spot roaming, spoofing, or environment drift

Requires prior scans to exist. No active attacks.
"
wifi_history() {

    ui_clear
    ui_echo "${CYAN}${BOLD}Comparing WiFi scan history...${NC}"
    log_to_file "▶ WiFi history comparison started"
    echo

    WIFI_RAW_DIR="$BASE_DIR/reports/limeseeker_wifi"
    FILES=($(ls "$WIFI_RAW_DIR"/*.raw 2>/dev/null | sort))

    if [[ ${#FILES[@]} -lt 2 ]]; then
        ui_echo "${YELLOW}[INFO]${NC} Not enough scan data for comparison"
        log_to_file "[INFO] Not enough scan data for comparison"
        return 0
    fi

    PREV="${FILES[-2]}"
    CURR="${FILES[-1]}"

    ui_echo "${GREEN}Comparing:${NC}"
    ui_echo "  Previous: $(basename "$PREV")"
    ui_echo "  Current:  $(basename "$CURR")"
    log_to_file "Comparing $PREV -> $CURR"
    echo

    # -------------
    # SSID changes
    # -------------
    ui_echo "${GREEN}${BOLD}▶ SSID CHANGES:${NC}"

    prev_ssid=$(awk '/SSID:/ {print $2}' "$PREV" | sort -u)
    curr_ssid=$(awk '/SSID:/ {print $2}' "$CURR" | sort -u)

    comm -13 <(echo "$prev_ssid") <(echo "$curr_ssid") | while read -r ssid; do
        ui_echo "${YELLOW}[NEW]${NC} SSID detected: $ssid"
        log_to_file "[NEW] SSID detected: $ssid"
    done

    comm -23 <(echo "$prev_ssid") <(echo "$curr_ssid") | while read -r ssid; do
        ui_echo "${BLUE}[GONE]${NC} SSID disappeared: $ssid"
        log_to_file "[GONE] SSID disappeared: $ssid"
    done

    echo

    # -------------------
    # Encryption changes
    # -------------------
    ui_echo "${GREEN}${BOLD}▶ ENCRYPTION CHANGES:${NC}"

    awk '
    /BSS/ {bssid=$2}
    /SSID:/ {ssid=$2}
    /RSN:/ {enc="WPA2/WPA3"}
    /WPA:/ {enc="WPA"}
    /WEP/ {enc="WEP"}
    END {print ssid,bssid,enc}
    ' "$PREV" "$CURR" | sort | uniq -c | awk '$1==1' | while read -r line; do
        ui_echo "${YELLOW}[CHANGE]${NC} $line"
        log_to_file "[CHANGE] $line"
    done

    echo
    ui_echo "${CYAN}${BOLD}WiFi history comparison completed.${NC}"
    log_to_file "✔ WiFi history comparison completed"

    return 0
}

