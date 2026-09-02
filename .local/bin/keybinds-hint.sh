#!/bin/bash
# ⌨️ Hyprland Keybind Cheatsheet
# Parses hyprland.lua via hypr-cheatsheet.py (config went hyprlang -> lua, 2026-08-14)

python3 "$HOME/.local/bin/hypr-cheatsheet.py" | \
    rofi -dmenu -i -p "Keybinds" -config ~/.config/rofi/config.rasi
