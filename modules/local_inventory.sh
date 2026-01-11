#!/usr/bin/env bash

# ------------------------
# Module metadata
# ------------------------
local_inventory_NAME="Local inventory"
local_inventory_DESC="
The Local inventory collects detailed information about the local system.

This includes:
  • Operating system and kernel version
  • Hardware information (CPU, memory, storage)
  • Installed packages
  • Running services
  • Active users and sessions

Purpose:
To provide a baseline overview of the system and identify unexpected
or outdated components.
"

local_inventory() {

    #-------------------------------
    # Rensa terminalen, inte logg 
    # ------------------------------
    if declare -F ui_clear >/dev/null; then
        ui_clear
    fi

    #--------------------
    # Rubrik för modul
    # -------------------
    sleep 0.3
    echo
    ui_echo "${CYAN}${BOLD}Scanning local inventory...${NC}"
    log_to_file "▶ Scanning local inventory..."
    echo
    echo
    
    #---------------------
    # Systemets upptid
    # --------------------
    sleep 1
    ui_echo "${GREEN}${BOLD}▶ SYSTEM UPTIME:${NC}"
    log_to_file "▶ SYSTEM UPTIME:"
    uptime -p
    echo
    
    #-------------------
    # BIOS / Firmware
    # ------------------
    sleep 0.5
    ui_echo "${GREEN}${BOLD}▶ BIOS / FIRMWARE:${NC}"
    log_to_file "▶ BIOS / FIRMWARE:"
    if command -v dmidecode &>/dev/null; then
        dmidecode -t bios 2>/dev/null | grep -E "Vendor|Version|Release Date"
    else
        echo "dmidecode not installed"
    fi
    echo
    
    #-----------------
    # Operativsystem
    # ----------------
    sleep 0.5
    ui_echo "${GREEN}${BOLD}▶ OPERATING SYSTEM:${NC}"
    log_to_file "▶ OPERATING SYSTEM:"
    echo "OS:               $(uname -o)"
    echo "Nodename:         $(uname -n)"
    echo "Kernel release:   $(uname -r)"
    echo "Kernel version:   $(uname -v)"
    echo "Architecture:     $(uname -m)"
    echo
    
    #--------------
    # Grafikkort
    # -------------
    sleep 0.5
    ui_echo "${GREEN}${BOLD}▶ GPU:${NC}"
    log_to_file "▶ GPU:"
    if command -v lspci &>/dev/null; then
        lspci | grep -i vga
    else
        echo "lspci not installed"
    fi
    echo

    #-------------
    # Processor
    # ------------
    sleep 0.5
    ui_echo "${GREEN}${BOLD}▶ CPU:${NC}"
    log_to_file "▶ CPU:"
    lscpu | grep -E "Model name|Vendor ID|Architecture|CPU\(s\)|Core\(s\) per socket|Thread\(s\) per core|Socket\(s\)"
    echo

    awk -F: '/cpu MHz/ {print $2}' /proc/cpuinfo | sort -n | \
        awk 'NR==1{min=$1} END{print "Min MHz:", min "\nMax MHz:", $1}'
    echo

    #-------------
    # RAM-minne
    # ------------
    sleep 0.5
    ui_echo "${GREEN}${BOLD}▶ MEMORY:${NC}"
    log_to_file "▶ MEMORY:"
    free -h
    echo

    #-------------
    # Hårddisk
    # ------------
    sleep 0.5
    ui_echo "${GREEN}${BOLD}▶ DISK SPACE:${NC}"
    log_to_file "▶ DISK SPACE:"
    df -h --exclude-type=tmpfs --exclude-type=devtmpfs
    echo

    #-----------
    # Nätverk
    # ----------
    sleep 0.5
    ui_echo "${GREEN}${BOLD}▶ NETWORK:${NC}"
    log_to_file "▶ NETWORK:"

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
    
    return 0
}

