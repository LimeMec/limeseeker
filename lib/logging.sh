#!/usr/bin/env bash

# ---------------------
# Initiating variables
# ---------------------
LOGGING_PAUSED=${LOGGING_PAUSED:-0}

# ---------------------------------------------
# Check logging allowed
# ---------------------------------------------
logging_enabled() {
    [[ "$LOGGING_ENABLED" == "false" ]] && return 1
    [[ -z "$REPORT_FILE" ]] && return 1
    return 0
}

# ------------------
# Strip ANSI-colors
# ------------------
_strip_colors() {
    sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

# ---------------
# Header logging
# ---------------
log_header() {
    logging_enabled || return
    {
        echo "==========================================================="
        echo "              LimeSeeker Scan Report"
        echo "              Started: $(date)"
        echo "==========================================================="
        echo
    } >> "$REPORT_FILE"
}

# -----------
# Loggfooter
# -----------
log_footer() {
    logging_enabled || return
    {
        echo
        echo "_    _ _  _ ____ ____ ____ ____ _  _ ____ ____ "
        echo "|    | |\/| |___ [__  |___ |___ |_/  |___ |__/ "
        echo "|___ | |  | |___ ___] |___ |___ | \_ |___ |  \ " 
	echo "Report complete: $(date)"
    } | _strip_colors >> "$REPORT_FILE"
}

# -------------
# Write to log
# # -----------
log_event() {
    [[ "$LOGGING_PAUSED" -eq 1 ]] && return
    logging_enabled || return
    
    printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$*" | _strip_colors >> "$REPORT_FILE"
}

# ------------------------
# log_to_file: Fix errors
# ------------------------
log_to_file() {
    log_event "$@"
}

# ------------------------
# Section / header module
# ------------------------
log_section() {
    [[ "$LOGGING_PAUSED" -eq 1 ]] && return
    logging_enabled || return
    {
        echo
        echo "-----------------------------------------------------------"
        echo "$*"
        echo "-----------------------------------------------------------"
    } | _strip_colors >> "$REPORT_FILE"
}

# ---------------
# Pause / resume
# ---------------
log_pause() {
    LOGGING_PAUSED=1
}

log_resume() {
    LOGGING_PAUSED=0
}

# --------
# Summary
# --------
log_summary() {
    logging_enabled || return
    printf "%-30s : %s\n" "$1" "$2" | _strip_colors >> "$REPORT_FILE"
}

