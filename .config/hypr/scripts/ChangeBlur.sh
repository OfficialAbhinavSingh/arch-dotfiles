#!/bin/bash
# ChangeBlur stub
hyprctl keyword decoration:blur:enabled toggle 2>/dev/null || echo "blur toggle not supported"
