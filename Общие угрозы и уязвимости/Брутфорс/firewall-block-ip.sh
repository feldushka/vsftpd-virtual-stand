#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") firewall-block-ip: $1" >> ${LOG_FILE}
}

log "Active Response triggered"

read -r INPUT
ACTION=$(echo "$INPUT" | grep -oP '"action":"\K[^"]+')
SRC_IP=$(echo "$INPUT" | grep -oP '"srcip":"\K[^"]+')

if [ -z "$SRC_IP" ] || [ -z "$ACTION" ]; then
    log "Error: Failed to extract parameters from JSON"
    exit 1
fi

if [ "$ACTION" = "add" ]; then
    log "Adding firewall drop rule for IP: ${SRC_IP}"
    sudo iptables -I INPUT -s "${SRC_IP}" -j DROP
elif [ "$ACTION" = "delete" ]; then
    log "Removing firewall drop rule for IP: ${SRC_IP}"
    sudo iptables -D INPUT -s "${SRC_IP}" -j DROP
fi

log "Mitigation task executed successfully"
exit 0
