#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") webshell-mitigate: $1" >> ${LOG_FILE}
}

read -r INPUT
SRC_IP=$(echo "$INPUT" | grep -oP '"srcip":"\K[^"]+')
FILE_PATH=$(echo "$INPUT" | grep -oP '"file":"\K[^"]+')

if [ -z "$SRC_IP" ] || [ -z "$FILE_PATH" ]; then
    log "Error: Missing parameters in JSON input"
    exit 1
fi

log "Mitigating Web Shell. Attacker IP: ${SRC_IP}, File: ${FILE_PATH}"

if [ -f "$FILE_PATH" ] && [[ "$FILE_PATH" == /var/www/html/webdav/* ]]; then
    sudo rm -f "$FILE_PATH"
    log "Malicious file ${FILE_PATH} successfully deleted"
fi

sudo iptables -I INPUT -p tcp -s "${SRC_IP}" --dport 80 -j DROP
sudo iptables -I INPUT -p tcp -s "${SRC_IP}" --dport 443 -j DROP
log "Blocked attacker IP ${SRC_IP} on web ports"

exit 0
