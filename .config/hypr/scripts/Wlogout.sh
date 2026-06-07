#!/bin/bash
# Wlogout launcher
if command -v wlogout &>/dev/null; then
    wlogout &
else
    # fallback
    hyprctl dispatch exit
fi
