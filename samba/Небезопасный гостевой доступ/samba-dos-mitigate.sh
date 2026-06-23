#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"
SHARE_DIR="/home/vsftpd/smb_share"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") samba-dos-mitigate: $1" >> ${LOG_FILE}
}

read -r INPUT
SRC_IP=$(echo "$INPUT" | grep -oP '"srcip":"\K[^"]+')

log "Storage mitigation triggered"

if [ -d "$SHARE_DIR" ]; then
    log "Searching and purging heavy guest payload files in ${SHARE_DIR}"
    find "$SHARE_DIR" -type f -size +10M -user nobody -delete
    log "Anonymous heavy files removed successfully"
fi

if [ -n "$SRC_IP" ]; then
    log "Blocking attacker IP ${SRC_IP} via iptables"
    sudo iptables -I INPUT -p tcp -s "${SRC_IP}" --dport 445 -j DROP
fi

exit 0
