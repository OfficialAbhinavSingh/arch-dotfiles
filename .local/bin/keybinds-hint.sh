#!/bin/bash
# ⌨️ Hyprland Keybind Cheatsheet

config_file="$HOME/.config/hypr/hyprland.conf"

# Extract binds and comments
cheatsheet=$(grep -E '^bind|^# ──' "$config_file" | \
    sed 's/^bind = //g' | \
    sed 's/^# ── //g' | \
    sed 's/ ──.*//g')

echo "$cheatsheet" | rofi -dmenu -i -p "Keybinds" -config ~/.config/rofi/config.rasi
