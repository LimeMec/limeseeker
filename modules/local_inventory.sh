#!/usr/bin/env bash

# ------------------------
# Module metadata
# ------------------------
local_inventory_NAME="Local inventory"
local_inventory_DESC="
Collects baseline information about the local system (read-only).


Highlights:
• OS/kernel, hardware, storage, memory
• Installed packages and running services
• Active users and sessions


Use this to quickly understand what a machine is and what is running on it.
"

local_inventory() {

    #---------------
    # Clear terminal 
    # --------------
    if declare -F ui_clear >/dev/null; then
        ui_clear
    fi

    #----------------------
    # Header running module
    # ---------------------
    echo
    ui_echo "${CYAN}${BOLD}Scanning local inventory...${NC}"
    log_to_file "▶ Scanning local inventory..."
    echo
    echo
    
    #--------------
    # System uptime
    # -------------
    ui_echo "${GREEN}${BOLD}▶ SYSTEM UPTIME:${NC}"
    log_to_file "▶ SYSTEM UPTIME:"
    uptime -p
    echo
    
    #----------------
    # BIOS / Firmware
    # ---------------
    ui_echo "${GREEN}${BOLD}▶ BIOS / FIRMWARE:${NC}"
    log_to_file "▶ BIOS / FIRMWARE:"
    if command -v dmidecode &>/dev/null; then
        dmidecode -t bios 2>/dev/null | grep -E "Vendor|Version|Release Date"
    else
        echo "dmidecode not installed"
    fi
    echo
    
    #----
    # OS
    # ---
    ui_echo "${GREEN}${BOLD}▶ OPERATING SYSTEM:${NC}"
    log_to_file "▶ OPERATING SYSTEM:"
    echo "OS:               $(uname -o)"
    echo "Nodename:         $(uname -n)"
    echo "Kernel release:   $(uname -r)"
    echo "Kernel version:   $(uname -v)"
    echo "Architecture:     $(uname -m)"
    echo
    
    #----
    # GPU
    # ---
    ui_echo "${GREEN}${BOLD}▶ GPU:${NC}"
    log_to_file "▶ GPU:"
    if command -v lspci &>/dev/null; then
        lspci | grep -i vga
    else
        echo "lspci not installed"
    fi
    echo

    #-----
    # CPU
    # ----
    ui_echo "${GREEN}${BOLD}▶ CPU:${NC}"
    log_to_file "▶ CPU:"
    lscpu | grep -E "Model name|Vendor ID|Architecture|CPU\(s\)|Core\(s\) per socket|Thread\(s\) per core|Socket\(s\)"
    echo

    awk -F: '/cpu MHz/ {print $2}' /proc/cpuinfo | sort -n | \
        awk 'NR==1{min=$1} END{print "Min MHz:", min "\nMax MHz:", $1}'
    echo

    #--------
    # Memory
    # -------
    ui_echo "${GREEN}${BOLD}▶ MEMORY:${NC}"
    log_to_file "▶ MEMORY:"
    free -h
    echo

    #------------
    # Hard drive
    # -----------
    ui_echo "${GREEN}${BOLD}▶ DISK SPACE:${NC}"
    log_to_file "▶ DISK SPACE:"
    df -h --exclude-type=tmpfs --exclude-type=devtmpfs
    echo

    #---------
    # Network
    # --------
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

