#!/usr/bin/env bash

# -----------------------------------
# Initiera variabel om den inte finns
# -----------------------------------
LOGGING_PAUSED=${LOGGING_PAUSED:-0}

# ---------------------------------------------
# Kontrollera om loggning är aktiv och tillåten
# ---------------------------------------------
logging_enabled() {
    [[ "$LOGGING_ENABLED" == "false" ]] && return 1
    [[ -z "$REPORT_FILE" ]] && return 1
    return 0
}

# -------------------------------
# Intern: ta bort ANSI-färgkoder
# ------------------------------
_strip_colors() {
    sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

# -----------------------
# Loggrubrik
# -----------------------
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

# ---------------------------------------------------------
# log_event: Den primära funktionen för att skriva till logg
# ---------------------------------------------------------
log_event() {
    [[ "$LOGGING_PAUSED" -eq 1 ]] && return
    logging_enabled || return
    
    # Skriver till loggfilen med tidstämpel
    printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$*" | _strip_colors >> "$REPORT_FILE"
}

# ---------------------------------------------------------
# log_to_file: Fixar felmeddelanden i local_inventory.sh
# ---------------------------------------------------------
log_to_file() {
    # Vi skickar detta vidare till log_event
    log_event "$@"
}

# ----------------------
# Sektion / modulrubrik
# ----------------------
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

# -------------------------------------------------
# Pausa / återuppta loggning (används av menu.sh)
# -------------------------------------------------
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

