#!/usr/bin/env bash
# Run as root after installing the catppuccin SDDM package:
#   sudo pacman -U ~/.cache/yay/catppuccin-sddm-theme-mocha/catppuccin-sddm-theme-mocha-1.1.2-1-any.pkg.tar.zst
#   sudo bash ~/.config/hypr/scripts/setup_sddm_theme.sh

set -e

THEME_NAME="catppuccin-mocha-mauve"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"
WALLPAPER="/home/laterabhi/Pictures/wallpapers/anime/japan-purple-blur.png"

if [ ! -d "$THEME_DIR" ]; then
    echo "ERROR: Theme directory not found: $THEME_DIR"
    echo "Install the package first: sudo pacman -U ~/.cache/yay/catppuccin-sddm-theme-mocha/catppuccin-sddm-theme-mocha-1.1.2-1-any.pkg.tar.zst"
    exit 1
fi

# Create sddm config directory
mkdir -p /etc/sddm.conf.d

# Set the active SDDM theme
cat > /etc/sddm.conf.d/theme.conf << EOF
[Theme]
Current=${THEME_NAME}
EOF

# Copy wallpaper into theme backgrounds so it's readable at login
cp "${WALLPAPER}" "${THEME_DIR}/backgrounds/wall.png"

# Write theme user overrides
cat > "${THEME_DIR}/theme.conf.user" << 'EOF'
[General]
Font="JetBrains Mono Nerd Font"
FontSize=10
ClockEnabled="true"
CustomBackground="true"
LoginBackground="false"
Background="backgrounds/wall.png"
UserIcon="false"
EOF

echo ""
echo "Done! SDDM will use: ${THEME_NAME}"
echo "Wallpaper: ${WALLPAPER}"
echo "Restart SDDM to see changes: sudo systemctl restart sddm"
echo "(Note: restarting SDDM will drop your current session)"
