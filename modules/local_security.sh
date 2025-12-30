local_security() {


    check_cve() {

    if ! command -v searchsploit &>/dev/null; then
        echo -e "${YELLOW}searchsploit not installed – skipping CVE checks${NC}"
        return
    fi

    local name="$1"
    local version="$2"

    echo -e "${BLUE}${BOLD}[*] CVE scan:${NC} $name (installed: $version)"

    # Hämta endast riktiga CVE-IDn, minska brus
    local results
    results=$(searchsploit --cve "$name" 2>/dev/null | \
              grep -E "CVE-[0-9]{4}-[0-9]{4,7}" | \
              head -n 10)

    if [ -z "$results" ]; then
        echo -e "${GREEN}[OK] No CVEs found in local database${NC}"
        return
    fi

    echo -e "${RED}[!] Potential vulnerabilities detected for $name${NC}"
    echo "$results"
    echo -e "${YELLOW}    → Manual validation required (version & config dependent)${NC}"
}

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

    local SUDO_USERS
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

    local ROOT_SSH
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
        apt update -qq
        local UPDATES
        UPDATES=$(apt list --upgradable 2>/dev/null | sed 1d)

        if [ -n "$UPDATES" ]; then
            echo -e "${RED}System updates available:${NC}"
            echo "$UPDATES"
        else
            echo -e "${GREEN}No system updates pending${NC}"
        fi

    elif command -v dnf &>/dev/null; then
        dnf updateinfo list security || echo "No system updates pending"
    else
        echo "Package manager not supported"
    fi
    echo

    # =========================
    # Running risky services
    # =========================
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ RUNNING SERVICES (RISKY):${NC}"

    local RISKY_SERVICES
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
    # Listening ports & process security
    # =========================
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ LISTENING PORTS & SECURITY:${NC}"

    while read -r line; do
        if [[ $line == *"uid:0"* ]]; then
            echo -e "${RED}[ROOT]${NC} $line"
        else
            echo -e "${BLUE}[USER]${NC} $line"
        fi
    done < <(ss -tulnpH | grep LISTEN)

    echo

    # =========================
    # World-writable files
    # =========================
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ WORLD-WRITABLE FILES (TOP 10):${NC}"
    find / -xdev -type f -perm -0002 2>/dev/null | head -n 10
    echo

    # =========================
    # SUID binaries
    # =========================
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ SUID BINARIES (TOP 10):${NC}"
    find / -xdev -perm -4000 -type f 2>/dev/null | head -n 10
    echo

    # =========================
    # CVE CHECK
    # =========================
    sleep 0.5
    echo -e "${GREEN}${BOLD}▶ CVE CHECK (COMMON PACKAGES):${NC}"

    OPENSSL=$(openssl version 2>/dev/null | awk '{print $2}')
    SSHD=$(sshd -V 2>&1 | head -n1 | awk '{print $1,$2}')
    KERNEL=$(uname -r)

    check_cve "openssl" "$OPENSSL"
    check_cve "openssh" "$SSHD"
    check_cve "linux kernel" "$KERNEL"
    
    echo
    echo
    log "Local security scan completed"
}

