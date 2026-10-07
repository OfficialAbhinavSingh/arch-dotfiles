#!/usr/bin/env bash
# install.sh: set up this Arch + Hyprland + impasto desktop on any Arch machine.
#
#   git clone -b impasto-rice https://github.com/OfficialAbhinavSingh/arch-dotfiles.git
#   cd arch-dotfiles && ./install.sh
#
# Run it as your normal user (it asks for sudo when it needs it). It is safe to
# run again: every file it would overwrite is backed up first. `./install.sh -h`
# lists the options.

set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ORIGINAL_HOME=/home/laterabhi       # the paths baked into the configs
ORIGINAL_USER=laterabhi

# impasto (the quickshell desktop shell) is pinned to the commit these configs
# were built against; the files under .config/quickshell/impasto in this repo
# are overlaid on top of it.
IMPASTO_URL=https://github.com/andreumassanet/impasto.git
IMPASTO_REF=62b43a2c9ee1b1c2a13e1c1b3c31d3ee51fc7e5f

TS=$(date +%Y%m%d-%H%M%S)
STATE=${XDG_STATE_HOME:-$HOME/.local/state}/arch-dotfiles
BACKUP=$STATE/backups/$TS

# ── packages ─────────────────────────────────────────────────────────────────
PACMAN_PKGS=(
    # base for building AUR packages and cloning
    base-devel git
    # compositor and desktop shell
    hyprland hypridle quickshell awww imagemagick python dbus gtk3 libnotify
    fontconfig xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    xdg-user-dirs xdg-utils qt6ct polkit-kde-agent
    # audio, media keys
    pipewire pipewire-pulse wireplumber libpulse playerctl
    # screenshots and clipboard
    grim slurp wl-clipboard cliphist satty swappy
    # quick controls the shell and keybinds use
    brightnessctl ddcutil networkmanager bluez bluez-utils power-profiles-daemon
    upower hyprsunset hyprpicker pacman-contrib
    # apps the keybinds open
    kitty rofi dolphin swaync waybar nwg-displays mpv ffmpeg jq
    # terminal
    zsh starship tmux less fzf zoxide fastfetch btop cava neovim ripgrep fd
    # fonts and icons
    ttf-jetbrains-mono-nerd inter-font adwaita-fonts noto-fonts noto-fonts-emoji
    noto-fonts-cjk papirus-icon-theme unicode-emoji unicode-cldr-annotations iso-codes
)
# Optional: a failure here is reported and skipped, never fatal.
AUR_PKGS=(
    catppuccin-cursors-mocha   # the cursor theme hyprland.lua sets
    zen-browser-bin            # $BROWSER
    wallust                    # rofi/waybar palettes (builds from source, slow)
    mpvpaper                   # animated wallpapers in impasto
    wl-kbptr                   # SUPER+J keyboard pointer
)

# Paths in this repo that are NOT copied into $HOME.
SKIP_PATHS=(
    .git .gitignore .gitconfig README.md MANUAL-INSTALLS.md install.sh
    system .claude .config/zen assets
    .config/quickshell/impasto   # installed by install_impasto, on top of upstream
)

# ── options ──────────────────────────────────────────────────────────────────
DRY=0 YES=0 SKIP_PACKAGES=0 SKIP_AUR=0 SKIP_IMPASTO=0 SKIP_SYSTEM=0 SKIP_CHSH=0

usage() {
    cat <<EOF
Usage: ./install.sh [options]

Installs the packages, impasto, oh-my-zsh and these dotfiles for the current
user. Files it replaces are backed up to ~/.local/state/arch-dotfiles/backups/.

  -n, --dry-run        show what would happen, change nothing
  -y, --yes            don't ask; take the default answer everywhere
      --skip-packages  install no packages (pacman or AUR)
      --skip-aur       install the official-repo packages only
      --skip-impasto   don't download or install the impasto shell
      --skip-system    don't touch system services or files outside \$HOME
      --no-chsh        don't change the login shell to zsh
  -h, --help           this help
EOF
}

while (($#)); do
    case $1 in
        -n|--dry-run) DRY=1 ;;
        -y|--yes) YES=1 ;;
        --skip-packages) SKIP_PACKAGES=1 ;;
        --skip-aur) SKIP_AUR=1 ;;
        --skip-impasto) SKIP_IMPASTO=1 ;;
        --skip-system) SKIP_SYSTEM=1 ;;
        --no-chsh) SKIP_CHSH=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

# ── output helpers ───────────────────────────────────────────────────────────
if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
    B=$'\e[1m' G=$'\e[32m' Y=$'\e[33m' R=$'\e[31m' C=$'\e[36m' N=$'\e[0m'
else
    B='' G='' Y='' R='' C='' N=''
fi
step()  { printf '\n%s==>%s %s%s%s\n' "$C" "$N" "$B" "$*" "$N"; }
info()  { printf '    %s\n' "$*"; }
ok()    { printf '    %s✓%s %s\n' "$G" "$N" "$*"; }
warn()  { printf '    %s!%s %s\n' "$Y" "$N" "$*" >&2; WARNINGS+=("$*"); }
die()   { printf '%serror:%s %s\n' "$R" "$N" "$*" >&2; exit 1; }
WARNINGS=()

# run CMD...: execute, or just print it in dry-run mode
run() {
    if ((DRY)); then printf '    %s[dry-run]%s %s\n' "$Y" "$N" "$*"; return 0; fi
    "$@"
}
confirm() {   # confirm "question" [default y|n]
    local q=$1 def=${2:-y} ans
    if ((YES || DRY)); then [[ $def == y ]]; return; fi
    read -r -p "    $q [$([[ $def == y ]] && echo Y/n || echo y/N)] " ans </dev/tty || ans=
    ans=${ans:-$def}
    [[ ${ans,,} == y* ]]
}

# ── preflight ────────────────────────────────────────────────────────────────
step "Checking this machine"
((EUID != 0)) || die "run this as your normal user, not root (it uses sudo when needed)"
[[ -f /etc/arch-release ]] && command -v pacman >/dev/null \
    || die "this script is for Arch Linux (pacman not found)"
[[ -n ${HOME:-} && -d $HOME ]] || die "\$HOME is not set to a directory"
NEED_SUDO=0
((SKIP_PACKAGES && SKIP_SYSTEM)) || NEED_SUDO=1
if ((NEED_SUDO)); then
    command -v sudo >/dev/null || die "sudo is not installed: as root run 'pacman -S sudo' and add yourself to sudoers"
    if ((!DRY)); then
        info "sudo will ask for your password"
        sudo -v || die "sudo failed; is $USER in the sudoers file?"
        # keep the sudo timestamp fresh while long builds run
        while true; do sudo -n true 2>/dev/null; sleep 50; kill -0 $$ 2>/dev/null || exit; done &
        SUDO_KEEPALIVE=$!
    fi
fi
ok "Arch Linux, user $USER, home $HOME"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"; [[ -n ${SUDO_KEEPALIVE:-} ]] && kill "$SUDO_KEEPALIVE" 2>/dev/null; true' EXIT
((DRY)) && info "${Y}dry run: nothing will be changed${N}"

# ── 1. packages ──────────────────────────────────────────────────────────────
install_packages() {
    step "Installing official packages"
    local pkgs=() missing=() p
    # A fresh install may never have synced; the name check below needs the
    # sync databases. (-Syu follows straight after, so no partial upgrade.)
    run sudo pacman -Sy
    # Skip names the repos no longer carry instead of failing the transaction.
    for p in "${PACMAN_PKGS[@]}"; do
        if pacman -Si "$p" >/dev/null 2>&1 || pacman -Sg "$p" >/dev/null 2>&1; then
            pkgs+=("$p")
        else
            missing+=("$p")
        fi
    done
    ((${#missing[@]})) && warn "not in the repos, skipped: ${missing[*]}"
    local flags=(-Syu --needed)
    ((YES)) && flags+=(--noconfirm)
    info "pacman ${flags[*]} (${#pkgs[@]} packages; this also updates the system)"
    run sudo pacman "${flags[@]}" "${pkgs[@]}" || die "pacman failed; fix the error above and run ./install.sh again"
    ok "official packages installed"
}

AUR_HELPER=
find_aur_helper() {
    local h
    for h in paru yay; do command -v "$h" >/dev/null && { AUR_HELPER=$h; return 0; }; done
    return 1
}
bootstrap_yay() {
    info "no AUR helper found; building yay-bin from the AUR"
    local tmp; tmp=$(mktemp -d)
    run git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" || return 1
    if ((DRY)); then info "[dry-run] makepkg -si in $tmp/yay-bin"; AUR_HELPER=yay; return 0; fi
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm) || return 1
    rm -rf "$tmp"
    AUR_HELPER=yay
}
install_aur() {
    step "Installing AUR packages (optional)"
    if ! find_aur_helper; then
        if confirm "No AUR helper (yay/paru). Build yay now?" y; then
            bootstrap_yay || { warn "could not build yay; skipping AUR packages: ${AUR_PKGS[*]}"; return; }
        else
            warn "skipped AUR packages: ${AUR_PKGS[*]}"; return
        fi
    fi
    info "using $AUR_HELPER"
    local p flags=(-S --needed)
    ((YES)) && flags+=(--noconfirm)
    for p in "${AUR_PKGS[@]}"; do
        if pacman -Qq "$p" >/dev/null 2>&1; then ok "$p (already installed)"; continue; fi
        if run "$AUR_HELPER" "${flags[@]}" "$p"; then ok "$p"; else warn "AUR package $p failed to build; skipped"; fi
    done
}

# ── 2. copying with backups ──────────────────────────────────────────────────
# same_file A B: identical content (sha256sum is in coreutils; cmp is not in base)
same_file() {
    [[ $(sha256sum <"$1") == "$(sha256sum <"$2")" ]]
}
# tree_hash DIR: one hash over every file's path and content (ignores __pycache__)
tree_hash() {
    (cd "$1" && find . -type f ! -path '*/__pycache__/*' -print0 | LC_ALL=C sort -z \
        | xargs -0 -r sha256sum | sha256sum)
}
# put_file SRC DEST: copy, backing up a different existing DEST first
put_file() {
    local src=$1 dest=$2
    if [[ -e $dest || -L $dest ]]; then
        if [[ -f $dest && ! -L $dest ]] && same_file "$src" "$dest"; then return 0; fi
        local rel=${dest#"$HOME"/}
        run mkdir -p "$(dirname "$BACKUP/$rel")"
        run mv "$dest" "$BACKUP/$rel"
        BACKED_UP=$((BACKED_UP + 1))
    fi
    run mkdir -p "$(dirname "$dest")"
    run cp -p "$src" "$dest"
    COPIED=$((COPIED + 1))
}
# personalised SRC: print a path to SRC with the original owner's home and
# user name swapped for this user's (a temp copy, or SRC itself if unchanged)
personalised() {
    local src=$1 tmp
    if [[ $HOME == "$ORIGINAL_HOME" && $USER == "$ORIGINAL_USER" ]] || ! grep -qF "$ORIGINAL_USER" "$src" 2>/dev/null; then
        printf '%s' "$src"; return
    fi
    tmp=$(mktemp -p "$WORK")
    cp -p "$src" "$tmp"
    sed -i "s|$ORIGINAL_HOME|$HOME|g" "$tmp"
    # the lock screen greets the account by name
    [[ $src == */hypr/hyprlock.conf ]] \
        && sed -i -E "s/^([[:space:]]*text[[:space:]]*=[[:space:]]*)$ORIGINAL_USER\$/\1$USER/" "$tmp"
    printf '%s' "$tmp"
}
is_skipped() {
    local rel=$1 s
    for s in "${SKIP_PATHS[@]}"; do
        [[ $rel == "$s" || $rel == "$s"/* ]] && return 0
    done
    return 1
}

install_dotfiles() {
    step "Copying dotfiles into $HOME"
    COPIED=0 BACKED_UP=0
    local rel
    while IFS= read -r -d '' f; do
        rel=${f#"$REPO"/}
        is_skipped "$rel" && continue
        put_file "$(personalised "$f")" "$HOME/$rel"
    done < <(find "$REPO" -path "$REPO/.git" -prune -o -type f -print0 | sort -z)
    ((DRY)) || chmod +x "$HOME"/.local/bin/* "$HOME"/.config/hypr/scripts/*.sh "$HOME"/.config/hypr/UserScripts/*.sh 2>/dev/null || true
    ok "$COPIED files copied, $BACKED_UP existing files backed up"
}

# ── 3. impasto ───────────────────────────────────────────────────────────────
install_impasto() {
    step "Installing the impasto shell (pinned to ${IMPASTO_REF:0:9})"
    local tmp; tmp=$(mktemp -d)
    if ((DRY)); then
        info "[dry-run] clone $IMPASTO_URL at $IMPASTO_REF"
        info "[dry-run] copy its quickshell config to ~/.config/quickshell/impasto"
        info "[dry-run] copy its wallpapers, fonts and data to ~/.local/share"
        return 0
    fi
    git clone --quiet --filter=blob:none "$IMPASTO_URL" "$tmp/impasto" \
        && git -C "$tmp/impasto" -c advice.detachedHead=false checkout --quiet "$IMPASTO_REF" \
        || { warn "could not download impasto; the desktop shell will not start"; rm -rf "$tmp"; return; }
    local src=$tmp/impasto/home dest=$HOME/.config/quickshell/impasto
    local staged=$tmp/staged f
    COPIED=0 BACKED_UP=0
    # Build the finished config first: upstream plus this repo's changes to it
    # (screenshot ropes, Claude usage widget).
    mkdir -p "$staged"
    cp -a "$src/.config/quickshell/." "$staged/"
    while IFS= read -r -d '' f; do
        cp -p "$f" "$staged/${f#"$REPO/.config/quickshell/impasto/"}"
    done < <(find "$REPO/.config/quickshell/impasto" -type f -print0)
    if [[ -d $dest ]] && [[ $(tree_hash "$staged") == "$(tree_hash "$dest")" ]]; then
        ok "impasto config already up to date"
    else
        # A previous install is moved aside whole, so no stale file lingers.
        if [[ -d $dest ]]; then
            mkdir -p "$BACKUP/.config/quickshell"
            mv "$dest" "$BACKUP/.config/quickshell/impasto"
            info "previous ~/.config/quickshell/impasto moved to the backup"
        fi
        mkdir -p "$(dirname "$dest")"
        cp -a "$staged" "$dest"
    fi
    # wallpapers, fonts and the palette board impasto expects in ~/.local/share
    for d in wallpapers fonts impasto; do
        [[ -d $src/.local/share/$d ]] || continue
        while IFS= read -r -d '' f; do
            put_file "$f" "$HOME/.local/share/$d/${f#"$src/.local/share/$d/"}"
        done < <(find "$src/.local/share/$d" -type f -print0)
    done
    rm -rf "$tmp"
    command -v fc-cache >/dev/null && fc-cache -f >/dev/null 2>&1 || true
    ok "impasto installed to ~/.config/quickshell/impasto"
}

# ── 4. zsh ───────────────────────────────────────────────────────────────────
clone_if_missing() {   # clone_if_missing URL DIR
    if [[ -d $2 ]]; then ok "$(basename "$2") already present"; return; fi
    run git clone --quiet --depth 1 "$1" "$2" && ok "$(basename "$2")" || warn "could not clone $1"
}
install_zsh() {
    step "Setting up zsh (oh-my-zsh, powerlevel10k, plugins)"
    ((DRY)) || command -v git >/dev/null || { warn "git missing; skipped oh-my-zsh"; return; }
    clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    local custom=$HOME/.oh-my-zsh/custom
    clone_if_missing https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$custom/plugins/zsh-autosuggestions"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/plugins/zsh-syntax-highlighting"
    if ((!SKIP_CHSH)); then
        local zsh_path current
        zsh_path=$(command -v zsh || true)
        current=$(getent passwd "$USER" | cut -d: -f7)
        if [[ -z $zsh_path ]]; then
            warn "zsh not installed; login shell left as $current"
        elif [[ $current == "$zsh_path" || $current == /bin/zsh || $current == /usr/bin/zsh ]]; then
            ok "login shell is already zsh"
        elif confirm "Make zsh your login shell?" y; then
            run sudo chsh -s "$zsh_path" "$USER" && ok "login shell set to zsh" || warn "chsh failed; run: chsh -s $zsh_path"
        fi
    fi
}

# ── 5. services ──────────────────────────────────────────────────────────────
enable_system_service() {   # enable_system_service UNIT
    if systemctl is-enabled --quiet "$1" 2>/dev/null; then ok "$1 already enabled"; return; fi
    # in a dry run the package may not be installed yet: just say what would run
    if ((DRY)); then run sudo systemctl enable --now "$1"; return; fi
    systemctl list-unit-files "$1" >/dev/null 2>&1 && systemctl cat "$1" >/dev/null 2>&1 \
        || { warn "$1 is not installed; skipped"; return; }
    run sudo systemctl enable --now "$1" && ok "enabled $1" || warn "could not enable $1"
}
setup_services() {
    step "Enabling services"
    if ((!SKIP_SYSTEM)); then
        enable_system_service power-profiles-daemon.service
        enable_system_service bluetooth.service
        # NetworkManager fights other network managers: only turn it on when
        # nothing else is managing the network.
        local other='' u
        for u in systemd-networkd.service iwd.service dhcpcd.service netctl.service connman.service; do
            systemctl is-enabled --quiet "$u" 2>/dev/null && other+=" $u"
        done
        if systemctl is-enabled --quiet NetworkManager.service 2>/dev/null; then
            ok "NetworkManager.service already enabled"
        elif [[ -n $other ]]; then
            warn "left NetworkManager off because${other} already manage the network (the bar's Wi-Fi tile needs NetworkManager)"
        else
            enable_system_service NetworkManager.service
        fi
        # AMD laptop panels that stay black after boot (only where that device exists)
        if [[ -e /sys/class/backlight/amdgpu_bl1/brightness ]]; then
            info "amdgpu_bl1 backlight found: installing the backlight fix"
            if ! { run sudo install -Dm755 "$REPO/system/usr/local/bin/amdgpu-backlight-nudge" /usr/local/bin/amdgpu-backlight-nudge \
                && run sudo install -Dm644 "$REPO/system/etc/systemd/system/amdgpu-backlight-nudge.service" /etc/systemd/system/amdgpu-backlight-nudge.service; }; then
                warn "could not install the backlight fix"
            fi
            run sudo systemctl daemon-reload || warn "systemctl daemon-reload failed"
            run sudo systemctl enable amdgpu-backlight-nudge.service && ok "amdgpu-backlight-nudge enabled" \
                || warn "could not enable amdgpu-backlight-nudge.service"
        fi
    fi
    # user units: needs a running user manager (absent in chroots/containers)
    if systemctl --user show-environment >/dev/null 2>&1; then
        run systemctl --user daemon-reload || true
        run systemctl --user enable --now hyprland-log-trim.timer >/dev/null 2>&1 && ok "hyprland-log-trim.timer" || warn "could not enable hyprland-log-trim.timer"
        if command -v npm >/dev/null; then
            run systemctl --user enable --now npm-cache-maintenance.timer >/dev/null 2>&1 && ok "npm-cache-maintenance.timer" || true
        fi
    else
        warn "no systemd user session here; after logging in run: systemctl --user enable --now hyprland-log-trim.timer"
    fi
    command -v xdg-user-dirs-update >/dev/null && run xdg-user-dirs-update || true
}

# ── run ──────────────────────────────────────────────────────────────────────
if ((!SKIP_PACKAGES)); then
    install_packages
    ((SKIP_AUR)) || install_aur
fi
install_dotfiles
((SKIP_IMPASTO)) || install_impasto
install_zsh
setup_services

step "Done"
if [[ -d $BACKUP ]]; then
    info "Replaced files were backed up to: $BACKUP"
    info "Restore them with: cp -a \"$BACKUP/.\" \"\$HOME/\""
fi
if ((${#WARNINGS[@]})); then
    printf '\n    %sWarnings:%s\n' "$Y" "$N"
    for w in "${WARNINGS[@]}"; do printf '      - %s\n' "$w"; done
fi
cat <<EOF

    Next steps:
      1. Log out and start Hyprland: run 'start-hyprland' from a TTY, or pick
         Hyprland in your display manager. The impasto shell starts by itself.
      2. Pick a wallpaper: SUPER+ALT+T opens impasto's wallpaper picker.
      3. Monitors are set for the original laptop in ~/.config/hypr/monitors.lua;
         others fall back to Hyprland's automatic layout. Edit it to taste.
      4. Right Alt is remapped to the backtick key (~/.config/hypr/keymap-ralt-grave.xkb);
         remove the kb_file line in hyprland.lua if you don't want that.
      5. Set your own git name and email: this repo's .gitconfig is not installed.
EOF
