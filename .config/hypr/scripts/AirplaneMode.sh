#!/bin/bash
# Toggle airplane mode (blocks/unblocks all wireless via rfkill)

if rfkill list all | grep -q "Soft blocked: yes"; then
    rfkill unblock all
    notify-send "Airplane Mode" "Disabled — wireless restored" --icon network-wireless -t 3000
else
    rfkill block all
    notify-send "Airplane Mode" "Enabled — all wireless blocked" --icon airplane-mode -t 3000
fi
