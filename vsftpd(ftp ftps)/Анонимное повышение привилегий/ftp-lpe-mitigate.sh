#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"
BACKUP_DIR="/var/backups/secure_scripts"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") ftp-lpe-mitigate: $1" >> ${LOG_FILE}
}

read -r INPUT
SRC_IP=$(echo "$INPUT" | grep -oP '"srcip":"\K[^"]+')
FILE_PATH=$(echo "$INPUT" | grep -oP '"file":"\K[^"]+')

log "FTP LPE mitigation triggered"

if [ -f "$FILE_PATH" ] && [[ "$FILE_PATH" == /var/ftp/incoming/scripts/* ]]; then
    FILENAME=$(basename "$FILE_PATH")
    sudo rm -f "$FILE_PATH"
    log "Poisoned script ${FILE_PATH} removed"
    
    if [ -f "${BACKUP_DIR}/${FILENAME}" ]; then
        sudo cp "${BACKUP_DIR}/${FILENAME}" "$FILE_PATH"
        sudo chown root:root "$FILE_PATH"
        sudo chmod 755 "$FILE_PATH"
        log "Legitimate script restored from backup repository"
    fi
fi

if [ -n "$SRC_IP" ]; then
    sudo iptables -I INPUT -p tcp -s "${SRC_IP}" --dport 21 -j DROP
    log "Blocked attacker IP ${SRC_IP} on FTP port 21"
fi

exit 0
