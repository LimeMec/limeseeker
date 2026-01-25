#!/usr/bin/env bash

main_menu() {
        
    local modules_to_run=()
	
    # -------
    # Ctrl+C 
    # -------
    handle_sigint() {
    echo -e "\n${YELLOW}Ctrl+C detected. Exiting LimeSeeker...${NC}" > /dev/tty
    echo -e "${YELLOW}Cleraring sudo privileges...${NC}" > /dev/tty
    log_event "User aborted LimeSeeker (Ctrl+C)"
    sudo -k
    exit 0
}
    trap handle_sigint SIGINT
    
    # -------
    # Ctrl+D
    # -------
    handle_eof() {
    echo -e "\n${YELLOW}Ctrl+D detected. Exiting LimeSeeker...${NC}" > /dev/tty
    echo -e "${YELLOW}Clearing sudo privileges...${NC}"
    log_event "User exited LimeSeeker via Ctrl+D (EOF)"
    sudo -k
    exit 0
}
    
    # -------
    # Ctrl+Z
    # -------
    handle_sigtstp() {
    echo -e "\n${YELLOW}Ctrl+Z detected. Exiting for security...${NC}" > /dev/tty
    echo -e "${YELLOW}Clearing sudo privileges${NC}" > /dev/tty
    log_event "User attempted to suspend script"
    sudo -k
    exit 1
}

    trap handle_sigtstp SIGTSTP

    local choice status module

    # --------------
    # Module status
    # --------------
    declare -A MODULE_STATUS=(
        [local_inventory]="– not run"
        [local_security]="– not run"
	[system_hardening]="– not run"
        [network_vulnerability]="– not run"
        [wifi]="– not run"
    )

    # --------------
    # Status colors
    # --------------
    status_color() {
        case "$1" in
            "– not run")
                echo -e "${DIM}[ ] not run${NC}"
                ;;
            "✔ done")
                echo -e "[${GREEN}✔${NC}] ${GREEN}done${NC}"
                ;;
            "✖ failed")
                echo -e "[${RED}✖${NC}] ${RED}failed${NC}"
                ;;
            *)
                echo "$1"
                ;;
        esac
    }

# ------------------------------------------
# Owerwrite without prompting per interface
# ------------------------------------------
: "${WIFI_BASELINE_FORCE_OVERWRITE:=0}"


# ------------------------
# Baseline helpers (WiFi)
# ------------------------
wifi_baseline_root() {
    echo "$BASE_DIR/reports/baselines/wifi"
}

wifi_list_baseline_locations() {
    local root
    root="$(wifi_baseline_root)"
    [[ ! -d "$root" ]] && return 0
    find "$root" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | sort
}

wifi_baseline_location_last_updated() {
    local loc="$1"
    local root path
    root="$(wifi_baseline_root)"
    path="$root/$loc"

    [[ ! -d "$path" ]] && { echo ""; return 0; }

    local latest_epoch
    latest_epoch=$(find "$path" -type f -name "*.baseline" -printf "%T@\n" 2>/dev/null | sort -nr | head -n1)
    [[ -z "$latest_epoch" ]] && { echo ""; return 0; }

    latest_epoch=${latest_epoch%.*}
    date -d "@$latest_epoch" "+%Y-%m-%d %H:%M" 2>/dev/null
}

wifi_print_baseline_overview() {
    local root loc
    root="$(wifi_baseline_root)"

    ui_echo "${BOLD}${CYAN}Existing WiFi baselines:${NC}"
    ui_echo "------------------------------------------------------------"

    if [[ ! -d "$root" ]]; then
        ui_echo "${DIM}(none found yet)${NC}"
        return 0
    fi

    local locations
    locations=$(wifi_list_baseline_locations)
    if [[ -z "$locations" ]]; then
        ui_echo "${DIM}(none found yet)${NC}"
        return 0
    fi

    while read -r loc; do
        [[ -z "$loc" ]] && continue

        local ifaces iface_count last iface_line
        ifaces=$(ls -1 "$root/$loc"/*.baseline 2>/dev/null \
            | sed -n 's#.*/##; s/\.baseline$//p' \
            | sort)

        iface_count=$(echo "$ifaces" | sed '/^$/d' | wc -l 2>/dev/null)
        last="$(wifi_baseline_location_last_updated "$loc")"
        [[ -z "$last" ]] && last="unknown"
        iface_line=$(echo "$ifaces" | tr '\n' ' ')

        ui_echo "• ${BOLD}$loc${NC}  ${DIM}(${iface_count} iface)${NC}"
        ui_echo "  ${DIM}Interfaces:${NC} ${iface_line:-none}"
        ui_echo "  ${DIM}Last updated:${NC} $last"
    done <<< "$locations"
}


wifi_prompt_existing_location() {
    local arr=() idx=1 choice loc
    mapfile -t arr < <(wifi_list_baseline_locations)

    if (( ${#arr[@]} == 0 )); then
        ui_echo "${YELLOW}[INFO]${NC} No baselines exist yet."
        echo ""
        return 1
    fi

    ui_echo
    ui_echo "${BOLD}${CYAN}Select baseline location:${NC}"
    for loc in "${arr[@]}"; do
        ui_echo "  $idx) $loc"
        ((idx++))
    done
    ui_echo "  q) Cancel"
    ui_echo

    if ! ui_read -rp "Choose: " choice; then
        echo ""
        return 1
    fi

    case "$choice" in
        q|Q) echo ""; return 1 ;;
        *)
            if [[ "$choice" =~ ^[0-9]+$ ]]; then
                local sel=$((choice-1))
                if (( sel >= 0 && sel < ${#arr[@]} )); then
                    echo "${arr[$sel]}"
                    return 0
                fi
            fi
            ui_echo "${RED}Invalid choice${NC}"
            echo ""
            return 1
            ;;
    esac
}

wifi_prompt_new_location() {
    local newloc root path
    ui_echo
    ui_echo "${BOLD}${CYAN}Create new baseline location${NC}"
    ui_echo "${DIM}Tip: use simple names like home/office/lab${NC}"
    ui_echo
    if ! ui_read -rp "Enter location name: " newloc; then
        echo ""
        return 1
    fi
    newloc="${newloc// /_}"
    [[ -z "$newloc" ]] && { ui_echo "${RED}Invalid location name${NC}"; echo ""; return 1; }

    root="$(wifi_baseline_root)"
    path="$root/$newloc"
    if [[ -d "$path" ]]; then
    ui_echo
    ui_echo "${YELLOW}[INFO]${NC} Location '${BOLD}$newloc${NC}${YELLOW}' already exists."
    ui_echo "${YELLOW}If baseline files exist, you will be asked once whether to overwrite.${NC}"
fi

    echo "$newloc"
    return 0
}
    
# ---------------------------------------
# Delete helper (WiFi baseline location)
# ---------------------------------------
wifi_delete_location() {
    local loc="$1"
    local root path files count

    root="$(wifi_baseline_root)"
    path="$root/$loc"

    [[ -z "$loc" ]] && return 1

    if [[ ! -d "$path" ]]; then
        ui_echo "${YELLOW}[INFO]${NC} Location does not exist: $loc"
        log_to_file "[INFO] Baseline delete: location not found ($loc)"
        return 1
    fi

    mapfile -t files < <(find "$path" -type f 2>/dev/null)
    count="${#files[@]}"

    ui_echo
    ui_echo "${YELLOW}${BOLD}[DRY-RUN] Baseline deletion preview${NC}"
    ui_echo "------------------------------------------------------------"
    ui_echo "${BOLD}Location:${NC} $loc"
    ui_echo "${BOLD}Path:${NC}     $path"
    ui_echo "${BOLD}Files:${NC}    $count"
    ui_echo

    if (( count == 0 )); then
        ui_echo "${DIM}(no files found)${NC}"
    else
        for f in "${files[@]}"; do
            ui_echo "  • ${f#$path/}"
        done
    fi

    ui_echo
    ui_echo "${YELLOW}${BOLD}[WARNING]${NC} This action is irreversible."
    ui_echo "${YELLOW}All files listed above will be permanently deleted.${NC}"
    ui_echo

    if [[ -f "$BASELINE_FILE" && "${WIFI_BASELINE_FORCE_OVERWRITE}" -ne 1 ]]; then
        ui_echo "${YELLOW}${BOLD}[WARNING]${NC} Baseline already exists for: ${BOLD}$LOCATION / $IFACE${NC}"
        ui_echo "${YELLOW}File:${NC} $BASELINE_FILE"
        ui_echo
        ui_read -rp "Overwrite existing baseline(s) for this run? Type YES to confirm: " confirm_overwrite

    if [[ "${confirm_overwrite^^}" != "YES" ]]; then
        ui_echo "${YELLOW}[INFO]${NC} Baseline overwrite cancelled for $LOCATION / $IFACE"
        log_to_file "[INFO] Baseline overwrite cancelled: $LOCATION / $IFACE"
        echo
        continue
    fi

    WIFI_BASELINE_FORCE_OVERWRITE=1
    export WIFI_BASELINE_FORCE_OVERWRITE

    ui_echo "${YELLOW}[INFO]${NC} Overwrite confirmed for this run (no more prompts)"
    log_to_file "[INFO] Baseline overwrite confirmed for this run"
    echo
fi

    rm -rf -- "$path"
    if [[ -d "$path" ]]; then
        ui_echo "${RED}[ERROR]${NC} Failed to delete location: $loc"
        log_to_file "[ERROR] Baseline delete failed ($loc)"
        return 1
    fi

    ui_echo "${GREEN}[OK]${NC} Deleted baseline location: $loc"
    log_to_file "[OK] Deleted baseline location: $loc"
    log_event "Baseline location deleted: $loc"

    return 0
}

# ----------------------
# WiFi baseline manager 
# ----------------------
wifi_baseline_manager() {
    local action loc status

    while true; do
        ui_clear
        ui_echo
        ui_echo "${BOLD}${CYAN}WiFi baseline manager${NC}"
        ui_echo "------------------------------------------------------------"
        ui_status_block
        ui_echo

        wifi_print_baseline_overview

        ui_echo
        ui_echo "${BOLD}${CYAN}Actions:${NC}"
        ui_echo "1) Create baseline (new location)"
        ui_echo "2) Check baseline  (choose existing location)"
        ui_echo "3) Delete location (remove baseline files)"
	ui_echo
        ui_echo "Q) Back to menu"
        ui_echo
	ui_echo

        if ! ui_read -rp "Select option: " action; then
            handle_eof
        fi

        case "$action" in
            1)
                loc="$(wifi_prompt_new_location)"
                [[ -z "$loc" ]] && { sleep 1; continue; }

                log_section "Running module: wifi_baseline_create ($loc)"
                wifi_baseline_create "$loc"
                status=$?
                wifi_set_status "wifi_baseline_create" "$status"

                ui_echo
                if [[ $status -eq 0 ]]; then
                    ui_echo "[${GREEN}✔${NC}] ${GREEN}Baseline created/updated for location: ${BOLD}$loc${NC}"
                    log_event "[OK] WiFi baseline create ($loc)"
                else
                    ui_echo "[${RED}✖${NC}] ${RED}Baseline create failed or cancelled (${BOLD}$loc${NC}${RED})${NC}"
                    log_event "[FAIL] WiFi baseline create ($loc)"
                fi
                ui_echo
                pause
                ;;
            2)
                loc="$(wifi_prompt_existing_location)"
                [[ -z "$loc" ]] && { sleep 1; continue; }

                log_section "Running module: wifi_baseline_check ($loc)"
                wifi_baseline_check "$loc"
                status=$?
                wifi_set_status "wifi_baseline_check" "$status"

                ui_echo
                if [[ $status -eq 0 ]]; then
                    ui_echo "[${GREEN}✔${NC}] ${GREEN}Baseline comparison completed for: ${BOLD}$loc${NC}"
                    log_event "[OK] WiFi baseline check ($loc)"
                else
                    ui_echo "[${RED}✖${NC}] ${RED}Baseline comparison failed for: ${BOLD}$loc${NC}"
                    log_event "[FAIL] WiFi baseline check ($loc)"
                fi
                ui_echo
                pause
                ;;
            3)
                loc="$(wifi_prompt_existing_location)"
                [[ -z "$loc" ]] && { sleep 1; continue; }

                log_section "Baseline delete requested: $loc"
                wifi_delete_location "$loc"
                status=$?

                ui_echo
                if [[ $status -eq 0 ]]; then
                    ui_echo "[${GREEN}✔${NC}] ${GREEN}Deleted baseline location: ${BOLD}$loc${NC}"
                    log_event "[OK] Baseline location deleted ($loc)"
                else
                    ui_echo "[${YELLOW}!${NC}] ${YELLOW}Delete cancelled or failed for: ${BOLD}$loc${NC}"
                    log_event "[INFO] Baseline delete cancelled/failed ($loc)"
                fi
                ui_echo
                pause
                ;;
            q|Q)
                return 0
                ;;
            *)
                ui_echo "${RED}Invalid choice${NC}"
                sleep 1
                ;;
        esac
    done
}

# ------------------
# WiFi module status
# ------------------
declare -A WIFI_STATUS=(
    [wifi_discovery]="– not run"
    [wifi_analysis]="– not run"
    [wifi_history]="– not run"
    [wifi_baseline_create]="– not run"
    [wifi_baseline_check]="– not run"
)

wifi_status_color() {
    case "$1" in
        "– not run") echo -e "${DIM}[ ] not run${NC}" ;;
        "✔ done")    echo -e "[${GREEN}✔${NC}] ${GREEN}done${NC}" ;;
        "✖ failed")  echo -e "[${RED}✖${NC}] ${RED}failed${NC}" ;;
        *)           echo "$1" ;;
    esac
}

wifi_set_status() {
    local key="$1" rc="$2"
    if [[ "$rc" -eq 0 ]]; then
        WIFI_STATUS["$key"]="✔ done"
    else
        WIFI_STATUS["$key"]="✖ failed"
    fi
}

# ---------------------
# WiFi baseline manager
#----------------------
wifi_baseline_manager() {
    local action loc status

    while true; do
        ui_clear
        ui_echo
	ui_echo "${BOLD}${CYAN}_    _ _  _ ____ ____ ____ ____ _  _ ____ ____"
        ui_echo "|    | |\/| |___ [__  |___ |___ |_/  |___ |__/"
        ui_echo "|___ | |  | |___ ___] |___ |___ | \_ |___ |  \ WiFi baseline manager"
        ui_echo "------------------------------------------------------------------------${NC}"
        ui_status_block
        ui_echo

        wifi_print_baseline_overview

        ui_echo
        ui_echo "${BOLD}${CYAN}Actions:${NC}"
        ui_echo "1) Create baseline (new location)"
        ui_echo "2) Check baseline  (compare scan vs baseline)"
	ui_echo "3) Delete baseline (choose location)"
	ui_echo
        ui_echo "Q) Back to menu"
        ui_echo
	ui_echo

        if ! ui_read -rp "Select option: " action; then
            handle_eof
        fi

        case "$action" in
            1)
                loc="$(wifi_prompt_new_location)"
                [[ -z "$loc" ]] && { sleep 1; continue; }

                log_section "Running module: wifi_baseline_create ($loc)"
                wifi_baseline_create "$loc"
                status=$?
                wifi_set_status "wifi_baseline_create" "$status"

                ui_echo
                if [[ $status -eq 0 ]]; then
                    ui_echo "[${GREEN}✔${NC}] ${GREEN}Baseline created/updated for location: ${BOLD}$loc${NC}"
                    log_event "[OK] WiFi baseline create ($loc)"
                else
                    ui_echo "[${RED}✖${NC}] ${RED}Baseline create failed or cancelled (${BOLD}$loc${NC}${RED})${NC}"
                    log_event "[FAIL] WiFi baseline create ($loc)"
                fi
                ui_echo
                pause
                ;;
            2)
                loc="$(wifi_prompt_existing_location)"
                [[ -z "$loc" ]] && { sleep 1; continue; }

                log_section "Running module: wifi_baseline_check ($loc)"
                wifi_baseline_check "$loc"
                status=$?
                wifi_set_status "wifi_baseline_check" "$status"

                ui_echo
                if [[ $status -eq 0 ]]; then
                    ui_echo "[${GREEN}✔${NC}] ${GREEN}Baseline comparison completed for: ${BOLD}$loc${NC}"
                    log_event "[OK] WiFi baseline check ($loc)"
                else
                    ui_echo "[${RED}✖${NC}] ${RED}Baseline comparison failed for: ${BOLD}$loc${NC}"
                    log_event "[FAIL] WiFi baseline check ($loc)"
                fi
                ui_echo
                pause
                ;;
            3)
                loc="$(wifi_prompt_existing_location)"
                [[ -z "$loc" ]] && { sleep 1; continue; }

                log_section "Baseline delete requested: $loc"
                wifi_delete_location "$loc"
                status=$?

                ui_echo
                if [[ $status -eq 0 ]]; then
                    ui_echo "[${GREEN}✔${NC}] ${GREEN}Deleted baseline location: ${BOLD}$loc${NC}"
                    log_event "[OK] Baseline location deleted ($loc)"
                else
                    ui_echo "[${YELLOW}!${NC}] ${YELLOW}Delete cancelled or failed for: ${BOLD}$loc${NC}"
                    log_event "[INFO] Baseline delete cancelled/failed ($loc)"
                fi
                ui_echo
                pause
                ;;
            q|Q)
                return 0
                ;;
            *)
                ui_echo "${RED}Invalid choice${NC}"
                sleep 1
                ;;
        esac
    done
}

# -------------
# WiFi submenu
# -------------
wifi_menu() {
    local wchoice status

    while true; do
        ui_clear
        ui_echo
        ui_echo "${BOLD}${CYAN}        _____ _______ _______ _______ _______ _______ _     _ _______  ______"
        ui_echo " |        |   |  |  | |______ |______ |______ |______ |____/  |______ |_____/"
        ui_echo " |_____ __|__ |  |  | |______ ______| |______ |______ |    \\_ |______ |    \\_"
        ui_echo "        WiFi tools"
        ui_echo "-----------------------------------------------------------------------------${NC}"
        ui_status_block
        ui_echo
        ui_echo "${BOLD}${CYAN}WiFi modules:${NC}"
	ui_echo "1) WiFi discovery    (collect raw scan data)        $(wifi_status_color "${WIFI_STATUS[wifi_discovery]}")"
	ui_echo "2) WiFi analysis     (analyze latest scan)          $(wifi_status_color "${WIFI_STATUS[wifi_analysis]}")"
	ui_echo "3) WiFi history      (compare scan vs previous)     $(wifi_status_color "${WIFI_STATUS[wifi_history]}")"
	ui_echo "4) Scan all modules"
	ui_echo
        ui_echo "${BOLD}${CYAN}Baselines:${NC}"
        ui_echo "5) Baseline manager                                 $(wifi_status_color "${WIFI_STATUS[wifi_baseline_check]}")"
        ui_echo
        ui_echo "Q) Back to main menu"
        ui_echo
	ui_echo

        if ! ui_read -rp "Select option [1-5]: " wchoice; then
            handle_eof
        fi

        status=0

        case "$wchoice" in
            1)
                log_section "Running module: wifi_discovery"
                wifi_discovery
                status=$?
                wifi_set_status "wifi_discovery" "$status"
                ;;
            2)
                log_section "Running module: wifi_analysis"
                wifi_analysis
                status=$?
                wifi_set_status "wifi_analysis" "$status"
                ;;
            3)
                log_section "Running module: wifi_history"
                wifi_history
                status=$?
                wifi_set_status "wifi_history" "$status"
                ;;
            4)
                log_section "Running module: wifi_discovery"
                wifi_discovery
                status=$?
                wifi_set_status "wifi_discovery" "$status"
                if [[ $status -ne 0 ]]; then
                    ui_echo
                    ui_echo "[${RED}✖${NC}] ${RED}WiFi discovery failed${NC}"
                    log_event "[FAIL] WiFi discovery failed"
                    ui_echo
                    pause
                    continue
                fi

                log_section "Running module: wifi_analysis"
                wifi_analysis
                status=$?
                wifi_set_status "wifi_analysis" "$status"
                if [[ $status -ne 0 ]]; then
                    ui_echo
                    ui_echo "[${RED}✖${NC}] ${RED}WiFi analysis failed${NC}"
                    log_event "[FAIL] WiFi analysis failed"
                    ui_echo
                    pause
                    continue
                fi

                log_section "Running module: wifi_history"
                wifi_history
                status=$?
                wifi_set_status "wifi_history" "$status"
                ;;
	    5) 
	        wifi_baseline_manager
    		status=$?
		;;		
            q|Q)
                return 0
                ;;
            *)
                ui_echo "${RED}Invalid choice${NC}"
                sleep 1
                continue
                ;;
        esac

        
        if [[ "$wchoice" != "4" ]]; then
            if [[ $status -eq 0 ]]; then
                ui_echo
                ui_echo "[${GREEN}✔${NC}] ${GREEN}WiFi task completed successfully${NC}"
                log_event "[OK] WiFi task completed successfully"
            else
                ui_echo
                ui_echo "[${RED}✖${NC}] ${RED}WiFi task failed or was aborted${NC}"
                log_event "[FAIL] WiFi task failed or aborted"
            fi
            ui_echo
            pause
        fi
    done
}
    
    # --------------------
    # Reset module status
    # --------------------
    reset_module_status() {
    ui_clear
    ui_echo
    ui_echo "${BOLD}${YELLOW}Reset module status${NC}"
    ui_echo
    ui_echo "This will mark all modules as '${DIM}not run${NC}'."
    ui_echo "Includes WiFi baseline sub-modules."
    ui_echo "No scans will be executed."
    ui_echo "Log files will NOT be deleted."
    ui_echo
    ui_read -rp "Type YES to confirm: " confirm

    if [[ "${confirm,,}" == "yes" ]]; then
        # Reset main menu statuses
        for module in "${!MODULE_STATUS[@]}"; do
            MODULE_STATUS["$module"]="– not run"
        done

        # Reset WiFi menu statuses
        if declare -p WIFI_STATUS &>/dev/null; then
            for k in "${!WIFI_STATUS[@]}"; do
                WIFI_STATUS["$k"]="– not run"
            done
        fi

        ui_echo
        ui_echo "${GREEN}Module status reset successfully.${NC}"
        log_event "Module status reset by user."
        sleep 1
    else
        ui_echo
        ui_echo "${YELLOW}Reset cancelled.${NC}"
        sleep 1
    fi
}

    # -----------------
    # Show module info
    # -----------------
    show_module_info() {
    local module="$1"

    local NAME_VAR="${module}_NAME"
    local DESC_VAR="${module}_DESC"
    local SAFETY_VAR="${module}_SAFETY"

    ui_clear
    ui_echo "${BOLD}${CYAN}_    _ _  _ ____ ____ ____ ____ _  _ ____ ____"
    ui_echo "|    | |\/| |___ [__  |___ |___ |_/  |___ |__/"
    ui_echo "|___ | |  | |___ ___] |___ |___ | \_ |___ |  \ ${!NAME_VAR}"
    ui_echo "------------------------------------------------------------------------${NC}"
    ui_status_block
    ui_echo "${!DESC_VAR}"
    ui_echo

    if [[ -n "${!SAFETY_VAR}" ]]; then
        ui_echo "${YELLOW}${BOLD}Safety notice:${NC}"
        ui_echo "${!SAFETY_VAR}"
        ui_echo
    fi

    ui_read -rp "Press ENTER to return"
}

    # ----------
    # Info menu
    # ----------
    info_menu() {
        local choice module

        while true; do
            ui_clear
            ui_echo
	    ui_echo "${BOLD}${CYAN}        _____ _______ _______ _______ _______ _______ _     _ _______  ______" 
            ui_echo " |        |   |  |  | |______ |______ |______ |______ |____/  |______ |_____/"
            ui_echo " |_____ __|__ |  |  | |______ ______| |______ |______ |    \_ |______ |    \_"
            ui_echo "        Module information"
	    ui_echo "-----------------------------------------------------------------------------${NC}"
	    ui_status_block
            ui_echo
	    ui_echo
	    ui_echo "${BOLD}${CYAN}Modules:${NC}"
            ui_echo "1) Local inventory"
            ui_echo "2) Local security"
	    ui_echo "3) System hardening"
            ui_echo "4) Network vulnerability"
            ui_echo "5) WiFi discovery"
	    ui_echo
            ui_echo "Q) Back to main menu"
            ui_echo
	    ui_echo

            ui_read -rp "Select option: " choice

            case "$choice" in
                1) module="local_inventory" ;;
                2) module="local_security" ;;
		3) module="system_hardening" ;;
                4) module="network_vulnerability" ;;
                5) module="wifi_discovery" ;;
		q|Q) return ;;
                *) ui_echo "${RED}Invalid choice${NC}"; sleep 1; continue ;;
            esac

            show_module_info "$module"
        done
    }

    

    # --------------
    # Module choice
    # --------------
    show_intro

    while true; do
        modules_to_run=() 
	ui_clear
	show_intro
	log_pause
        ui_echo "${BOLD}${CYAN}Hardware, OS & Network Analysis:${NC}"
        ui_echo "1) Local inventory              $(status_color "${MODULE_STATUS[local_inventory]}")"
        ui_echo "2) Local security               $(status_color "${MODULE_STATUS[local_security]}")"
	ui_echo "3) System hardening             $(status_color "${MODULE_STATUS[system_hardening]}")"
        ui_echo "4) Network vulnerability        $(status_color "${MODULE_STATUS[network_vulnerability]}")"
        ui_echo "5) Scan all modules"
	ui_echo
	ui_echo "${BOLD}${CYAN}WiFi Analysis:${NC}" 
	ui_echo "6) WiFi tools"
        ui_echo
	ui_echo
	ui_echo "${BOLD}${CYAN}Options:${NC}"
        ui_echo "i) Module information"
        ui_echo "c) Clear module status"
	ui_echo
        ui_echo "Q) Quit"
        ui_echo
	ui_echo
        
	if ! ui_read -rp "Select option [1-6]: " choice; then 
		handle_eof
        fi 

        case "$choice" in
		1) modules_to_run=(local_inventory) ;;
                2) modules_to_run=(local_security) ;;
		3) modules_to_run=(system_hardening) ;;
                4) modules_to_run=(network_vulnerability) ;;
		5) modules_to_run=(local_inventory local_security system_hardening network_vulnerability);;
		6)
			wifi_menu
			continue
			;;
     
   	        i|I) 
			 info_menu 
			 continue
			 ;;
                c|C) 
			 reset_module_status 
			 continue
			 ;;
                q|Q)
			 ui_echo "${YELLOW}Exiting LimeSeeker...${NC}"
		         ui_echo "${YELLOW}Clearing sudo privileges...${NC}"
			 log_footer
                         log_event "User exited LimeSeeker"
                         sudo -k
                         return 0
                         ;;
                *) ui_echo "${RED}Invalid choice${NC}"; sleep 1; continue ;;
        esac

         for module in "${modules_to_run[@]}"; do
		 log_section "Running module: $module"
		 $module
                 status=$?

         if [[ $status -eq 0 ]]; then
                 MODULE_STATUS["$module"]="✔ done"
                 ui_echo
                 ui_echo "[${GREEN}✔${NC}] ${GREEN}${module//_/ } completed successfully${NC}"
                 log_event "[OK] $module completed successfully"
         else
                  MODULE_STATUS["$module"]="✖ failed"
                  ui_echo
                  ui_echo "[${RED}✖${NC}] ${RED}${module//_/ } failed or was aborted${NC}"
                  log_event "[FAIL] $module failed or aborted"
         fi
        done

        ui_echo
        pause
done
}
