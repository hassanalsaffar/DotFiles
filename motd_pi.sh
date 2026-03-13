#!/bin/bash

# --- Colors ---
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
GRAY='\e[90m'
RESET='\e[0m'

# --- Config ---
WIDTH=78
BORDER_COLOR=$RED
LABEL_COLOR=$YELLOW
TEXT_COLOR=$CYAN

# --- Helper Functions ---

draw_bar() {
    local percentage=$1
    local bar_width=20
    local filled=$(( (percentage * bar_width) / 100 ))
    local empty=$(( bar_width - filled ))
    
    local color=$GREEN
    if [ $percentage -gt 80 ]; then color=$RED; elif [ $percentage -gt 50 ]; then color=$YELLOW; fi

    printf "["
    printf "${color}"
    for ((i=0; i<filled; i++)); do printf "┃"; done
    printf "${GRAY}"
    for ((i=0; i<empty; i++)); do printf " "; done
    printf "${RESET}] %3d%%" "$percentage"
}

sec2time() {
    local T=$1
    local D=$((T/86400)); local H=$((T/3600%24)); local M=$((T/60%60))
    local d_s="s"; [[ $D -eq 1 ]] && d_s=""
    local h_s="s"; [[ $H -eq 1 ]] && h_s=""
    local m_s="s"; [[ $M -eq 1 ]] && m_s=""
    echo "$D day$d_s, $H hour$h_s, $M minute$m_s"
}

# --- Data Gathering ---
ME=$(whoami)
DATE_NOW=$(date +"%A, %d %B %Y, %T")
UP_SEC=$(cut -d "." -f 1 /proc/uptime)
BOOT_TIME=$(date -d "@$(grep btime /proc/stat | cut -d ' ' -f 2)" +"%d-%m-%Y %H:%M:%S")

MEM_INFO=$(free | awk 'NR==2{printf "%d %d", $3, $2}')
MEM_USED=$(echo $MEM_INFO | cut -d' ' -f1)
MEM_TOTAL=$(echo $MEM_INFO | cut -d' ' -f2)
MEM_PERC=$(( MEM_USED * 100 / MEM_TOTAL ))

DISK_PERC=$(df -h ~ | awk 'NR==2 {print $5}' | tr -d '%')
DISK_INFO=$(df -h ~ | awk 'NR==2 {printf "Used: %s / Total: %s", $3, $2}')

if command -v vcgencmd >/dev/null; then
    TEMP=$(vcgencmd measure_temp | grep -oP '\d+\.\d+')
else
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000}')
fi
TEMP_ROUND=${TEMP%.*}
TEMP_PERC=$(( TEMP_ROUND * 100 / 85 ))

# --- Drawing ---
clear

# Top Border (No vertical bar at the end)
printf "${BORDER_COLOR}┏$(printf '━%.0s' $(seq 1 $WIDTH))┓${RESET}\n\n"

# Logo
printf "${GREEN}%-28s${RESET}\n" "          .~~.   .~~."
printf "${GREEN}%-28s${RESET}\n" "         '. \ ' ' / .'"
printf "${RED}%-28s %-50s${RESET}\n" "          .~ .~~~..~.                _                        _     " ""
printf "${RED}%-28s %-50s${RESET}\n" "         : .~.'~'.~. :    ___ ___ ___ ___| |_ ___ ___ ___ _ _    ___|_|    " ""
printf "${RED}%-28s %-50s${RESET}\n" "          ~ (   ) (   ) ~   |  _| .'|_ -| . | . | -_|  _|  _| | |  | . | |    " ""
printf "${RED}%-28s %-50s${RESET}\n" "         ( : '~'.~.'~' : )  |_| |__,|___|  _|___|___|_| |_| |_  |  |  _|_|    " ""
printf "${RED}%-28s %-50s${RESET}\n" "          ~ .~ (   ) ~. ~               |_|                  |___|  |_|          " ""

echo -e "\n"

# Greetings (Centered)
GREET="Welcome back, $ME!"
printf "%$(( (WIDTH - ${#GREET}) / 2 ))s${TEXT_COLOR}%s${RESET}\n" "" "$GREET"
printf "%$(( (WIDTH - ${#DATE_NOW}) / 2 ))s${TEXT_COLOR}%s${RESET}\n" "" "$DATE_NOW"

echo -e "\n"

# Stats Section
printf "  ${LABEL_COLOR}%-16s${RESET} %s\n" "Uptime:" "$(sec2time $UP_SEC)"
printf "  ${LABEL_COLOR}%-16s${RESET} %s\n" "Booted:" "$BOOT_TIME"
echo ""
printf "  ${LABEL_COLOR}%-16s${RESET} %-25s %-33s\n" "Memory usage:" "$(draw_bar $MEM_PERC)" "$((MEM_USED/1024))MB / $((MEM_TOTAL/1024))MB"
printf "  ${LABEL_COLOR}%-16s${RESET} %-25s %-33s\n" "Disk usage:" "$(draw_bar $DISK_PERC)" "$DISK_INFO"
printf "  ${LABEL_COLOR}%-16s${RESET} %-25s %-33s\n" "Temperature:" "$(draw_bar $TEMP_PERC)" "${TEMP}ºC"

echo -e "\n"

# Bottom Border (No vertical bar at the end)
printf "${BORDER_COLOR}┗$(printf '━%.0s' $(seq 1 $WIDTH))┛${RESET}\n"
