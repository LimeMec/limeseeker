#!/usr/bin/env bash

# ----------------
# Module metadata
# ----------------
wifi_analysis_NAME="WiFi analysis"
wifi_analysis_DESC="
Analyzes collected WiFi scan data and highlights risks and policy issues.

Highlights:
• Weak security (OPEN/WEP/TKIP), WPS detection
• Channel congestion overview
• Duplicate SSIDs and suspicious changes
• Recommendations for hardening

Requires WiFi discovery data. No active attacks.
"
# --------------
# wifi_analysis
# --------------
wifi_analysis() {

    ui_clear
    ui_echo "${CYAN}${BOLD}Analyzing wireless environment...${NC}"
    log_to_file "▶ WiFi analysis started"
    echo

    WIFI_RAW_DIR="$BASE_DIR/reports/limeseeker_wifi"
    [[ ! -d "$WIFI_RAW_DIR" ]] && {
        ui_echo "${YELLOW}[INFO]${NC} No WiFi scan data found"
        log_to_file "[INFO] No WiFi scan data found"
        return 0
    }

    TMP_ALL="/tmp/limeseeker_wifi_all.txt"
    cat "$WIFI_RAW_DIR"/* > "$TMP_ALL"

    # -----------------
    # Network overview
    # -----------------
    ui_echo "${GREEN}${BOLD}▶ DISCOVERED NETWORKS:${NC}"
    log_to_file "▶ DISCOVERED NETWORKS"

    awk '
    /BSS/ {bssid=$2}
    /signal/ {signal=$2}
    /DS Parameter set/ {chan=$5}
    /SSID:/ {
        ssid=$0
        sub(/^SSID: /,"",ssid)
        enc="OPEN"
    }
    /RSN:/ {enc="WPA2/WPA3"}
    /WPA:/ {enc="WPA"}
    /WEP/ {enc="WEP"}
    /SSID:/ {
        printf "SSID: %-25s | Signal: %-6s dBm | Channel: %-3s | Encryption: %s\n",
        ssid,signal,chan,enc
    }' "$TMP_ALL"

    echo

    # ------------------
    # Security findings
    # ------------------
    ui_echo "${GREEN}${BOLD}▶ SECURITY FINDINGS:${NC}"
    log_to_file "▶ SECURITY FINDINGS"

    grep -q "WEP" "$TMP_ALL" && {
        ui_echo "${RED}[CRITICAL]${NC} WEP networks detected"
        log_to_file "[CRITICAL] WEP networks detected"
    }

    grep -q "TKIP" "$TMP_ALL" && {
        ui_echo "${YELLOW}[WARN]${NC} Legacy TKIP encryption detected"
        log_to_file "[WARN] Legacy TKIP encryption detected"
    }

    awk '
    /SSID:/ {ssid=1}
    /RSN:|WPA:/ {ssid=0}
    ssid==1 {open++}
    END {
        if (open>0)
            print "[WARN] Open (unencrypted) networks detected"
    }' "$TMP_ALL" | while read -r l; do
        ui_echo "${YELLOW}$l${NC}"
        log_to_file "$l"
    done

    grep -q "SSID: $" "$TMP_ALL" && {
        ui_echo "${YELLOW}[INFO]${NC} Hidden SSIDs detected"
        log_to_file "[INFO] Hidden SSIDs detected"
    }

    echo

    # --------------
    # WPS detection
    # --------------
    ui_echo "${GREEN}${BOLD}▶ WPS DETECTION:${NC}"
    log_to_file "▶ WPS DETECTION"

    grep -q "WPS:" "$TMP_ALL" && {
        ui_echo "${YELLOW}[WARN]${NC} WPS enabled on one or more networks"
        log_to_file "[WARN] WPS enabled on one or more networks"
    } || {
        ui_echo "${GREEN}[OK]${NC} No WPS detected"
        log_to_file "[OK] No WPS detected"
    }

    echo

    # ---------------------
    # WiFi standards / PHY
    # ---------------------
    ui_echo "${GREEN}${BOLD}▶ WIFI STANDARDS:${NC}"
    log_to_file "▶ WIFI STANDARDS"

    grep -E "HT capabilities|VHT capabilities|HE capabilities" "$TMP_ALL" | \
    sort -u | while read -r cap; do
        ui_echo "• $cap"
        log_to_file "$cap"
    done

    echo

    # ---------------------
    # Channel congestion
    # ---------------------
    ui_echo "${GREEN}${BOLD}▶ CHANNEL CONGESTION:${NC}"
    log_to_file "▶ CHANNEL CONGESTION"

    awk '
    /DS Parameter set/ {
        ch=$5
        count[ch]++
    }
    END {
        for (c in count)
            printf "Channel %-3s : %d networks\n", c, count[c]
    }' "$TMP_ALL" | while read -r l; do
        ui_echo "$l"
        log_to_file "$l"
    done

    echo

    # ----------------
    # Duplicate SSIDs 
    # ----------------
    ui_echo "${GREEN}${BOLD}▶ DUPLICATE SSIDS:${NC}"
    log_to_file "▶ DUPLICATE SSIDS"

    awk '/SSID:/ {print $2}' "$TMP_ALL" | sort | uniq -d | while read -r ssid; do
        ui_echo "${YELLOW}[INFO]${NC} Duplicate SSID detected: $ssid"
        log_to_file "[INFO] Duplicate SSID detected: $ssid"
    done

    echo

    # --------------
    # Strongest APs
    # --------------
    ui_echo "${GREEN}${BOLD}▶ STRONGEST ACCESS POINTS:${NC}"
    log_to_file "▶ STRONGEST ACCESS POINTS"

    awk '
    /signal/ {signal=$2}
    /SSID:/ {
        ssid=$0
        sub(/^SSID: /,"",ssid)
        print signal, ssid
    }' "$TMP_ALL" | sort -nr | head -n 5 | \
    awk '{printf "Signal: %-6s dBm | SSID: %s\n",$1,$2}' | \
    while read -r l; do
        ui_echo "$l"
        log_to_file "$l"
    done

    echo

    # ----------------
    # Recommendations
    # ----------------
    ui_echo "${GREEN}${BOLD}▶ RECOMMENDATIONS:${NC}"
    ui_echo "• Use WPA2/WPA3 with CCMP/AES"
    ui_echo "• Disable WEP and open networks"
    ui_echo "• Disable WPS where possible"
    ui_echo "• Prefer 5GHz bands"
    ui_echo "• Avoid crowded channels"
    ui_echo "• Regularly audit wireless infrastructure"

    log_to_file "Recommendations displayed"

    echo
    ui_echo "${CYAN}${BOLD}WiFi analysis completed.${NC}"
    log_to_file "✔ WiFi analysis completed"

    rm -f "$TMP_ALL"
    return 0
}



