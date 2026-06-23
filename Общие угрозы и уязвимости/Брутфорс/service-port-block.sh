#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") service-port-block: $1" >> ${LOG_FILE}
}

read -r INPUT
ACTION=$(echo "$INPUT" | grep -oP '"action":"\K[^"]+')
SRC_IP=$(echo "$INPUT" | grep -oP '"srcip":"\K[^"]+')
RULE_ID=$(echo "$INPUT" | grep -oP '"id":"\K[^"]+')

if [ -z "$SRC_IP" ] || [ -z "$ACTION" ] || [ -z "$RULE_ID" ]; then
    log "Error: Missing parameters in JSON input"
    exit 1
fi

case "$RULE_ID" in
    "100210") PORT="445" ;;
    "100211") PORT="22"  ;;
    "100212") PORT="21"  ;;
    "100213") PORT="80,443" ;;
    *) PORT="0" ;;
    esac

if [ "$PORT" = "0" ]; then
    log "Error: Unknown rule ID ${RULE_ID}"
    exit 1
fi

IFS=',' read -ra PORTS <<< "$PORT"

if [ "$ACTION" = "add" ]; then
    log "Blocking IP ${SRC_IP} on port(s) ${PORT}"
    for p in "${PORTS[@]}"; do
        sudo iptables -I INPUT -p tcp -s "${SRC_IP}" --dport "$p" -j DROP
    done
elif [ "$ACTION" = "delete" ]; then
    log "Unblocking IP ${SRC_IP} on port(s) ${PORT}"
    for p in "${PORTS[@]}"; do
        sudo iptables -D INPUT -p tcp -s "${SRC_IP}" --dport "$p" -j DROP
    done
fi

exit 0
