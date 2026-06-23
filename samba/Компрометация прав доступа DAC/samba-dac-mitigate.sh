#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"
TARGET_FILE="/etc/samba/smb.conf"

log() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") samba-dac-mitigate: $1" >> ${LOG_FILE}
}

read -r INPUT
FILE_PATH=$(echo "$INPUT" | grep -oP '"file":"\K[^"]+')

log "DAC integrity violation mitigation triggered"

if [ "$FILE_PATH" = "$TARGET_FILE" ] && [ -f "$TARGET_FILE" ]; then
    log "Restoring secure permissions (644) and root ownership on ${TARGET_FILE}"
    sudo chown root:root "$TARGET_FILE"
    sudo chmod 644 "$TARGET_FILE"
    
    if grep -q "root preexec" "$TARGET_FILE"; then
        log "Warning: Malicious 'root preexec' directive found! Cleaning configuration file..."
        sudo sed -i '/root preexec/d' "$TARGET_FILE"
        sudo systemctl reload smbd
    fi
    log "Configuration integrity successfully restored"
fi

exit 0
