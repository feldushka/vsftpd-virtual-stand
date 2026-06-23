#!/bin/bash

TARGET_IP="IP_МАШИНЫ_2"
TARGET_USER="vasya"

if [ -z "$TARGET_IP" ]; then
    exit 1
fi

for i in {1..10}; do
    smbclient //${TARGET_IP}/PublicShare -U ${TARGET_USER}%WrongPassword${i} -c "ls" 2>/dev/null
    sleep 0.5
done

exit 0
