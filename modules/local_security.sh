#!/usr/bin/env bash

# ----------------
# Module metadata
# ----------------
local_security_NAME="Local security"
local_security_DESC="
Performs common local security checks (read-only).


Highlights:
• Sudo users, SSH root login status
• Available system updates
• Risky running services
• Listening ports (root vs user)
• World-writable files and SUID binaries
• Optional CVE lookups (searchsploit, if installed)


Use this to spot local weaknesses and misconfigurations.
"

# ---------
# CVE scan
# ---------
check_cve() {

    if ! command -v searchsploit &>/dev/null; then
        ui_echo "${YELLOW}searchsploit not installed – skipping CVE checks${NC}"
        log_to_file "searchsploit not installed - skipping CVE checks"
        return
    fi

    local name="$1"
    local version="$2"

    ui_echo "${BLUE}${BOLD}[*] CVE scan:${NC} $name (installed: $version)"
    log_to_file "[*] CVE scan: $name (installed: $version)"

    local results
    results=$(searchsploit --cve "$name" 2>/dev/null | \
        grep -E "CVE-[0-9]{4}-[0-9]{4,7}" | head -n 10)

    if [ -z "$results" ]; then
        ui_echo "${GREEN}[OK] No CVEs found in local database${NC}"
        log_to_file "[OK] No CVEs found in local database"
        return
    fi

    ui_echo "${RED}[!] Potential vulnerabilities detected for $name${NC}"
    log_to_file "[!] Potential vulnerabilities detected for $name"
    echo "$results"
    ui_echo "${YELLOW}    → Manual validation required${NC}"
    log_to_file "    → Manual validation required"
}

#----------------
# local_security
# ---------------
local_security() {

    if declare -F ui_clear >/dev/null; then
        ui_clear
    fi

    #-------------------
    # Header module
    # ----------------- 
    echo
    ui_echo "${CYAN}${BOLD}Scanning local security...${NC}"
    log_to_file "▶ Scanning local security..."
    echo
    echo

    # ----------
    # Sudo user
    # ----------
    ui_echo "${GREEN}${BOLD}▶ USERS WITH SUDO ACCESS:${NC}"
    log_to_file "▶ USERS WITH SUDO ACCESS:"
    
    local SUDO_USERS
    SUDO_USERS=$(getent group sudo 2>/dev/null | cut -d: -f4)

    if [ -n "$SUDO_USERS" ]; then
        ui_echo "${YELLOW}Users with sudo privileges:${NC}"
	log_to_file "Users with sudo privileges"
        echo "$SUDO_USERS" | tr ',' '\n'
    else
        ui_echo "${GREEN}No users found in sudo group${NC}"
	log_to_file "No users found in sudo group"
    fi
    echo

    # ---------------
    # Root SSH login
    # ---------------
    ui_echo "${GREEN}${BOLD}▶ ROOT SSH LOGIN:${NC}"
    log_to_file "▶ ROOT SSH LOGIN:"
    local ROOT_SSH
    ROOT_SSH=$(sshd -T 2>/dev/null | awk '/permitrootlogin/ {print $2}')

    case "$ROOT_SSH" in
        yes)
            ui_echo "${RED}Root SSH login ENABLED (password allowed)${NC}"
	    log_to_file "Root SSH login ENABLED (password allowed)"
            ;;
        prohibit-password|without-password)
            ui_echo "${YELLOW}Root SSH login allowed via SSH key only${NC}"
	    log_to_file "Root SSH login allowed via SSH key only"
            ;;
        forced-commands-only)
            ui_echo "${YELLOW}Root SSH login restricted (forced commands)${NC}"
	    log_to_file "Root SSH login restricted (forced commands)"
            ;;
        no)
            ui_echo "${GREEN}Root SSH login DISABLED${NC}"
	    log_to_file "Root SSH login DISABLED"
            ;;
        *)
            ui_echo "${YELLOW}Unknown SSH root login state: $ROOT_SSH${NC}"
	    log_to_file "Unknown SSH root login state: $ROOT_SSH"
            ;;
    esac
    echo

    # ---------------
    # System updates
    # ---------------
    sleep 0.5
    ui_echo "${RED}${BOLD}▶ UNPATCHED PACKAGES (SECURITY RISK):${NC}"
    log_to_file "▶ AVAILABLE SYSTEM UPDATES:"

    if command -v apt &>/dev/null; then
        apt update -qq
        local UPDATES
        UPDATES=$(apt list --upgradable 2>/dev/null | sed 1d)

        if [ -n "$UPDATES" ]; then	    
            ui_echo "${RED}${BOLD}System updates available:${NC}"
	    log_to_file "System updates available:"
            echo "$UPDATES"
        else
            ui_echo "${GREEN}${BOLD}No system updates pending${NC}"
	    log_to_file "No system updates pending"
        fi

    elif command -v dnf &>/dev/null; then
        dnf updateinfo list security || echo "No system updates pending"
    else
        echo "Package manager not supported"
	return 1
    fi
    echo

    # ---------------
    # Risky services
    # ---------------
    ui_echo "${GREEN}${BOLD}▶ RUNNING SERVICES (RISKY):${NC}"
    log_to_file "▶ RUNNING SERVICES (RISKY):"

    local RISKY_SERVICES
    RISKY_SERVICES=$(systemctl list-units --type=service --state=running 2>/dev/null | \
        grep -Ei "ssh|telnet|ftp|rpc|nfs|smb")

    if [ -n "$RISKY_SERVICES" ]; then
        ui_echo "${YELLOW}Potentially risky services detected:${NC}"
	log_to_file "Potentially risky services detected:"
        echo "$RISKY_SERVICES"
    else
        ui_echo "${GREEN}No obvious risky services running${NC}"
	log_to_file "No obvious risky services running"
    fi
    echo

    # ---------------------------
    # Listening ports & processes
    # ---------------------------
    ui_echo "${GREEN}${BOLD}▶ LISTENING PORTS & SECURITY:${NC}"
    log_to_file "▶ LISTENING PORTS & SECURITY:"

    while read -r line; do
        if [[ $line == *"uid:0"* ]]; then
            ui_echo "${RED}[ROOT]${NC} $line"
	    log_to_file "[ROOT] $line"
        else
            ui_echo "${BLUE}[USER]${NC} $line"
	    log_to_file "[USER] $line"
        fi
    done < <(ss -tulnpH | grep LISTEN)

    echo

    # --------------------
    # Global write access
    # --------------------
    ui_echo "${GREEN}${BOLD}▶ WORLD-WRITABLE FILES (TOP 10):${NC}"
    log_to_file "▶ WORLD-WRITABLE FILES (TOP 10):"
    find / -xdev -type f -perm -0002 2>/dev/null | head -n 10
    echo

    # --------------
    # SUID binaries
    # --------------
    ui_echo "${GREEN}${BOLD}▶ SUID BINARIES (TOP 10):${NC}"
    log_to_file "▶ SUID BINARIES (TOP 10):"
    find / -xdev -perm -4000 -type f 2>/dev/null | head -n 10
    echo

    # ----------
    # CVE check
    # ----------
    ui_echo "${GREEN}${BOLD}▶ CVE CHECK (COMMON PACKAGES):${NC}"
    log_to_file "▶ CVE CHECK (COMMON PACKAGES):"

    OPENSSL=$(openssl version 2>/dev/null | awk '{print $2}')
    SSHD=$(sshd -V 2>&1 | head -n1 | awk '{print $1,$2}')
    KERNEL=$(uname -r)

    check_cve "openssl" "$OPENSSL"
    check_cve "openssh" "$SSHD"
    check_cve "linux kernel" "$KERNEL"

    return 0
}

