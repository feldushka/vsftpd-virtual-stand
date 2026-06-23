#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"
TARGET_USER="sftp_weak"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") sftp-chroot-mitigate: $1" >> ${LOG_FILE}
}

read -r INPUT
SRC_IP=$(echo "$INPUT" | grep -oP '"srcip":"\K[^"]+')
FILE_PATH=$(echo "$INPUT" | grep -oP '"file":"\K[^"]+')

log "Chroot escape mitigation triggered"

if [ -f "$FILE_PATH" ] && [[ "$FILE_PATH" == /home/${TARGET_USER}/jail/* ]]; then
    sudo rm -f "$FILE_PATH"
    log "Malicious shell binary ${FILE_PATH} removed from jail"
fi

sudo pkill -9 -u "$TARGET_USER"
log "Terminated all active sessions for user ${TARGET_USER}"

if [ -n "$SRC_IP" ]; then
    sudo iptables -I INPUT -p tcp -s "${SRC_IP}" --dport 22 -j DROP
    log "Blocked attacker IP ${SRC_IP} on port 22"
fi

exit 0
