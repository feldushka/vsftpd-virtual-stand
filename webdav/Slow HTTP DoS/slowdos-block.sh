#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") slowdos-block: $1" >> ${LOG_FILE}
}

read -r INPUT
ACTION=$(echo "$INPUT" | grep -oP '"action":"\K[^"]+')
SRC_IP=$(echo "$INPUT" | grep -oP '"srcip":"\K[^"]+')

if [ -z "$SRC_IP" ] || [ -z "$ACTION" ]; then
    log "Error: Missing parameters in JSON input"
    exit 1
fi

if [ "$ACTION" = "add" ]; then
    log "Mitigating Slow HTTP DoS: Blocking IP ${SRC_IP} on HTTP/HTTPS ports"
    sudo iptables -I INPUT -p tcp -s "${SRC_IP}" --dport 80 -j DROP
    sudo iptables -I INPUT -p tcp -s "${SRC_IP}" --dport 443 -j DROP
elif [ "$ACTION" = "delete" ]; then
    log "Timeout reached: Unblocking IP ${SRC_IP} on HTTP/HTTPS ports"
    sudo iptables -D INPUT -p tcp -s "${SRC_IP}" --dport 80 -j DROP
    sudo iptables -D INPUT -p tcp -s "${SRC_IP}" --dport 443 -j DROP
fi

exit 0
