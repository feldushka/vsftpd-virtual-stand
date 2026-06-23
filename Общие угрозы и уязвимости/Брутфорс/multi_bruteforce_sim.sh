#!/bin/bash

TARGET_IP="IP_МАШИНЫ_2"
TARGET_USER="vasya"

if [ -z "$TARGET_IP" ]; then
    exit 1
fi

brute_samba() {
    for i in {1..10}; do
        smbclient //${TARGET_IP}/PublicShare -U ${TARGET_USER}%WrongPass${i} -c "ls" 2>/dev/null
        sleep 0.3
    done
}

brute_sftp() {
    for i in {1..10}; do
        sshpass -p "WrongPass${i}" sftp -oStrictHostKeyChecking=no ${TARGET_USER}@${TARGET_IP} 2>/dev/null
        sleep 0.3
    done
}

brute_vsftpd() {
    for i in {1..10}; do
        curl -u "${TARGET_USER}:WrongPass${i}" ftp://${TARGET_IP}/ 2>/dev/null
        sleep 0.3
    done
}

brute_webdav() {
    for i in {1..10}; do
        curl -i -u "${TARGET_USER}:WrongPass${i}" http://${TARGET_IP}/webdav/ 2>/dev/null
        sleep 0.3
    done
}

if [ "$1" == "samba" ]; then brute_samba;
elif [ "$1" == "sftp" ]; then brute_sftp;
elif [ "$1" == "vsftpd" ]; then brute_vsftpd;
elif [ "$1" == "webdav" ]; then brute_webdav;
else
    brute_samba
    brute_sftp
    brute_vsftpd
    brute_webdav
fi

exit 0
