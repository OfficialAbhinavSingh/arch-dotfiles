#!/bin/bash
# 🛠️ Arch Linux Maintenance Script

# 1. Update system packages
echo "📦 Updating system..."
yay -Syu --noconfirm

# 2. Cleanup Pacman cache (keep 2 versions)
echo "🧹 Cleaning Pacman cache..."
sudo paccache -rk2

# 3. Cleanup AUR cache
echo "🧹 Cleaning Yay cache..."
yay -Sc --noconfirm

# 4. Sync Dotfiles to GitHub
echo "🚀 Syncing dotfiles..."
if [ -f ~/.local/bin/dot-sync.sh ]; then
    bash ~/.local/bin/dot-sync.sh
fi

# 5. Notify completion
notify-send "System Maintenance" "Maintenance completed successfully!" -i system-software-update
echo "✅ Done!"
