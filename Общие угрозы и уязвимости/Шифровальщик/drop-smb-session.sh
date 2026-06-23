#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") drop-smb-session: $1" >> ${LOG_FILE}
}

log "Active Response triggered"

read -r INPUT
SRC_IP=$(echo "$INPUT" | grep -oP '"srcip":"\K[^"]+')

if [ -z "$SRC_IP" ]; then
    log "Error: Failed to extract srcip from JSON"
    exit 1
fi

log "Target attack IP detected: ${SRC_IP}"

SMBD_PIDS=$(smbstatus -p 2>/dev/null | grep "(${SRC_IP})" | awk '{print $1}')

if [ -z "$SMBD_PIDS" ]; then
    log "No active Samba sessions found for IP ${SRC_IP}"
    exit 0
fi

for pid in ${SMBD_PIDS}; do
    if kill -0 "$pid" 2>/dev/null; then
        log "Terminating smbd process with PID ${pid}"
        sudo kill -9 "$pid"
    fi
done

log "Mitigation completed for IP ${SRC_IP}"
exit 0
