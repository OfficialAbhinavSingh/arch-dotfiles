-- Hyprland configuration (Lua)
-- hyprlang is deprecated since 0.55; this file is the single source of truth.
-- Docs: https://wiki.hypr.land/Configuring/Start/
-- Stubs for LSP autocompletion: /usr/share/hypr/stubs/hl.meta.lua
--
-- Tuning target: ASUS laptop, Ryzen 7 6800H + Radeon 680M (iGPU) + RTX 3050,
-- 16GB RAM, 1920x1080@144 eDP. Plain and fast on purpose: no blur, no shadows,
-- no window transparency, no looping animations. Every effect that repaints
-- while the desktop is idle has been removed.

-- ── Monitors & workspace pinning ─────────────────────────────────────────────
require("monitors")
require("workspaces")

-- ── Environment variables ────────────────────────────────────────────────────
-- Qt apps: use Wayland natively instead of falling back to XCB/X11
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
-- GTK apps: prefer Wayland, fall back to XWayland if needed
hl.env("GDK_BACKEND", "wayland,x11")
-- Explicit cursor theme for Hyprland, XWayland, and GTK apps
hl.env("XCURSOR_THEME", "catppuccin-mocha-mauve-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-mauve-cursors")
hl.env("HYPRCURSOR_SIZE", "24")
-- Tell portals/apps which desktop is running
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show drun -modi run,drun,filebrowser,window"

-- ── Launchers ───────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.local/bin/power-menu"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + P", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/hypr/scripts/DarkLight.sh toggle"))
hl.bind(mainMod .. " + O", hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mainMod .. " + Slash", hl.dsp.exec_cmd("~/.local/bin/keybinds-hint.sh"))
hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd("rofi -show emoji -modi emoji"))
hl.bind(mainMod .. " + ALT + A", hl.dsp.exec_cmd([[kitty --title "ai" sh -c "echo '🤖 Ask your local AI:'; read -p '> ' prompt; ~/.local/bin/ai \"\$prompt\"; read"]]))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.local/bin/wallpaper-shuffle"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.local/bin/live-wallpaper"))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("~/.local/bin/live-wallpaper stop"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd([[kitty --title "maintenance" sh -c "~/.local/bin/arch-maintenance.sh; read"]]))
hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("wl-kbptr-toggle"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.exec_cmd("wl-kbptr-toggle right"))
hl.bind("ALT + Shift_L", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- ── caelestia shell drawers ──────────────────────────────────────────────────
-- Drawer names come from `caelestia shell drawers list`.
-- rofi (SUPER+R) and the old power-menu (SUPER+M) are deliberately left alone
-- so there is a working fallback if quickshell is not running.
local cae = function(cmd) return hl.dsp.exec_cmd("caelestia shell " .. cmd) end
local function open_launcher()
    hl.dispatch(hl.dsp.global("quickshell:launcher"))
    hl.dispatch(hl.dsp.exec_cmd("caelestia shell drawers toggle launcher"))
end
hl.bind(mainMod .. " + Space", open_launcher)
hl.bind(mainMod .. " + SHIFT + D",     cae("drawers toggle dashboard"))
hl.bind(mainMod .. " + SHIFT + N",     cae("drawers toggle sidebar"))
hl.bind(mainMod .. " + SHIFT + U",     cae("drawers toggle utilities"))
hl.bind(mainMod .. " + SHIFT + Escape", cae("drawers toggle session"))
hl.bind(mainMod .. " + SHIFT + I",     cae("idleInhibitor toggle"))
hl.bind(mainMod .. " + CTRL + N",      cae("notifs toggleDnd"))

-- ── impasto shell (test, Quickshell global shortcuts) ───────────────────────
-- Only fires when a quickshell config that registers these names is running
-- (currently `qs -c impasto`, started manually, not at session start). No-op
-- when it isn't, since the portal has nothing registered under that name.
-- Kept off plain SUPER+<letter> entirely: that space already belongs to the
-- binds above. Remove this block (or stop the impasto shell) to fully revert.
-- Launcher is on plain SUPER+Space below (works for both shells), not here.
hl.bind(mainMod .. " + A",               hl.dsp.global("quickshell:controls"))
hl.bind(mainMod .. " + ALT + Tab",       hl.dsp.global("quickshell:overview"))
hl.bind(mainMod .. " + ALT + Comma",     hl.dsp.global("quickshell:settings"))
hl.bind(mainMod .. " + ALT + T",         hl.dsp.global("quickshell:appearance"))
hl.bind(mainMod .. " + ALT + SHIFT + T", hl.dsp.global("quickshell:palette"))
hl.bind(mainMod .. " + ALT + U",         hl.dsp.global("quickshell:stats"))
hl.bind(mainMod .. " + ALT + P",         hl.dsp.global("quickshell:pet"))
hl.bind(mainMod .. " + ALT + G",         hl.dsp.global("quickshell:games"))
hl.bind(mainMod .. " + ALT + N",         hl.dsp.global("quickshell:notes"))
hl.bind(mainMod .. " + ALT + K",         hl.dsp.global("quickshell:board"))
hl.bind(mainMod .. " + ALT + H",         hl.dsp.global("quickshell:keys"))
-- Lock is on plain SUPER+L below (works for both shells), not duplicated here.
hl.bind(mainMod .. " + ALT + X",         hl.dsp.global("quickshell:session"))
hl.bind(mainMod .. " + ALT + V",         hl.dsp.global("quickshell:clipboard"))
hl.bind(mainMod .. " + ALT + I",         hl.dsp.global("quickshell:packages"))

-- ── System info floating window ─────────────────────────────────────────────
-- neofetch was archived upstream; fastfetch is the maintained replacement.
-- Window title stays "neofetch" so the rules below keep matching.
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd([[kitty --title "neofetch" --override "initial_window_width=520" --override "initial_window_height=360" sh -c "fastfetch; read"]]))

-- ── Focus movement ───────────────────────────────────────────────────────────
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }))
-- SUPER+L is the lockscreen, SUPER+J is wl-kbptr; use arrows for right/down.

-- ── Lockscreen ───────────────────────────────────────────────────────────────
-- Whichever quickshell config is actually running owns the lock. It was
-- hyprlock here, but running both put two clients on ext-session-lock-v1 and
-- killed the shell whenever hyprlock won the race.
-- caelestia has no portal-registered global shortcuts (CLI only: `caelestia
-- shell lock lock`); impasto has no CLI (portal only: `quickshell:lock`).
-- Firing both keeps SUPER+L correct for whichever one is actually running --
-- the other call just errors silently against a shell that isn't there.
local function lock_screen()
    hl.dispatch(hl.dsp.global("quickshell:lock"))
    hl.dispatch(hl.dsp.exec_cmd("caelestia shell lock lock"))
end
hl.bind(mainMod .. " + L", lock_screen)

-- ── Window management ────────────────────────────────────────────────────────
-- Move the focused window within the layout
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))
-- Resize the focused window, 40px per press (hold to repeat)
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -40, y = 0,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 40,  y = 0,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })
-- Cycle windows inside the workspace
hl.bind(mainMod .. " + Tab",         hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.window.cycle_next({ prev = true }))
-- Centre a floating window
hl.bind(mainMod .. " + CTRL + Return", hl.dsp.window.center())
-- Reload this config without logging out
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
-- Show/hide the bar
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("caelestia shell drawers toggle bar"))

-- ── Workspace switching / move window to workspace ───────────────────────────
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- The loop above stops at 10, so workspaces 11+ (created by `movetoworkspace`
-- or a window rule) have no key of their own. `e+1`/`e-1` step through the
-- workspaces that actually exist, skipping empties and special:scratchpad, so
-- these reach any number without needing a key per workspace.
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + Left",  hl.dsp.focus({ workspace = "e-1" }))

-- ── Mouse workspace scroll ───────────────────────────────────────────────────
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
-- On 0.56.2, hyprctl reports `mouse=false` on these binds (the lua bind
-- parser never reads the `mouse` option into BIND_FLAG_MOUSE — confirmed via
-- upstream source diff, fixed on main) but drag/resize work fine in practice,
-- confirmed live 2026-08-14. That JSON field is exclusivity-check metadata,
-- not what gates the actual dispatcher — don't trust it as a functional signal.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Accessibility: screen magnifier ──────────────────────────────────────────
-- Zooms the area around the cursor. Equals/Minus without SHIFT, so it also
-- works on the numpad. SUPER+CTRL+0 resets to 1:1.
hl.bind(mainMod .. " + CTRL + Equal", hl.dsp.exec_cmd([[sh -c 'z=$(hyprctl getoption cursor:zoom_factor | awk "/float/{print \$2}"); hyprctl keyword cursor:zoom_factor $(awk -v z="$z" "BEGIN{f=z+0.25; if(f>4)f=4; print f}")']]), { repeating = true })
hl.bind(mainMod .. " + CTRL + Minus", hl.dsp.exec_cmd([[sh -c 'z=$(hyprctl getoption cursor:zoom_factor | awk "/float/{print \$2}"); hyprctl keyword cursor:zoom_factor $(awk -v z="$z" "BEGIN{f=z-0.25; if(f<1)f=1; print f}")']]), { repeating = true })
hl.bind(mainMod .. " + CTRL + 0",     hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 1"))

-- ── Volume & Brightness (media keys) ────────────────────────────────────────
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("~/.config/hypr/scripts/Volume.sh --inc"),        { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("~/.config/hypr/scripts/Volume.sh --dec"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("~/.config/hypr/scripts/Volume.sh --toggle"),     { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("~/.config/hypr/scripts/Brightness.sh --inc"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/hypr/scripts/Brightness.sh --dec"),    { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d asus::kbd_backlight set 1+"),   { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d asus::kbd_backlight set 1-"),   { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- ── Screenshot ───────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png]]))
-- Print key: region to both clipboard and disk
hl.bind("Print", hl.dsp.exec_cmd([[sh -c 'f=~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png; grim -g "$(slurp)" "$f" && wl-copy < "$f"']]))

-- ── Clipboard history ────────────────────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

-- ── Scratchpad (Zen Terminal) ────────────────────────────────────────────────
hl.bind(mainMod .. " + Grave",         hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + SHIFT + Grave", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- ─────────────────────────────────────────────────────────────────────────────

hl.config({
    general = {
        -- Tighter than before: 1080p is not much screen to give away to gaps.
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            -- Solid colours. A gradient border costs a shader pass per window
            -- and only looks different while the borderangle animation runs,
            -- which is off below.
            active_border   = "rgba(cba6f7ff)",
            inactive_border = "rgba(45475aff)",
        },

        layout = "dwindle",
        resize_on_border = true,
        -- Floating windows snap to edges and each other while dragging.
        snap = { enabled = true },
    },

    decoration = {
        rounding = 10,

        -- Fully opaque. Transparency means every window underneath has to be
        -- rendered too, and it makes text harder to read for no real gain.
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- Shadows: an extra blurred pass per window, every frame it changes.
        shadow = { enabled = false },

        -- Blur: was size 6 / 2 passes, i.e. the most expensive single setting
        -- in the old config. Off entirely.
        blur = { enabled = false },

        dim_inactive = false,
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper   = 0,
        disable_hyprland_logo     = true,
        disable_splash_rendering  = true,
        mouse_move_enables_dpms   = true,
        key_press_enables_dpms    = true,
        -- Terminal swallowing: launching a GUI app from the terminal hides the
        -- terminal until the app exits, instead of leaving a dead pane around.
        enable_swallow            = true,
        swallow_regex             = "^(kitty|kitty-pad)$",
        -- Don't animate manual drags/resizes: those are the frames where you
        -- most want the compositor to just keep up with the pointer.
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,
        focus_on_activate            = true,
    },

    input = {
        -- kb_file wins over kb_layout/kb_variant when set. This file is the same
        -- us + us(dvp) pair, with Right Alt replaced by a plain backtick key
        -- (Shift+RightAlt = ~), because this keyboard has no grave key.
        kb_file            = "/home/laterabhi/.config/hypr/keymap-ralt-grave.xkb",
        kb_layout          = "us,us",
        kb_variant         = ",dvp",
        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0,

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            scroll_factor        = 0.8,
            tap_button_map       = "lrm",
        },
    },

    debug = {
        -- Keep Hyprland from filling /run (tmpfs = RAM) with debug logs.
        disable_logs = true,
    },
})

-- ── Animations ───────────────────────────────────────────────────────────────
-- Short and few. `speed` is in deciseconds, so 2 = 200ms, 1.5 = 150ms.
-- Deliberately absent: `borderangle`. The old config ran it at speed 80 in
-- `loop` style, which repaints every window border on every frame forever —
-- at 144Hz that is a permanent GPU/CPU load with the desktop sitting idle.
hl.curve("snap",  { type = "bezier", points = { {0.05, 0.9},  {0.1,  1.0} } })
hl.curve("quint", { type = "bezier", points = { {0.23, 1.0},  {0.32, 1.0} } })

hl.animation({ leaf = "windows",          enabled = true,  speed = 2,   bezier = "snap",  style = "slide" })
hl.animation({ leaf = "windowsOut",       enabled = true,  speed = 1.5, bezier = "quint", style = "slide" })
hl.animation({ leaf = "windowsMove",      enabled = true,  speed = 1.5, bezier = "snap",  style = "slide" })
hl.animation({ leaf = "fade",             enabled = true,  speed = 1.5, bezier = "quint" })
hl.animation({ leaf = "border",           enabled = false })
hl.animation({ leaf = "borderangle",      enabled = false })
hl.animation({ leaf = "workspaces",       enabled = true,  speed = 2,   bezier = "quint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true,  speed = 2,   bezier = "quint", style = "slidevert" })

-- ── Touchpad gestures ────────────────────────────────────────────────────────
-- Three fingers left/right = previous/next workspace. Wrapped in pcall so an
-- API change upstream degrades to "no gestures" instead of a broken config.
pcall(function()
    hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
    hl.gesture({ fingers = 4, direction = "up", action = "special", workspace_name = "scratchpad" })
end)

-- ── Window rules ──────────────────────────────────────────────────────────────

-- Terminal: no Hyprland-side transparency. kitty does its own via
-- background_opacity in ~/.config/kitty/kitty.conf; the two multiply, so
-- pinning Hyprland to 1.0 keeps kitty.conf the single source of truth.
hl.window_rule({ match = { class = "^([Kk]itty)$" },     opacity = "1.0 1.0" })
hl.window_rule({ match = { class = "^([Kk]itty-pad)$" }, opacity = "1.0 1.0" })

-- fastfetch panel floats pinned in the top-right corner
hl.window_rule({ match = { title = "^(neofetch)$" }, float = true })
hl.window_rule({ match = { title = "^(neofetch)$" }, size  = {520, 360} })
hl.window_rule({ match = { title = "^(neofetch)$" }, move  = {"monitor_w-540", "40"} })
hl.window_rule({ match = { title = "^(neofetch)$" }, pin   = true })

-- Rofi
hl.window_rule({ match = { class = "^(rofi)$" }, float  = true })
hl.window_rule({ match = { class = "^(rofi)$" }, center = true })

-- Dolphin
hl.window_rule({ match = { class = "^(dolphin)$" }, float = true })

-- Common dialogs and small utility windows float instead of tiling
hl.window_rule({ match = { class = "^(pavucontrol|blueman-manager|nm-connection-editor|org.kde.polkit-kde-authentication-agent-1)$" }, float  = true })
hl.window_rule({ match = { class = "^(pavucontrol|blueman-manager|nm-connection-editor|org.kde.polkit-kde-authentication-agent-1)$" }, center = true })
hl.window_rule({ match = { title = "^(Open File|Save File|Save As|Choose Files|Open Folder)$" }, float  = true })
hl.window_rule({ match = { title = "^(Open File|Save File|Save As|Choose Files|Open Folder)$" }, center = true })

-- Picture-in-picture: float, pin above everything, park bottom-right
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, pin   = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, size  = {640, 360} })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, move  = {"monitor_w-660", "monitor_h-400"} })

-- Zen Terminal scratchpad
hl.window_rule({ match = { class = "^(kitty-pad)$" }, float     = true })
hl.window_rule({ match = { class = "^(kitty-pad)$" }, size      = {"monitor_w*0.8", "monitor_h*0.85"} })
hl.window_rule({ match = { class = "^(kitty-pad)$" }, center    = true })
hl.window_rule({ match = { class = "^(kitty-pad)$" }, workspace = "special:scratchpad silent" })

-- ── Startup ───────────────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
    -- `balanced` instead of the old forced `power-saver`: power-saver caps the
    -- 6800H even while plugged in. Switch profiles from the waybar module.
    hl.exec_cmd("powerprofilesctl set balanced")

    hl.exec_cmd("hypridle")

    -- impasto (quickshell), testing as the daily driver in place of caelestia.
    -- To revert: comment the impasto-launch line below and uncomment the two
    -- caelestia lines. Nothing about caelestia's own config was touched --
    -- caelestia-shell.service and ~/.config/quickshell/caelestia/ are untouched,
    -- just not auto-started.
    -- hl.exec_cmd("~/.local/bin/caelestia-launch")
    hl.exec_cmd("~/.local/bin/impasto-launch")

    -- swaync is NOT started here. It owns the org.freedesktop.Notifications bus
    -- name, so starting it by hand raced its own D-Bus activation and left
    -- swaync.service in start-limit-hit. systemd --user owns it now.

    -- caelestia owns the background layer and draws the wallpaper itself, so
    -- awww-daemon is no longer started by wallpaper-shuffle; impasto-launch
    -- starts awww-daemon itself instead. Re-enable this when reverting to
    -- caelestia.
    -- hl.exec_cmd("~/.local/bin/wallpaper-shuffle")

    -- nm-applet and blueman-applet were removed: waybar has native network and
    -- bluetooth modules, and those two GTK trays cost ~70MB for a duplicate UI.

    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Zen Terminal, hidden in the scratchpad
    hl.exec_cmd("kitty --class kitty-pad", { workspace = "special:scratchpad silent" })
end)
