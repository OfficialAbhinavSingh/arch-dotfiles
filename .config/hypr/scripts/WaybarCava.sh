#!/bin/bash
# WaybarCava - cava music visualizer for waybar
# requires: cava
# Outputs characters representing audio bars

if ! command -v cava &>/dev/null; then
    echo ""
    exit 0
fi

cava_config="$HOME/.config/cava/waybar_config"

if [ ! -f "$cava_config" ]; then
    mkdir -p "$HOME/.config/cava"
    cat > "$cava_config" << 'EOF'
[general]
bars = 10
bar_width = 1
bar_spacing = 0
framerate = 30
sensitivity = 100

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF
fi

cava -p "$cava_config" | while read -r line; do
    # Convert numbers to block characters
    output=""
    for char in $line; do
        case $char in
            0) output="${output}▁" ;;
            1) output="${output}▂" ;;
            2) output="${output}▃" ;;
            3) output="${output}▄" ;;
            4) output="${output}▅" ;;
            5) output="${output}▆" ;;
            6) output="${output}▇" ;;
            7) output="${output}█" ;;
            *) output="${output} " ;;
        esac
    done
    echo "$output"
done
