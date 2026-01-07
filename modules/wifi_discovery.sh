#!/usr/bin/env bash

# -------------------------------------------------------------------------
# Modulkontrakt:
#
# Module: wifi_discovery
# Description:
#   Discovers nearby wireless networks and signal strength information.
#
# Category:
#   Wireless / Discovery
#
# Requires (commands):
#   iw, ip
#
# Requires (privileges):
#   root (wireless scanning and interface control)
#
# Input:
#   none
#
# Output:
#   Wireless network discovery results to stdout
#   Logged output via log_to_file
#
# Return codes:
#   0 = scan completed successfully
#   1 = no wireless interfaces or scan aborted
#
# Side effects:
#   Temporarily brings wireless interfaces up
#   Generates passive wireless scan traffic
# ------------------------------------------------------------------------



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
