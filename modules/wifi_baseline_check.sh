#!/usr/bin/env bash

wifi_baseline_check() {

    LOCATION="$1"

    ui_clear
    ui_echo "${CYAN}${BOLD}Comparing WiFi environment against baseline...${NC}"
    log_to_file "▶ WiFi baseline comparison started"
    echo

    [[ -z "$LOCATION" ]] && {
        ui_echo "${RED}[ERROR]${NC} Location name required (e.g. home/office/lab)"
        log_to_file "[ERROR] Location name required"
        return 1
    }

    WIFI_RAW_DIR="$BASE_DIR/reports/limeseeker_wifi"
    BASELINE_DIR="$BASE_DIR/reports/baselines/wifi/$LOCATION"

    [[ ! -d "$WIFI_RAW_DIR" ]] && {
        ui_echo "${YELLOW}[INFO]${NC} No WiFi scan data found"
        log_to_file "[INFO] No WiFi scan data found"
        return 0
    }

    [[ ! -d "$BASELINE_DIR" ]] && {
        ui_echo "${YELLOW}[INFO]${NC} No baseline found for location: $LOCATION"
        log_to_file "[INFO] No baseline found for location: $LOCATION"
        return 0
    }

    WLAN_IFACES=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}')
    [[ -z "$WLAN_IFACES" ]] && {
        ui_echo "${YELLOW}[INFO]${NC} No wireless interfaces detected"
        log_to_file "[INFO] No wireless interfaces detected"
        return 0
    }

    for IFACE in $WLAN_IFACES; do

        BASELINE_FILE="$BASELINE_DIR/$IFACE.baseline"
        [[ ! -f "$BASELINE_FILE" ]] && {
            ui_echo "${YELLOW}[INFO]${NC} No baseline for $LOCATION / $IFACE"
            log_to_file "[INFO] No baseline for $LOCATION / $IFACE"
            echo
            continue
        }

        CUR_RAW=$(ls -t "$WIFI_RAW_DIR"/"${IFACE}_"*.raw 2>/dev/null | head -n 1)
        [[ -z "$CUR_RAW" ]] && continue

        TMP_CUR="/tmp/limeseeker_wifi_current_${IFACE}.txt"

        awk '
        /BSS/ {bssid=$2}
        /SSID:/ {
            ssid=$0
            sub(/^SSID: /,"",ssid)
            enc="OPEN"
            wps="no"
            chan="?"
        }
        /DS Parameter set/ {chan=$5}
        /RSN:/ {enc="WPA2/WPA3"}
        /WPA:/ {enc="WPA"}
        /WEP/ {enc="WEP"}
        /WPS:/ {wps="yes"}
        /SSID:/ {
            printf "AP|SSID=%s|BSSID=%s|ENC=%s|CHAN=%s|WPS=%s\n",
            ssid,bssid,enc,chan,wps
        }' "$CUR_RAW" > "$TMP_CUR"

        ui_echo "${GREEN}${BOLD}▶ BASELINE DEVIATIONS ($LOCATION / $IFACE):${NC}"
        log_to_file "▶ BASELINE DEVIATIONS ($LOCATION / $IFACE)"

        grep -Fxv -f "$BASELINE_FILE" "$TMP_CUR" | while read -r ap; do
            ui_echo "${RED}[NEW]${NC} $ap"
            log_to_file "[NEW][$LOCATION/$IFACE] $ap"
        done

        grep -Fxv -f "$TMP_CUR" "$BASELINE_FILE" | grep '^AP|' | while read -r ap; do
            ui_echo "${YELLOW}[MISSING]${NC} $ap"
            log_to_file "[MISSING][$LOCATION/$IFACE] $ap"
        done

        grep '^AP|' "$TMP_CUR" | while read -r cur; do
            ssid=$(echo "$cur" | sed -n 's/.*SSID=\([^|]*\).*/\1/p')
            cur_enc=$(echo "$cur" | sed -n 's/.*ENC=\([^|]*\).*/\1/p')

            base_enc=$(grep "SSID=$ssid|" "$BASELINE_FILE" | sed -n 's/.*ENC=\([^|]*\).*/\1/p' | head -n 1)

            [[ -n "$base_enc" && "$base_enc" != "$cur_enc" ]] && {
                ui_echo "${RED}[CHANGE]${NC} SSID=$ssid ENC $base_enc -> $cur_enc"
                log_to_file "[CHANGE][$LOCATION/$IFACE] SSID=$ssid ENC $base_enc -> $cur_enc"
            }
        done

        rm -f "$TMP_CUR"
        echo
    done

    ui_echo "${CYAN}${BOLD}WiFi baseline comparison completed.${NC}"
    log_to_file "✔ WiFi baseline comparison completed"

    return 0
}

