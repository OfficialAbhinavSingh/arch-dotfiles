#!/usr/bin/env bash
# Fired by hl.on("monitor.added", ...) in monitors.lua for every newly
# connected output. Laptop panels are skipped. For anything else:
#   1. Force a DPMS off/on cycle after a short settle delay. Hyprland can
#      report the output connected + dpmsStatus:1 while the physical panel
#      never actually lit (observed on this hybrid-GPU laptop's HDMI port,
#      wired to the dGPU: nvidia-modeset logs "Unable to read EDID" on the
#      first hotplug probe even though a later probe succeeds). A cycle
#      forces a fresh modeset instead of trusting the stale reported state.
#   2. Ask (rofi) whether the monitor sits left or right of the laptop and
#      position it there live via `hyprctl eval`, so the answer doesn't
#      depend on which physical port or which monitor was plugged in.
set -euo pipefail

OUT="${1:?usage: monitor-side-prompt.sh <output-name>}"

case "$OUT" in
    eDP-1|eDP-2) exit 0 ;;
esac

LAPTOP_W=1920

# Let the hotplug settle (EDID/mode probing) before touching DPMS or asking.
sleep 1

hyprctl eval "hl.dispatch(hl.dsp.dpms(\"off\", \"$OUT\"))" >/dev/null 2>&1 || true
sleep 0.3
hyprctl eval "hl.dispatch(hl.dsp.dpms(\"on\", \"$OUT\"))" >/dev/null 2>&1 || true

choice=$(printf 'Left\nRight\n' | rofi -dmenu -p "$OUT: left or right of the laptop?")

case "$choice" in
    Left)  POS="-${LAPTOP_W}x0" ;;
    Right) POS="${LAPTOP_W}x0" ;;
    *) exit 0 ;;
esac

hyprctl eval "hl.monitor({ output = \"$OUT\", mode = \"preferred\", position = \"$POS\", scale = 1 })" >/dev/null

hyprctl notify -1 3000 "rgb(89dceb)" "$OUT placed $choice of laptop"
