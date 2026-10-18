-- ── Monitor layout ────────────────────────────────────────────────────────
--
-- The internal panel's connector name depends on which GPU drives it:
--   MUX in dGPU mode  -> eDP-2 (wired to the RTX 3050)
--   MUX in Hybrid     -> eDP-1 (wired to the Radeon 680M)
-- Both are declared with identical settings so a MUX switch needs no edit
-- here; only one of the two ever exists at a time.

local panel = { mode = "1920x1080@144", position = "0x0", scale = 1 }

hl.monitor({ output = "eDP-1", mode = panel.mode, position = panel.position, scale = panel.scale })
hl.monitor({ output = "eDP-2", mode = panel.mode, position = panel.position, scale = panel.scale })

-- Known external (Acer EK241Y over HDMI): placed to the left of the laptop
hl.monitor({
    output        = "HDMI-A-1",
    mode          = "1920x1080@60",
    position      = "-1920x0",
    scale         = 1,
    sdrbrightness = 1.6,
})

-- Any other/unknown external monitor: auto res/refresh, placed to the left
-- as a default; monitor-side-prompt.sh (below) overrides this live once the
-- user answers the hotplug prompt.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "-1920x0",
    scale    = 1,
})

-- Every external hotplug: force a DPMS cycle (the HDMI port is wired to the
-- dGPU, which has shown a stale "connected + on" report with no actual
-- picture on first probe) and ask which side of the laptop it's on, then
-- reposition it live. Laptop panels (eDP-1/eDP-2) are skipped in the script.
hl.on("monitor.added", function(mon)
    hl.exec_cmd("~/.config/hypr/scripts/monitor-side-prompt.sh " .. mon.name)
end)
