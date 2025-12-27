#!/usr/bin/env bash
# LimeSeeker - System & Network Security Scanner
# Linux + Vim + Bash (Kali)

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
BLUE='\033[0;34m'
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
    echo -e "              LimeSeeker - System & Network Security Scanner"
    echo -e "=======================================================================${NC}"
    echo -e "${RED}${BOLD}   IMPORTANT:${NC}${CYAN} Only scan networks you own or have permission to test.${NC}"
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
# NETWORK VULNERABILITY SCAN
# =========================
network_vuln_scan() {

    clear
    echo -e "${CYAN}${BOLD}======================================================================="
    echo -e "               SCANNING: NETWORK VULNERABILITIES"
    echo -e "=======================================================================${NC}"
    echo

    IFACE=$(ip route | awk '/default/ {print $5}' | head -n 1)
    IP_RANGE=$(ip -o -f inet addr show "$IFACE" | awk '{print $4}')

    # Säkerhetskontroll – endast privata nät
    if [[ ! "$IP_RANGE" =~ ^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])) ]]; then
        echo -e "${RED}ERROR: Public IP range detected ($IP_RANGE)${NC}"
        pause_and_return
        return
    fi

    echo -e "${GREEN}${BOLD}▶ Interface:${NC} $IFACE"
    echo -e "${GREEN}${BOLD}▶ Target network:${NC} $IP_RANGE"
    echo

    echo -e "${GREEN}${BOLD}▶ Discovering active hosts...${NC}"
    HOSTS=$(nmap -sn "$IP_RANGE" | awk '/Nmap scan report/{print $NF}')

    if [ -z "$HOSTS" ]; then
        echo -e "${RED}No active hosts found${NC}"
        pause_and_return
        return
    fi

    for HOST in $HOSTS; do
        echo
        echo -e "${BLUE}${BOLD}▶ Analyzing host: $HOST${NC}"

        echo -e "${GREEN}• Open ports & services${NC}"
        nmap -sS -sV --open -T3 "$HOST"

        echo -e "${YELLOW}• Vulnerability checks${NC}"
        nmap --script vuln "$HOST"
    done

    echo
    echo -e "${GREEN}${BOLD}Network vulnerability scan completed.${NC}"
    pause_and_return
}

# =========================
# WIRELESS SECURITY SCAN
# =========================
wireless_scan() {
    clear
    echo -e "${CYAN}${BOLD}======================================================================="
    echo -e "                 SCANNING: WIRELESS NETWORKS"
    echo -e "=======================================================================${NC}"
    echo

    if ! command -v iw &>/dev/null; then
        echo -e "${RED}iw not installed${NC}"
        pause_and_return
	return
    fi

    WLAN_IFACES=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}')

    if [ -z "$WLAN_IFACES" ]; then
        echo -e "${YELLOW}No wireless interface detected${NC}"
        pause_and_return
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

    pause_and_return
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
    echo "  3) Network vulnerability scan"
    echo "  4) Wireless inventory scan"
    echo "  5) Quit"
    echo

    read -rp "Select option [1-5]: " choice
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
    echo -e "${GREEN}${BOLD}▶ SYSTEM UPTIME:${NC} $(uptime -p)"

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
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ GPU: ${NC}"
    command -v lspci &>/dev/null && lspci | grep -i vga || echo "lspci not installed"

    echo
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ CPU: ${NC}"
    lscpu | grep -E "Model name|Vendor ID|Architecture|CPU\(s\)|Core\(s\) per socket|Thread\(s\) per core|Socket\(s\)"

    echo
    awk -F: '/cpu MHz/ {print $2}' /proc/cpuinfo | sort -n | \
    awk 'NR==1{min=$1} END{print "Min MHz:", min "\nMax MHz:", $1}'

    echo
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ MEMORY: ${NC}"
    free -h

    echo
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ DISK SPACE: ${NC}"
    df -h --exclude-type=tmpfs --exclude-type=devtmpfs

    echo
    sleep 0.5
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
    sleep 0.5
    echo -e "${CYAN}${BOLD}======================================================================="
    echo -e "                    SCANNING: LOCAL SECURITY"
    echo -e "=======================================================================${NC}"
    echo
    echo

    # =========================
    # Kernel & OS
    # =========================
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ KERNEL & OS:${NC}"
    echo "Kernel: $(uname -r)"
    echo "OS:     $(uname -o)"
    echo

    # =========================
    # Sudo users
    # =========================
    sleep 0.5
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
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ ROOT SSH LOGIN:${NC}"

    ROOT_SSH=$(sshd -T 2>/dev/null | awk '/permitrootlogin/ {print $2}')

    case "$ROOT_SSH" in
	    yes)
		    echo -e "${RED}Root SSH login ENABLED (password allowed)${NC}"
                    ;;
    prohibit-password|without-password)
                    echo -e "${YELLOW}Root SSH login allowed via SSH key only${NC}"
                    ;;
    forced-commands-only)
                    echo -e "${YELLOW}Root SSH login restricted (forced commands)${NC}"
                    ;;
            no)
		    echo -e "${GREEN}Root SSH login DISABLED${NC}"
                    ;;
            *)
		    echo -e "${YELLOW}Unknown SSH root login state: $ROOT_SSH${NC}"
                    ;;
    esac
    echo
    # =========================
    # Missing system updates
    # =========================
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ AVAILABLE SYSTEM UPDATES:${NC}"
    if command -v apt &>/dev/null; then
        sudo apt update -qq
	UPDATES=$(apt list --upgradable 2>/dev/null | sed 1d)
        if [ -n "$UPDATES" ]; then
            echo -e "${RED}System updates available:${NC}"
            echo "$UPDATES"
        else
            echo -e "${GREEN}No system  updates pending${NC}"
        fi
    elif command -v dnf &>/dev/null; then
        sudo dnf updateinfo list security || echo "No system  updates pending"
    else
        echo "Package manager not supported"
    fi
    echo

    # =========================
    # Running risky services
    # =========================
    sleep 0.5
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
    sleep 0.5
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
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ WORLD-WRITABLE FILES (TOP 10):${NC}"
    sudo find / -xdev -type f -perm -0002 2>/dev/null | head -n 10
    echo

    # =========================
    # SUID binaries
    # =========================
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ SUID BINARIES (TOP 10):${NC}"
    sudo find / -xdev -perm -4000 -type f 2>/dev/null | head -n 10

    echo -e "${GREEN}${BOLD}▶ CVE CHECK (COMMON PACKAGES):${NC}"

    #========================
    # CVE-check
    # =======================
    sleep 0.5    
    OPENSSL=$(openssl version 2>/dev/null | awk '{print $2}')
    SSHD=$(sshd -V 2>&1 | head -n1 | awk '{print $1,$2}')
    KERNEL=$(uname -r)

    check_cve() {
	    if ! command -v searchsploit &>/dev/null; then
		    echo -e "${YELLOW}searchsploit not installed – skipping CVE checks${NC}"
            return
    fi

	    local name="$1"
            local version="$2"

            if searchsploit "$name" "$version" | grep -qi cve; then
		    echo -e "${RED}[!] CVEs found for $name $version${NC}"
                    searchsploit "$name" "$version" | head -n 5
            else
		    echo -e "${GREEN}[OK] No CVEs found for $name $version${NC}"
            fi
    }

    check_cve "openssl" "$OPENSSL"
    check_cve "openssh" "$SSHD"
    check_cve "linux kernel" "$KERNEL"
    echo

    pause_and_return
    ;;

# =========================
# NETWORK VULNERABILITY SCAN
# =========================
3)
    if confirm_network_scan; then
        network_vuln_scan
        show_intro
    else
        show_intro
    fi
    ;;

# =========================
# WIRELESS SECURITY SCAN
# =========================
4)
   wireless_scan
   ;;

# =========================
# QUIT
# =========================
5)
    echo -e "${YELLOW}Quit...${NC}"
    exit 0
    ;;

*)
    echo -e "${RED}Invalid choice.${NC}"
    sleep 1
    show_intro
    ;;
    esac
done

