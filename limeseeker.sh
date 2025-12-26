#!/usr/bin/env bash
# LimeSeeker - Hardware, OS & Network Scanner
# Linux + Vim + Bash

# =========================
# Bash-kontroll
# =========================
if [ -z "$BASH_VERSION" ]; then
    echo "ERROR: This script has to run in bash"
    exit 1
fi

# =========================
# Färger
# =========================
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# =========================
# CTRL+C
# =========================
trap 'echo -e "\n${YELLOW}Quitting LimeSeeker...${NC}"; exit 0' SIGINT

# =========================
# Intro
# =========================
show_intro() {
    clear
    echo
    echo -e "${CYAN}${BOLD}======================================================================="
    echo -e "              LimeSeeker - Hardware, OS & Network Scanner"
    echo -e "=======================================================================${NC}"
    echo -e "${RED}${BOLD}   IMPORTANT:${NC}${RED} Only scan networks you own or have permission to test.${NC}"
    echo
    echo -e "${GREEN}${BOLD}▶ Date:${NC} $(date "+%Y-%m-%d   %H:%M:%S")"
    echo -e "${GREEN}${BOLD}▶ Logged in user:${NC} $(whoami)"
    echo -ne "${GREEN}${BOLD}▶ ROOT Access status: ${NC}"; if [ $(id -u) -eq 0 ]; then echo -e "${RED}Running as ROOT${NC}"; else echo -e "${GREEN}Not running as root${NC}"; fi
    echo
    echo
}

# =========================
# Paus + återgång
# =========================
pause_and_return() {
    echo
    echo -ne $"\033[1mPress Enter to return to menu...\033[0m"
    read -rs
    show_intro
}

# =========================
# Bekräftelse network scan
# =========================
confirm_network_scan() {
    echo
    echo -e "${RED}${BOLD}WARNING!${NC}"
    echo "You are about to scan a network."
    echo "This action requires authorization."
    echo
    read -rp "Type YES to continue (10s timeout): " -t 10 ANSWER

    [[ "$ANSWER" == "YES" ]]
}

# =========================
# Sudo-kontroll
# =========================
if ! sudo -n true 2>/dev/null; then
    echo -e "${YELLOW}LimeSeeker requiers sudo privileges to run.${NC}"
    sudo true || exit 1
fi

# =========================
# Start
# =========================
show_intro

while true; do
    echo -e "${BOLD}Choose your scan:${NC}"
    echo "  1) Local inventory scan"
    echo "  2) Local security scan"
    echo "  3) Network scan"
    echo "  4) Quit"
    echo

    read -rp "Select option [1-4]: " choice
    echo

    case "$choice" in

# =========================
# LOCAL INVENTORY SCAN
# =========================
1)
    clear
    echo -e "${CYAN}${BOLD}======================================================================="
    echo -e "                  SCANNING: OS & HARDWARE"
    echo -e "=======================================================================${NC}"
    echo

   echo
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ SYSYEM UPTIME:${NC} $(uptime -p)"

    echo
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ BIOS / FIRMWARE: ${NC}"
    sudo dmidecode -t bios 2>/dev/null | grep "Vendor"
    sudo dmidecode -t bios 2>/dev/null | grep "Version"
    sudo dmidecode -t bios 2>/dev/null | grep "Release Date"

    echo
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ OPERATING SYSTEM: ${NC}"
    echo "OS: $(uname -o)"
    echo "Nodename: $(uname -n)"
    echo "Kernel release: $(uname -r)"
    echo "Kernel version: $(uname -v)"
    echo "HW Architecture: $(uname -m)"

    echo
    echo -e "${GREEN}${BOLD}▶ GPU: ${NC}"
    command -v lspci &>/dev/null && lspci | grep -i vga || echo "lspci not installed"

    echo
    echo -e "${GREEN}${BOLD}▶ CPU: ${NC}"
    lscpu | grep -E "Model name|Vendor ID|Architecture|CPU\(s\)|Core\(s\) per socket|Thread\(s\) per core|Socket\(s\)"

    echo
    awk -F: '/cpu MHz/ {print $2}' /proc/cpuinfo | sort -n | \
    awk 'NR==1{min=$1} END{print "Min MHz:", min "\nMax MHz:", $1}'

    echo
    echo -e "${GREEN}${BOLD}▶ MEMORY: ${NC}"
    free -h

    echo
    echo -e "${GREEN}${BOLD}▶ DISK SPACE: ${NC}"
    df -h --exclude-type=tmpfs --exclude-type=devtmpfs

    echo
    echo -e "${GREEN}${BOLD}▶ NETWORK: ${NC}"
    IFACE=$(ip route | awk '/default/ {print $5}' | head -n 1)

    if [ -n "$IFACE" ]; then
        echo "Interface:   $IFACE"
        echo "MAC-adress:  $(ip link show "$IFACE" | awk '/ether/ {print $2}')"
        echo "IP-adress:   $(ip -o -f inet addr show "$IFACE" | awk '{print $4}' | cut -d/ -f1)"
        echo "Gateway:     $(ip route | awk '/default/ {print $3}')"
        echo "Netmask:     /$(ip -o -f inet addr show "$IFACE" | awk '{print $4}' | cut -d/ -f2)"
    fi
    echo
    pause_and_return

    ;;
# =========================
# LOCAL SECURITY SCAN
# =========================
2)
    clear
    echo -e "${CYAN}${BOLD}======================================================================="
    echo -e "                    SCANNING: LOCAL SECURITY"
    echo -e "=======================================================================${NC}"
    echo
    echo
    sleep 0.5

    # =========================
    # Kernel & OS
    # =========================
    echo -e "${GREEN}${BOLD}▶ KERNEL & OS:${NC}"
    echo "Kernel: $(uname -r)"
    echo "OS:     $(uname -o)"
    echo

    # =========================
    # Sudo users
    # =========================
    echo -e "${GREEN}${BOLD}▶ USERS WITH SUDO ACCESS:${NC}"

    SUDO_USERS=$(getent group sudo 2>/dev/null | cut -d: -f4)

    if [ -n "$SUDO_USERS" ]; then
	    echo -e "${YELLOW}Users with sudo privileges:${NC}"
    echo "$SUDO_USERS" | tr ',' '\n'
    else
	    echo -e "${GREEN}No users found in sudo group${NC}"
    fi
    echo

    # =========================
    # Root SSH login
    # =========================
    echo -e "${GREEN}${BOLD}▶ ROOT SSH LOGIN:${NC}"

    if grep -qi "^PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null; then
	    echo -e "${RED}Root SSH login is ENABLED${NC}"
    else
	    echo -e "${GREEN}Root SSH login is disabled${NC}"
    fi
    echo

    # =========================
    # Missing security updates
    # =========================
    echo -e "${GREEN}${BOLD}▶ SECURITY UPDATES:${NC}"
    if command -v apt &>/dev/null; then
        sudo apt update -qq
        UPDATES=$(apt list --upgradable 2>/dev/null | grep -i security)
        if [ -n "$UPDATES" ]; then
            echo -e "${RED}Security updates available:${NC}"
            echo "$UPDATES"
        else
            echo -e "${GREEN}No security updates pending${NC}"
        fi
    elif command -v dnf &>/dev/null; then
        sudo dnf updateinfo list security || echo "No security updates pending"
    else
        echo "Package manager not supported"
    fi
    echo

    # =========================
    # Running risky services
    # =========================
    echo -e "${GREEN}${BOLD}▶ RUNNING SERVICES (RISKY):${NC}"
    RISKY_SERVICES=$(systemctl list-units --type=service --state=running 2>/dev/null | \
        grep -Ei "ssh|telnet|ftp|rpc|nfs|smb")

    if [ -n "$RISKY_SERVICES" ]; then
        echo -e "${YELLOW}Potentially risky services detected:${NC}"
        echo "$RISKY_SERVICES"
    else
        echo -e "${GREEN}No obvious risky services running${NC}"
    fi
    echo

    # =========================
    # Listening ports & Process Security
    # =========================
    echo -e "${GREEN}${BOLD}▶ LISTENING PORTS & SECURITY:${NC}"
    
        sudo ss -tulnpH | grep LISTEN | while read -r line; do
            if [[ $line == *"uid:0"* ]]; then
            echo -e "${RED}[!] ROOT-PROCESS:${NC} $line"
        else
            echo -e "${BLUE}[ ] User-process:${NC} $line"
        fi
    done
    echo ""

    # =========================
    # World-writable files
    # =========================
    echo -e "${GREEN}${BOLD}▶ WORLD-WRITABLE FILES (TOP 10):${NC}"
    sudo find / -xdev -type f -perm -0002 2>/dev/null | head -n 10
    echo

    # =========================
    # SUID binaries
    # =========================
    echo -e "${GREEN}${BOLD}▶ SUID BINARIES (TOP 10):${NC}"
    sudo find / -xdev -perm -4000 -type f 2>/dev/null | head -n 10
    echo

    pause_and_return
    ;;

# =========================
# NETWORK SCAN
# =========================
3)
    if ! confirm_network_scan; then
        show_intro
        continue
    fi

    clear
    echo -e "${CYAN}${BOLD}======================================================================="
    echo -e "                          SCANNING NETWORK"
    echo -e "=======================================================================${NC}"
    echo

    IFACE=$(ip route | awk '/default/ {print $5}' | head -n 1)
    IP_RANGE=$(ip -o -f inet addr show "$IFACE" | awk '{print $4}')

    echo -e "${YELLOW}Using range: ${BOLD}$IP_RANGE${NC}"
    echo "Network scan in progress..."
    echo

    ACTIVE_HOSTS=$(sudo nmap -sn "$IP_RANGE" | awk '/Nmap scan report/{print $NF}' | tr -d '()')

    for IP in $ACTIVE_HOSTS; do
        echo -e "${GREEN}${BOLD}▶ ANALYZING HOST: $IP${NC}"
        sudo nmap -A -T4 --version-intensity 5 "$IP"
        echo "--------------------------------------------------"
    done

    echo -e "${GREEN}${BOLD}Scanning complete!${NC}"
    pause_and_return
    ;;

# =========================
# QUIT
# =========================
4)
    echo -e "${YELLOW}Quit...${NC}"
    exit 0
    ;;

*)
    echo -e "${RED}Invalid choice. Please select 1-4.${NC}"
    sleep 1.5
    show_intro
    ;;
    esac
done

