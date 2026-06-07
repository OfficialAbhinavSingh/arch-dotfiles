#!/bin/bash
# WaybarScripts - launcher helper

case "$1" in
    --term)
        kitty &
        ;;
    --files)
        dolphin &
        ;;
    --btop)
        kitty --title btop btop &
        ;;
    --nvtop)
        kitty --title nvtop nvtop &
        ;;
    --nmtui)
        kitty --title nmtui nmtui &
        ;;
    *)
        echo "Usage: $0 [--term|--files|--btop|--nvtop|--nmtui]"
        ;;
esac
