#!/bin/bash
# Brightness control script

STEP=5%

case "$1" in
    --inc)
        brightnessctl set +${STEP}
        ;;
    --dec)
        brightnessctl set ${STEP}-
        ;;
    --get)
        brightnessctl get
        ;;
    *)
        echo "Usage: $0 [--inc|--dec|--get]"
        ;;
esac
