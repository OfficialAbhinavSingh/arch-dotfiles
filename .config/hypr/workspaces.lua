-- ── Workspace ↔ monitor pinning ──────────────────────────────────────────────
--
-- Workspaces 1-5 live on the laptop panel, 6-10 on the external.
-- The panel is eDP-2 with the MUX in dGPU mode and eDP-1 in Hybrid mode, so
-- both names are pinned; a rule naming an absent output is simply inert.

for _, out in ipairs({ "eDP-1", "eDP-2" }) do
    for ws = 1, 5 do
        hl.workspace_rule({ workspace = tostring(ws), monitor = out, default = (ws == 1) })
    end
end

for ws = 6, 10 do
    hl.workspace_rule({ workspace = tostring(ws), monitor = "HDMI-A-1", default = (ws == 6) })
end
