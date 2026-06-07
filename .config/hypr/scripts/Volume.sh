#!/bin/bash
# Volume control script

STEP=5

get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%'
}

get_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

case "$1" in
    --inc)
        pactl set-sink-volume @DEFAULT_SINK@ +${STEP}%
        ;;
    --dec)
        pactl set-sink-volume @DEFAULT_SINK@ -${STEP}%
        ;;
    --toggle)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    --toggle-mic)
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        ;;
    --mic-inc)
        pactl set-source-volume @DEFAULT_SOURCE@ +${STEP}%
        ;;
    --mic-dec)
        pactl set-source-volume @DEFAULT_SOURCE@ -${STEP}%
        ;;
    --get)
        echo "$(get_volume)"
        ;;
    *)
        echo "Usage: $0 [--inc|--dec|--toggle|--toggle-mic|--mic-inc|--mic-dec|--get]"
        ;;
esac
