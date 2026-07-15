#!/bin/bash

set -eu

GTK3_SETTINGS="${HOME}/.config/gtk-3.0/settings.ini"
GTK4_SETTINGS="${HOME}/.config/gtk-4.0/settings.ini"

DARK_THEME="catppuccin-mocha-mauve-standard+default"
LIGHT_THEME="Adwaita"
ICON_THEME="Adwaita"
CURSOR_THEME="catppuccin-mocha-mauve-cursors"
CURSOR_SIZE="24"

mode="${1:-toggle}"

current_theme() {
    if [ -f "${GTK3_SETTINGS}" ]; then
        awk -F= '/^gtk-theme-name=/{print $2; exit}' "${GTK3_SETTINGS}"
    fi
}

write_settings() {
    theme="$1"
    prefer_dark="$2"

    mkdir -p "$(dirname "${GTK3_SETTINGS}")" "$(dirname "${GTK4_SETTINGS}")"

    for file in "${GTK3_SETTINGS}" "${GTK4_SETTINGS}"; do
        cat > "${file}" <<EOF
[Settings]
gtk-theme-name=${theme}
gtk-icon-theme-name=${ICON_THEME}
gtk-cursor-theme-name=${CURSOR_THEME}
gtk-cursor-theme-size=${CURSOR_SIZE}
gtk-application-prefer-dark-theme=${prefer_dark}
EOF
    done

    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.desktop.interface gtk-theme "${theme}" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme "${ICON_THEME}" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-theme "${CURSOR_THEME}" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-size "${CURSOR_SIZE}" 2>/dev/null || true
        if [ "${prefer_dark}" = "1" ]; then
            gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
        else
            gsettings set org.gnome.desktop.interface color-scheme default 2>/dev/null || true
        fi
    fi
}

case "${mode}" in
    dark)
        write_settings "${DARK_THEME}" 1
        printf 'Theme set to dark (%s)\n' "${DARK_THEME}"
        ;;
    light)
        write_settings "${LIGHT_THEME}" 0
        printf 'Theme set to light (%s)\n' "${LIGHT_THEME}"
        ;;
    toggle)
        if [ "$(current_theme)" = "${DARK_THEME}" ]; then
            write_settings "${LIGHT_THEME}" 0
            printf 'Theme set to light (%s)\n' "${LIGHT_THEME}"
        else
            write_settings "${DARK_THEME}" 1
            printf 'Theme set to dark (%s)\n' "${DARK_THEME}"
        fi
        ;;
    *)
        printf 'Usage: %s [dark|light|toggle]\n' "$0" >&2
        exit 1
        ;;
esac
