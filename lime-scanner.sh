#!/bin/bash
# Option 1: Run computer scan
# Option 2: Run network scan
# Option 3: Quit script


# Färger
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo
sleep 0.5
echo -e "${CYAN}${BOLD}======================================================"
echo -e "              LimeScanner - HW-OS-NET Scanner"
echo -e "======================================================${NC}"
echo -e "${BOLD}Logged in user:${NC} $(whoami)"
echo -e "${BOLD}Created:${NC} $(date)"
echo -e "${BOLD}System uptime:${NC} $(uptime -p)"
echo
echo -e "${RED}${BOLD}*DISCLAIMER* Only scan networks you own or have permissions to test!${NC}"
echo
echo -e "${BOLD}Choose your analyze: (1-3)${NC}"
PS3=":"
options=("Computer scan" "Network scan" "Quit")
select opt in "${options[@]}"
do
case $opt in
"Computer scan")
echo
echo
echo
echo "Running computer scanner..."
echo
clear
sleep 0.5
echo -e "${CYAN}${BOLD}======================================================"
echo -e "       COMPUTER SCANNER - OS / HARDWARE / NETWORK"
echo -e "======================================================${NC}"
echo
sleep 0.5
echo -e "     ${BOLD}[ OPERATING SYSTEM: ]${NC}"
# Skriver ut information om  operativsystemet
echo "OS: $(uname -o)"
echo "Nodename: $(uname -n)"
echo "Kernel release: $(uname -r)"
echo "Kerner version: $(uname -v)" 
echo "HW Architecture: $(uname -m)"


echo
sleep 0.5
echo -e "     ${BOLD}[ GPU ]${NC}"
# Skriver ut modell av grafikkort
lspci | grep -i vga 


echo
sleep 0.5
echo -e "     ${BOLD}[ CPU: ]${NORM}"
# Skriver ut specifikation på CPU
lscpu | grep -E "Model name|Modellnamn"
lscpu | grep -E "Vendor ID|Tillverkare"
lscpu | grep -E "Architecture|Arkitektur"
lscpu | grep -E "CPU op-mode|Driftsläge"
lscpu | grep -E "Byte Order|Byteordning" 
lscpu | grep -E "CPU\(s\)|CPU\(er\)"
lscpu | grep -E "Core\(s\) per socket|Kärna\(or\) per socket"
lscpu | grep -E "Thread\(s\) per core|Tråd\(ar\) per kärna"
lscpu | grep -E "Socket\(s\)|Socket"
lscpu | grep -E "NUMA node\(s\)|NUMA-noder"
echo "Max MHz:                  	         $(cat /proc/cpuinfo | grep 'cpu MHz' | head -n 1 | awk '{print $4}')"
echo "Min MHz:                          	 $(cat /proc/cpuinfo | grep 'cpu MHz' | tail -n 1 | awk '{print $4}')"


echo
sleep 0.5
echo -e "     ${BOLD}[ MEMORY: ]${NC}"
# Skriver ut användning av minnet
free -h


echo
sleep 0.5
echo -e "     ${BOLD}[ DISK SPACE: ]${NC}"
# Skriver ut användning av lagringsutrymmet
df -h --exclude-type=tmpfs --exclude-type=devtmpfs
echo " "


echo
sleep 0.5
echo -e "     ${BOLD}[ NETWORK: ]${NC}"
# Skriver ut modellnamn på nätverkskort
echo "Model name:  $(lspci | grep -i ethernet)"
# Skriver ut MAC-adress
MAC=$(ip link show $IFACE | grep ether | awk '{print $2}')
echo "MAC-adress:  $MAC"
# Skriver ut IP-adress
IP=$(ip a show $IFACE | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
echo "IP-adress:   $IP"
# Skriver ut Gateway
GW=$(ip route | grep default | awk '{print $3}')
echo "Gateway:     $GW"
# Skriver ut Nätmask
NM_CIDR=$(ip a show $IFACE | grep 'inet ' | awk '{print $2}' | cut -d'/' -f2)
echo "Netmask:     /$NM_CIDR"
echo
echo 
;;
"Network scan")
echo
echo
echo
echo "Running Network scanner..."
echo
clear
sleep 0.5
echo -e "${CYAN}${BOLD}======================================================"
echo -e "                 NETWORK SCANNING"
echo -e "======================================================${NC}"

# Identifiera nätverk
IP_RANGE=$(ip route | grep default | awk '{print $3}' | cut -d. -f1-3).0/24
echo
echo -e "${YELLOW}Använder räckvidd: ${BOLD}$IP_RANGE${NC}"
echo -e "Detta kommer ta tid eftersom vi gör en djupanalys...\n"

# Hitta aktiva enheter snabbt först
ACTIVE_HOSTS=$(sudo nmap -sn $IP_RANGE | grep "report for" | awk '{print $NF}' | tr -d '()')

for IP in $ACTIVE_HOSTS; do
    echo -e "${GREEN}${BOLD}▶ ANALYSERAR ENHET: ${IP}${NC}"
    
    # Kör aggressiv skanning (-A) med hög intensitet för versioner
    # --version-intensity 5 ger en bra balans mellan fart och detaljrikedom
    DETAILS=$(sudo nmap -A -T4 --version-intensity 5 $IP)

    # Värdnamn & Tillverkare
    HOSTNAME=$(echo "$DETAILS" | grep "Nmap scan report" | awk '{print $5}')
    MAC_LINE=$(echo "$DETAILS" | grep "MAC Address")
    
    [ "$HOSTNAME" != "$IP" ] && echo -e "  ${BOLD}Värdnamn:${NC} $HOSTNAME"
    if [ ! -z "$MAC_LINE" ]; then
        echo -e "  ${BOLD}MAC-adress:${NC} $(echo $MAC_LINE | awk '{print $3}')"
        echo -e "  ${BOLD}Hårdvara:${NC} $(echo $MAC_LINE | cut -d' ' -f4-)"
    fi

    # Operativsystem
    OS=$(echo "$DETAILS" | grep "OS details" | cut -d':' -f2- | sed 's/^[ \t]*//')
    [ ! -z "$OS" ] && echo -e "  ${BOLD}Operativsystem:${NC} $OS"

    # Nätverksavstånd
    HOPS=$(echo "$DETAILS" | grep "Network Distance" | awk '{print $3}')
    [ ! -z "$HOPS" ] && echo -e "  ${BOLD}Nätverkshopp:${NC} $HOPS"

    # Detaljerade tjänster & Skriptresultat
    echo -e "  ${BOLD}Tjänster & Öppna portar:${NC}"
    # Filtrerar ut rader som visar portar och deras versioner/skriptinfo
    echo "$DETAILS" | grep -E "^[0-9]+/tcp|^[0-9]+/udp" -A 2 | sed 's/^/    /'

    echo -e "--------------------------------------------------"
done

echo -e "${GREEN}${BOLD}Scanning complete!${NC}"
echo
echo
;;
"Quit")
echo "Quit..."
break
;;
*)
echo "Invalid choise: $REPLY"
;;
esac
sleep 0.5
echo -e "${CYAN}${BOLD}======================================================"
echo -e "              LimeScanner - HW-OS-NET Scanner"
echo -e "======================================================${NC}"
echo -e "${BOLD}User:${NC} $(whoami)"
echo -e "${BOLD}Created:${NC} $(date)"
echo -e "${BOLD}System uptime:${NC} $(uptime -p)"
echo
echo -e "${RED}${BOLD}*DISCLAIMER* Only scan networks you own or have persmissions to test!${NC}"
echo
echo -e "${BOLD}Choose type of scan: (1-3)${NC}"
echo -e "${BOLD}1)${NC} Computer scan"
echo -e "${BOLD}2)${NC} Network scan"
echo -e "${BOLD}3)${NC} Quit"
done

