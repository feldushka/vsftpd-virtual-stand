#!/bin/bash

TARGET_DIR="/mnt/target_share"

if [ ! -d "$TARGET_DIR" ] || [ -z "$(ls -A $TARGET_DIR)" ]; then
    exit 1
fi

for file in "$TARGET_DIR"/*.txt; do
    [ -e "$file" ] || continue
    mv "$file" "${file}.locked" 2>/dev/null
    if [ $? -ne 0 ]; then
        break
    fi
    sleep 0.2
done

exit 0
