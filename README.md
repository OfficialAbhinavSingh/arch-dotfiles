# Arch Linux Laptop Dotfiles

Personal configuration files for my Arch Linux laptop, primarily for Hyprland on Wayland. These files reflect one machine and are a starting point for another laptop, not a universal installer. Review and adapt each setting before applying it.

## Use on another laptop

Clone the repository and inspect the files you want:

```bash
mkdir -p ~/Projects
git clone https://github.com/OfficialAbhinavSingh/arch-dotfiles.git ~/Projects/arch-dotfiles
cd ~/Projects/arch-dotfiles
git ls-files
```

Back up any existing configuration before copying files. For example, to apply the Hyprland config:

```bash
backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup" "$HOME/.config"
if [ -e "$HOME/.config/hypr" ]; then
    cp -a "$HOME/.config/hypr" "$backup/hypr"
fi
cp -a .config/hypr "$HOME/.config/"
```

Use the same approach for other selected files under `.config/`, plus `.bashrc`, `.zshrc`, or `.p10k.zsh` if you use those shells. Applying a whole config directory can replace files with the same names, so inspect the diff and keep the backup until everything works.

## Adapt before applying

- Replace `/home/laterabhi` paths with the account path on the target laptop. Wallpaper, avatar, and monitor settings also point to files or hardware from my machine.
- The Hyprland setup expects its programs and plugins to be installed separately. Install the dependencies you need with pacman or an AUR helper before enabling related configs and services. This repository does not include a current package list or automatic installer.
- `system/` contains system-wide source files, not files to copy into `$HOME`. Review them and install only the units that match the target hardware. The AMD backlight helper is specific to an `amdgpu_bl1` backlight device.
- Do not copy `.gitconfig` as-is: set your own Git name, email, signing key, and credential helper.
- `.config/zen/user.js` is a Zen Browser profile template. Place it in the active Zen profile only if you want those preferences.
- See [MANUAL-INSTALLS.md](MANUAL-INSTALLS.md) for software installed outside pacman/AUR.

## Credentials and privacy

Never put API keys, access tokens, passwords, private keys, or browser credentials in this repository. Local secret and credential files are excluded by `.gitignore`; keep them on the machine or in a password manager. Before pushing changes, review `git status` and the complete diff, especially newly added files.

This is a personal configuration repository. Review it for account details, local paths, and other information you do not want to publish before changing its visibility.

## Syncing this repository

The tracked `.local/bin/dot-sync.sh` script is for the original machine's bare-repository setup. It reads package lists from the current laptop and pushes through `~/.dotfiles`; it is not a general installer or sync command for a fresh clone. On another laptop, use normal Git commands in the cloned repository and configure its remote and identity first.
