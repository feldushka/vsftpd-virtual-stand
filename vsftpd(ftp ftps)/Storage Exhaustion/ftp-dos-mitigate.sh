#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"
FTP_INCOMING="/var/ftp/incoming"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") ftp-dos-mitigate: $1" >> ${LOG_FILE}
}

read -r INPUT
SRC_IP=$(echo "$INPUT" | grep -oP '"srcip":"\K[^"]+')

log "FTP storage mitigation triggered"

if [ -d "$FTP_INCOMING" ]; then
    log "Searching and purging anonymous files larger than 10M in ${FTP_INCOMING}"
    find "$FTP_INCOMING" -type f -size +10M -user ftp -delete 2>/dev/null
    find "$FTP_INCOMING" -type f -size +10M -user nobody -delete 2>/dev/null
    log "Space reclaimed successfully"
fi

if [ -n "$SRC_IP" ]; then
    sudo iptables -I INPUT -p tcp -s "${SRC_IP}" --dport 21 -j DROP
    log "Blocked attacker IP ${SRC_IP} on port 21"
fi

exit 0
