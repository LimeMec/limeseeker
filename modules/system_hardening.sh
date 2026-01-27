#!/usr/bin/env bash

# ----------------
# Module metadata
# ----------------
system_hardening_NAME="System hardening"
system_hardening_DESC="
Validates hardening best practices and secure defaults (read-only).


Highlights:
• SSH hardening recommendations
• Firewall status (ufw/firewalld)
• Kernel/sysctl protections
• Filesystem mount protections
• Core dump and ptrace restrictions


Use this to reduce attack surface and verify baseline security posture.
"

# -----------------------
# Helper: sysctl checker
# -----------------------
check_sysctl() {
    local key="$1"
    local expected="$2"

    local current
    current=$(sysctl -n "$key" 2>/dev/null)

    if [[ -z "$current" ]]; then
        ui_echo "${YELLOW}[INFO]${NC} $key not available"
        log_to_file "[INFO] $key not available"
        return
    fi

    if [[ "$current" == "$expected" ]]; then
        ui_echo "${GREEN}[OK]${NC} $key = $current"
        log_to_file "[OK] $key = $current"
    else
        ui_echo "${RED}[WARN]${NC} $key = $current (expected: $expected)"
        log_to_file "[WARN] $key = $current (expected: $expected)"
    fi
}

# -----------------
# Main module logic
# -----------------
system_hardening() {

    ui_clear
    ui_echo "${CYAN}${BOLD}Scanning system hardening configuration...${NC}"
    log_to_file "▶ Scanning system hardening configuration"
    ui_echo

    # --------------
    # SSH hardening
    # --------------
    ui_echo "${GREEN}${BOLD}▶ SSH HARDENING:${NC}"
    log_to_file "▶ SSH HARDENING:"

    if command -v sshd &>/dev/null; then
        SSH_CONF=$(sshd -T 2>/dev/null)

        declare -A SSH_CHECKS=(
            ["permitrootlogin"]="no"
            ["passwordauthentication"]="no"
            ["x11forwarding"]="no"
            ["maxauthtries"]="3"
        )

        for key in "${!SSH_CHECKS[@]}"; do
            value=$(echo "$SSH_CONF" | awk -v k="$key" '$1==k {print $2}')
            expected="${SSH_CHECKS[$key]}"

            if [[ "$value" == "$expected" ]]; then
                ui_echo "${GREEN}[OK]${NC} $key = $value"
                log_to_file "[OK] $key = $value"
            else
                ui_echo "${YELLOW}[WARN]${NC} $key = ${value:-unset} (recommended: $expected)"
                log_to_file "[WARN] $key = ${value:-unset} (recommended: $expected)"
            fi
        done
    else
        ui_echo "${YELLOW}[INFO]${NC} sshd not installed – skipping SSH hardening checks"
        log_to_file "[INFO] sshd not installed – skipping SSH hardening checks"
    fi

    echo

    # ----------------
    # Firewall status
    # ----------------
    ui_echo "${GREEN}${BOLD}▶ FIREWALL STATUS:${NC}"
    log_to_file "▶ FIREWALL STATUS:"

    if command -v ufw &>/dev/null; then
        if ufw status | grep -q "Status: active"; then
            ui_echo "${GREEN}[OK]${NC} UFW firewall is active"
            log_to_file "[OK] UFW firewall is active"
        else
            ui_echo "${RED}[WARN]${NC} UFW installed but not active"
            log_to_file "[WARN] UFW installed but not active"
        fi
    elif command -v firewall-cmd &>/dev/null; then
        if firewall-cmd --state 2>/dev/null | grep -q running; then
            ui_echo "${GREEN}[OK]${NC} firewalld is running"
            log_to_file "[OK] firewalld is running"
        else
            ui_echo "${RED}[WARN]${NC} firewalld installed but not running"
            log_to_file "[WARN] firewalld installed but not running"
        fi
    else
        ui_echo "${YELLOW}[INFO]${NC} No supported firewall detected"
        log_to_file "[INFO] No supported firewall detected"
    fi

    echo

    # -------------------------
    # Kernel hardening (sysctl)
    # -------------------------
    ui_echo "${GREEN}${BOLD}▶ KERNEL HARDENING (SYSCTL):${NC}"
    log_to_file "▶ KERNEL HARDENING (SYSCTL):"

    check_sysctl kernel.randomize_va_space 2
    check_sysctl kernel.kptr_restrict 2
    check_sysctl fs.protected_symlinks 1
    check_sysctl fs.protected_hardlinks 1
    check_sysctl net.ipv4.conf.all.accept_redirects 0
    check_sysctl net.ipv4.conf.all.send_redirects 0
    check_sysctl net.ipv4.ip_forward 0

    echo

    # -----------------------
    # Filesystem protections
    # -----------------------
    ui_echo "${GREEN}${BOLD}▶ FILESYSTEM MOUNT OPTIONS:${NC}"
    log_to_file "▶ FILESYSTEM MOUNT OPTIONS:"

    check_mount() {
        local mountpoint="$1"
        local option="$2"

        if mount | grep "on $mountpoint " | grep -q "$option"; then
            ui_echo "${GREEN}[OK]${NC} $mountpoint mounted with $option"
            log_to_file "[OK] $mountpoint mounted with $option"
        else
            ui_echo "${YELLOW}[WARN]${NC} $mountpoint missing $option"
            log_to_file "[WARN] $mountpoint missing $option"
        fi
    }

    check_mount /tmp noexec
    check_mount /tmp nosuid
    check_mount /home nodev

    echo

    # --------------------
    # Core dumps & ptrace
    # --------------------
    ui_echo "${GREEN}${BOLD}▶ PROCESS HARDENING:${NC}"
    log_to_file "▶ PROCESS HARDENING:"

    COREDUMP=$(ulimit -c)
    if [[ "$COREDUMP" == "0" ]]; then
        ui_echo "${GREEN}[OK]${NC} Core dumps disabled"
        log_to_file "[OK] Core dumps disabled"
    else
        ui_echo "${YELLOW}[WARN]${NC} Core dumps enabled (ulimit -c = $COREDUMP)"
        log_to_file "[WARN] Core dumps enabled (ulimit -c = $COREDUMP)"
    fi

    check_sysctl kernel.yama.ptrace_scope 1

    ui_echo
    ui_echo "${CYAN}${BOLD}System hardening scan completed.${NC}"
    log_to_file "✔ System hardening scan completed"

    return 0
}

