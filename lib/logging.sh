#!/usr/bin/env bash

LOGGING_PAUSED=0

logging_enabled() {
    [[ -n "$REPORT_FILE" ]]
}

log_pause() {
    logging_enabled || return
    LOGGING_PAUSED=1
}

log_resume() {
    logging_enabled || return
    LOGGING_PAUSED=0
}

# -------------------------------------------------
# Intern: ta bort ANSI-färgkoder
# -------------------------------------------------
_strip_colors() {
    sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

# -------------------------------------------------
# Loggrubrik – EN timestamp, räcker
# -------------------------------------------------
log_header() {
    {
        echo "==========================================================="
        echo "              LimeSeeker Scan Report"
        echo "              Started: $(date)"
        echo "==========================================================="
        echo
    } >> "$REPORT_FILE"
}

# -------------------------------------------------
# Loggfooter
# -------------------------------------------------
log_footer() {
    {
        echo
        echo "==========================================================="
        echo "              Scan finished: $(date)"
        echo "==========================================================="
    } >> "$REPORT_FILE"
}

# -------------------------------------------------
# Eventlogg (MENY, EXIT, FEL) – med timestamp
# -------------------------------------------------
log_event() {
    [[ $LOGGING_PAUSED -eq 1 ]] && return
    logging_enabled || return
    printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$*" \
        | _strip_colors >> "$REPORT_FILE"
}

# -------------------------------------------------
# DIN BEFINTLIGA LOGGNING (UTAN timestamp)
# -------------------------------------------------
log_to_file() {
    [[ $LOGGING_PAUSED -eq 1 ]] && return
    logging_enabled || return
    printf "%s\n" "$*" | _strip_colors >> "$REPORT_FILE"
}

# -------------------------------------------------
# Sektion / modulrubrik
# -------------------------------------------------
log_section() {
    [[ $LOGGING_PAUSED -eq 1 ]] && return
    logging_enabled || return
    {
        echo
        echo "-----------------------------------------------------------"
        echo "$*" | _strip_colors
        echo "-----------------------------------------------------------"
    } >> "$REPORT_FILE"
}

# -------------------------------------------------
# Pausa / återuppta loggning (används av menu.sh)
# -------------------------------------------------
log_pause() {
    LOGGING_PAUSED=1
}

log_resume() {
    LOGGING_PAUSED=0
}

# -------------------------------------------------
# Summary
# -------------------------------------------------
log_summary() {
    printf "%-30s : %s\n" "$1" "$2" | _strip_colors >> "$REPORT_FILE"
}

