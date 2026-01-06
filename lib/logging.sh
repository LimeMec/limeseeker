#!/usr/bin/env bash

# Loggning för LimeSeeker
# Färger i terminal men inga färger i logg


# -------------------------
# Loggstämpel
# -------------------------
_log_ts() {
    date "+%Y-%m-%d %H:%M:%S"
}

# -------------------------
# Rensar färger innan logg
# -------------------------
_strip_colors() {
    sed 's/\x1B\[[0-9;]*[mK]//g'
}

# ---------------------------
# Text utan färger till logg
# ---------------------------
log_to_file() {
    echo "$*" >> "$REPORT_FILE"
}

# ------------------------------
# Text med färg till terminalen
# ------------------------------
log_info() {
    echo -e "[$(_log_ts)] [INFO]  $*"
    log_to_file "[$(_log_ts)] [INFO]  $*"
}

log_ok() {
    echo -e "[$(_log_ts)] [ OK ]  ${GREEN}$*${NC}"
    log_to_file "[$(_log_ts)] [ OK ]  $*"
}

log_warn() {
    echo -e "[$(_log_ts)] [WARN]  ${YELLOW}$*${NC}"
    log_to_file "[$(_log_ts)] [WARN]  $*"
}

log_error() {
    echo -e "[$(_log_ts)] [ERROR] ${RED}$*${NC}" >&2
    log_to_file "[$(_log_ts)] [ERROR] $*"
}

log_debug() {
    [[ "$DEBUG" == "1" ]] || return 0
    echo -e "[$(_log_ts)] [DEBUG] $*"
    log_to_file "[$(_log_ts)] [DEBUG] $*"
}

# -------------------------
# Rubriker
# -------------------------
log_section() {
    echo
    echo "--------------------------------------------------"
    echo "[$(_log_ts)] $*"
    echo "--------------------------------------------------"
    log_to_file "--------------------------------------------------"
    log_to_file "$*"
    log_to_file "--------------------------------------------------"
}

# -------------------------
# Automatisk loggning
# -------------------------
run_cmd() {
    local desc="$1"
    shift

    log_info "$desc"
    log_debug "Command: $*"

    if "$@"; then
        log_ok "$desc completed"
    else
        log_error "$desc failed"
        return 1
    fi
}
# ---------------------------
# Pausa / återuppta loggning
# ---------------------------

log_pause() {
    exec 3>&1 4>&2
    exec >/dev/tty 2>/dev/tty
}

log_resume() {
    exec >&3 2>&4
    exec 3>&- 4>&-
}


