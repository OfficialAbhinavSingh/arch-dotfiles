#!/bin/bash
# Hyprsunset night light toggle

PIDFILE="/tmp/hyprsunset.pid"
TEMP="${HYPRSUNSET_TEMP:-3500}"

case "$1" in
    status)
        if [ -f "$PIDFILE" ] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
            echo '{"text": "󰛨", "tooltip": "Night light ON", "class": "active"}'
        else
            echo '{"text": "󰌶", "tooltip": "Night light OFF", "class": ""}'
        fi
        ;;
    toggle)
        if [ -f "$PIDFILE" ] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
            kill "$(cat $PIDFILE)" 2>/dev/null
            rm -f "$PIDFILE"
        else
            hyprsunset -t "$TEMP" &
            echo $! > "$PIDFILE"
        fi
        ;;
    *)
        echo "Usage: $0 [status|toggle]"
        ;;
esac
