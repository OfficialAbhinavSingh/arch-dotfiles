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

-- Known external (Dell E2218HN over HDMI): placed to the right of the laptop
hl.monitor({
    output        = "HDMI-A-1",
    mode          = "1920x1080@60",
    position      = "1920x0",
    scale         = 1,
    sdrbrightness = 1.6,
})

-- Any other/unknown external monitor: auto res/refresh, placed to the right
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "1920x0",
    scale    = 1,
})
