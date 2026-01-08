#!/usr/bin/env bash

# ----------------------------
# Modulkontrakt för info-meny
# ----------------------------
wifi_discovery_DESC="Discovers nearby wireless networks and signal strength information"
wifi_discovery_CATEGORY="Network / Discovery"
wifi_discovery_COMMANDS="iw, ip"
wifi_discovery_PRIVILEGES="root (wireless scanning and interface control)"
wifi_discovery_INPUT="none"
wifi_discovery_OUTPUT="Wireless results to stdout, logged output via log_to_file"
wifi_discovery_RETURNCODES="0 = success, 1 = failure"
wifi_discovery_SIDEFFECTS="Temporarily brings wireless interface up, generates passive wireless scan traffic"


wifi_discovery() {
    
    clear
    echo
    # ------------------
    # Rubrik för modul
    # ------------------
    sleep 0.3
    ui_echo "${CYAN}${BOLD}WIFI discovery scan...${NC}"
    log_to_file "▶ WIFI discovery scan..."
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

     echo
     echo
     return 0
}
