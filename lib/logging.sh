#!/usr/bin/env bash

LOG_DIR="$HOME/.limeseeker/reports"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/scan_$(date +%F_%H-%M-%S).log"

log() {
    echo -e "[$(date +%T)] $1" | tee -a "$LOG_FILE"
}

