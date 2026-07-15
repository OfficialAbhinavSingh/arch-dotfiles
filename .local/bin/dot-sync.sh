#!/bin/bash
# Update package lists
pacman -Qqe > ~/pkglist.txt
yay -Qqe > ~/aurlist.txt

# Alias for dot command
dot="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Add, commit, and push
$dot add ~/pkglist.txt ~/aurlist.txt
$dot commit -m "Update package lists and configs: $(date)"
$dot push origin main
