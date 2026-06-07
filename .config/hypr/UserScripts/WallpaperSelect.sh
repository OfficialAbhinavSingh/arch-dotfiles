#!/bin/bash
# WallpaperSelect stub - opens a file picker or fzf to choose wallpaper
if command -v fzf &>/dev/null; then
    wall=$(find ~/Pictures/Wallpapers -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null | fzf --preview 'echo {}')
    if [ -n "$wall" ]; then
        hyprctl hyprpaper unload all
        hyprctl hyprpaper preload "$wall"
        hyprctl hyprpaper wallpaper ",$wall"
    fi
else
    echo "Install fzf for wallpaper picker, or set wall manually"
fi
