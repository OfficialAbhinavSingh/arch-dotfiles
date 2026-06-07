# 🐧 Arch Linux Dotfiles

This repository contains my personal Arch Linux configuration files managed via a **Bare Git Repository**. This method allows me to track files directly in my home directory without using symlinks.

## 🛠️ How to Manage Dotfiles

I use an alias called `dot` to interact with this repository.

- **Check status:** `dot status`
- **Add a new file:** `dot add ~/.config/some-app/config`
- **Commit changes:** `dot commit -m "Update config"`
- **Push to GitHub:** `dot push`

---

## 🚀 Restoration Guide (In case of disaster)

If you need to restore these configs on a fresh Arch Linux install, follow these steps:

### 1. Prerequisites
Ensure `git` is installed:
```bash
sudo pacman -S git
```

### 2. Clone the Repository
Clone the repository as a bare repo into a hidden folder:
```bash
git clone --bare https://github.com/OfficialAbhinavSingh/arch-dotfiles.git $HOME/.dotfiles
```

### 3. Define the Alias (Temporary)
```bash
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

### 4. Checkout the Files
Try to checkout the files to your home directory:
```bash
dot checkout
```
*Note: If it fails because files like `.bashrc` already exist, move them to a backup folder and try again:*
```bash
mkdir -p .dotfiles-backup && dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
dot checkout
```

### 5. Prevent Untracked Files from Showing
```bash
dot config --local status.showUntrackedFiles no
```

### 6. Reinstall Packages
Use the included package lists to restore your software:
```bash
# Install Pacman packages
sudo pacman -S --needed - < pkglist.txt

# Install AUR packages (Assuming yay is installed)
yay -S --needed - < aurlist.txt
```

---

## 🔄 Automatic Sync
I have a script at `~/.local/bin/dot-sync.sh` that automatically:
1. Exports current package lists.
2. Commits them.
3. Pushes everything to GitHub.

To run it:
```bash
dot-sync.sh
```
