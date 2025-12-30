#!/usr/bin/env bash

local_inventory() {

    clear
    echo -e "${CYAN}${BOLD}======================================================================="
    echo -e "                  SCANNING: OS & HARDWARE"
    echo -e "=======================================================================${NC}"
    echo

    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ SYSTEM UPTIME:${NC}"
    uptime -p
    echo

    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ BIOS / FIRMWARE:${NC}"
    if command -v dmidecode &>/dev/null; then
        dmidecode -t bios 2>/dev/null | grep -E "Vendor|Version|Release Date"
    else
        echo "dmidecode not installed"
    fi
    echo

    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ OPERATING SYSTEM:${NC}"
    echo "OS:               $(uname -o)"
    echo "Nodename:         $(uname -n)"
    echo "Kernel release:   $(uname -r)"
    echo "Kernel version:   $(uname -v)"
    echo "Architecture:     $(uname -m)"
    echo

    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ GPU:${NC}"
    if command -v lspci &>/dev/null; then
        lspci | grep -i vga
    else
        echo "lspci not installed"
    fi
    echo

    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ CPU:${NC}"
    lscpu | grep -E "Model name|Vendor ID|Architecture|CPU\(s\)|Core\(s\) per socket|Thread\(s\) per core|Socket\(s\)"
    echo

    awk -F: '/cpu MHz/ {print $2}' /proc/cpuinfo | sort -n | \
        awk 'NR==1{min=$1} END{print "Min MHz:", min "\nMax MHz:", $1}'
    echo

    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ MEMORY:${NC}"
    free -h
    echo

    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ DISK SPACE:${NC}"
    df -h --exclude-type=tmpfs --exclude-type=devtmpfs
    echo

    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ NETWORK:${NC}"

    IFACE=$(ip route | awk '/default/ {print $5}' | head -n 1)

    if [[ -n "$IFACE" ]]; then
        echo "Interface:   $IFACE"
        echo "MAC address: $(ip link show "$IFACE" | awk '/ether/ {print $2}')"
        echo "IP address:  $(ip -o -f inet addr show "$IFACE" | awk '{print $4}' | cut -d/ -f1)"
        echo "Gateway:     $(ip route | awk '/default/ {print $3}')"
        echo "Netmask:     /$(ip -o -f inet addr show "$IFACE" | awk '{print $4}' | cut -d/ -f2)"
    else
        echo "No active network interface found"
    fi
    
    echo
    echo
    log "Local inventory scan completed"
}

