#!/usr/bin/env bash

# ----------------
# Module metadata
# ----------------
wifi_discovery_NAME="WiFi discovery"
wifi_discovery_DESC="
The WiFi discovery module scans the local wireless environment.

This includes:
•  Nearby access points
•  Encryption types (WEP/WPA/WPA2/WPA3)
•  Signal strength
•  Channel usage

Purpose:
To map the surrounding wireless landscape and identify weak or
misconfigured access points.

Note:
This module may require monitor mode and root privileges.
"

wifi_discovery() {
    
    clear
    echo
    # ------------------
    # Rubrik för modul
    # ------------------
    sleep 0.3
    ui_echo "${CYAN}${BOLD}WiFi discovery scan...${NC}"
    log_to_file "▶ WiFi discovery scan..."
    echo
    echo
    
    sleep 0.5
    if ! command -v iw &>/dev/null; then
        ui_echo "${RED}iw not installed${NC}"
	log_to_file "iw not installed"
	return 1
    fi

    WLAN_IFACES=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}')
    
    sleep 0.5
    if [ -z "$WLAN_IFACES" ]; then
        ui_echo "${YELLOW}No wireless interface detected${NC}"
	log_to_file "No wireless interface detected"
	return 1
    fi
    
    for IFACE in $WLAN_IFACES; do
        ui_echo "${GREEN}${BOLD}▶ Interface:${NC} $IFACE"
	log_to_file "▶ Interfaces: $IFACE"
        sudo ip link set "$IFACE" up 2>/dev/null

        sudo iw dev "$IFACE" scan 2>/dev/null | \
        awk '
            /BSS/     {bssid=$2}
            /signal/  {signal=$2}
            /SSID/    {print "SSID:", $2, "| BSSID:", bssid, "| Signal:", signal}
        '
        echo
     done
    
     return 0
}
