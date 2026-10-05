#!/bin/bash

data_dir="$(dirname "$(readlink -f "$0")")/../data"
file_path="$data_dir/last_charged.txt"

if rg -q '^1$' /sys/class/power_supply/*/online; then
    exit 0
fi

date +%s > "$file_path"
chmod 644 "$file_path"
