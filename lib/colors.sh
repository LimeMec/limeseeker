#!/usr/bin/env bash

# ----------------
#  Colors terminal
#  ---------------
if [[ -t 1 || -t 2 || -e /dev/tty ]]; then
    RED="\e[31m"
    GREEN="\e[32m"
    YELLOW="\e[33m"
    BLUE="\e[34m"
    MAGENTA="\e[35m"
    CYAN="\e[36m"
    BOLD="\e[1m"
    DIM="\e[2m"
    NC="\e[0m"

else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    MAGENTA=""
    CYAN=""
    BOLD=""
    NC=""
fi

