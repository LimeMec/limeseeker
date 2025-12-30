wifi_discovery() {
    clear
    echo -e "${CYAN}${BOLD}======================================================================="
    echo -e "                 SCANNING: WIRELESS NETWORKS"
    echo -e "=======================================================================${NC}"
    echo

    if ! command -v iw &>/dev/null; then
        echo -e "${RED}iw not installed${NC}"
	return
    fi

    WLAN_IFACES=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}')

    if [ -z "$WLAN_IFACES" ]; then
        echo -e "${YELLOW}No wireless interface detected${NC}"
	return
    fi

    for IFACE in $WLAN_IFACES; do
        echo -e "${GREEN}${BOLD}▶ Interface:${NC} $IFACE"
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
     log "Wifi discovery scan completed"
}
