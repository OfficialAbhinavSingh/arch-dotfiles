# Performance mode

Notes and a ready-to-paste agent prompt for a machine running these dotfiles that
slows down under a normal dev load: two coding-agent sessions in the terminal plus
a browser with 5-10 tabs.

## Where the CPU and RAM usually go

The Hyprland side is already lean (`hyprland.lua` has no blur, no shadows, no
transparency, no looping animations), so the compositor is rarely the problem.
The usual suspects with this setup, roughly in order:

1. **Coding agents.** Each Claude Code session is its own Node process, and every
   MCP server and LSP plugin it enables is started again *per session*. Two
   sessions with playwright, firecrawl, figma, vercel and rust-analyzer enabled
   means two copies of each. Idle sessions still hold all of that memory.
2. **Browser.** Zen/Firefox runs one content process per site group. The tuned
   `.config/zen/user.js` (process cap, tab unloading) is **not** installed by
   `install.sh`, so a fresh machine runs the defaults.
3. **Memory pressure handling.** No zram and no userspace OOM killer are set up
   by `install.sh`. When RAM fills, the kernel thrashes the disk instead of
   compressing pages or killing one tab, and everything stutters.
4. **Desktop shell.** impasto (Quickshell/QML) plus `awww-daemon` and two
   `cliphist` watchers. Small individually, but they never sleep.
5. **Shell startup.** oh-my-zsh + powerlevel10k + plugins are re-run for every
   pane and every agent-spawned shell.

## The prompt

Paste this into a coding agent (Claude Code, Codex, etc.) **on the slow machine**,
from inside the cloned `arch-dotfiles` repo.

````text
You are tuning an Arch Linux laptop that runs the dotfiles in this repository
(Hyprland with a Lua config, impasto Quickshell shell, kitty, zsh with
oh-my-zsh + powerlevel10k, Zen Browser). The owner's normal load is two coding
agent sessions in the terminal plus a browser with 5-10 tabs, and under that
load CPU and RAM usage are far too high. Your job is to (1) find out what is
actually using the resources, (2) apply safe optimisations, and (3) build a
toggleable "performance mode".

Ground rules
- Measure before you change anything, and measure again after. Every change you
  keep must be justified by a number. Do not guess.
- Do not uninstall packages, delete user data, disable security features
  (Firefox/Zen fission and site isolation stay ON), or touch the bootloader.
- Back up every file before editing it (copy to
  ~/.local/state/perf-mode/backups/<timestamp>/). Every change must be
  reversible, and you must write down how to revert it.
- Ask before any command that needs sudo, and list what it will do.
- This laptop's hardware is not the one the dotfiles were written on. Read the
  real CPU, GPU, RAM and swap with lscpu, lspci -k, free -h, swapon --show and
  cat /proc/pressure/{cpu,memory} before choosing any value.

Step 1: Baseline (do this with the heavy load running)
- Ask the owner to open their usual load: two agent sessions and the browser.
- Record: free -h; swapon --show; cat /proc/pressure/memory;
  `ps -eo pid,ppid,rss,pcpu,comm --sort=-rss | head -40`;
  `systemd-cgtop -m -n 3 -b`; and per-app totals with smem -t -k -c "name pss"
  or ps_mem if available (install only with permission).
- Group the numbers by app: agent sessions (node/claude/codex and every child
  process they spawned: MCP servers, LSPs, npx, playwright Chromium), browser
  (all zen/firefox processes), shell (qs, awww-daemon, cliphist, wl-paste),
  Hyprland, everything else.
- Save the baseline table to ~/.local/state/perf-mode/baseline.md.

Step 2: Permanent, low-risk fixes (apply only what the baseline justifies)
a. Memory pressure
   - If there is no zram: install zram-generator and set zram-size = ram / 2,
     compression-algorithm = zstd in /etc/systemd/zram-generator.conf.
   - With zram, set vm.swappiness=180, vm.watermark_boost_factor=0,
     vm.watermark_scale_factor=125, vm.page-cluster=0 in
     /etc/sysctl.d/99-vm-zram.conf (the values the Arch wiki recommends for zram).
   - Enable systemd-oomd (systemctl enable --now systemd-oomd) so a runaway tab
     or agent is killed instead of the whole desktop freezing.
b. Coding agents
   - List every MCP server and plugin each agent enables (for Claude Code:
     ~/.claude/settings.json "enabledPlugins", ~/.claude.json mcpServers, and any
     project .mcp.json). Show the owner each one's RSS from the baseline and
     which ones they actually use. Disable the unused ones globally and enable
     heavy ones (playwright, figma, vercel, language servers) only in the
     projects that need them.
   - Check for orphaned children from old sessions (MCP servers, playwright
     Chromium, LSPs whose parent is gone or is PID 1) and report them.
   - Do not cap Node heap size blindly; only add NODE_OPTIONS
     --max-old-space-size if the baseline shows a single agent process growing
     past ~1.5 GB.
c. Browser
   - Install .config/zen/user.js from this repo into the active Zen profile
     (find it in ~/.zen/profiles.ini). Adjust dom.ipc.processCount to the real
     RAM: 4 at 16 GB, 2-3 at 8 GB. Keep browser.tabs.unloadOnLowMemory true.
   - Check about:support that hardware video decode and WebRender are active.
     If the GPU is not AMD, drop the radeonsi-specific force-enabled prefs
     rather than forcing them on an untested driver.
d. Shell startup
   - Time it: `for i in 1 2 3 4 5; do /usr/bin/time -f %e zsh -i -c exit; done`.
     If it is over ~0.3 s, profile with zmodload zsh/zprof and fix the slowest
     part (lazy-load nvm/bun/completions, drop unused oh-my-zsh plugins).
e. CPU
   - Confirm power-profiles-daemon works and which profile is active.
   - Check the CPU frequency driver (amd-pstate-epp / intel_pstate) is active.
   - Look for any process using CPU while the desktop is idle (top over 30 s
     with nothing open) and fix or report it.

Step 3: Performance mode
Create ~/.local/bin/perf-mode (bash, `set -euo pipefail`) with on, off, toggle
and status subcommands. Keep it in this repo at .local/bin/perf-mode.
"on" must, without sudo:
- Hyprland, at runtime only via hyprctl keyword, never by editing the config:
  animations:enabled 0, decoration:rounding 0, misc:vfr 1. Record the previous
  values with hyprctl getoption first so "off" restores exactly those.
- powerprofilesctl set performance on AC, keep balanced on battery (read
  /sys/class/power_supply/*/online).
- Freeze idle-time extras that do nothing while you work: pause awww-daemon
  wallpaper animation if any, and stop any optional user services the
  baseline flagged.
- Put agent sessions and the browser into their own systemd user scopes with
  limits, so neither can starve the other. Example:
  `systemd-run --user --scope -p MemoryHigh=<x> -p CPUWeight=<y> <cmd>`
  Provide wrapper commands (e.g. `perf-run agent claude`, `perf-run browser zen`)
  and pick MemoryHigh from the measured baseline and real RAM, not a fixed
  number. MemoryHigh throttles; never use MemoryMax here because it kills.
- Write state to ~/.local/state/perf-mode/state so status and off are exact.
"off" restores every saved value. "status" prints the mode, the active power
profile, the Hyprland values, and current RSS per app group.
- Add a keybind in .config/hypr/hyprland.lua that matches the existing style,
  e.g. hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("~/.local/bin/perf-mode toggle")),
  and send a notify-send message on each switch. Check the key combination is
  not already bound in hyprland.lua first.

Step 4: Verify and report
- Re-run the Step 1 measurements under the same load with performance mode on.
- Write ~/.local/state/perf-mode/report.md with a before/after table (total
  used RAM, swap/zram use, memory PSI, top 10 processes, per-app totals, idle
  CPU %), the list of every change, and the exact revert steps for each one.
- Report anything you found but did not change, and why.
````

## Reverting

Every change the prompt makes is backed up under
`~/.local/state/perf-mode/backups/<timestamp>/`, and the agent's report lists
the revert command for each one. `perf-mode off` undoes the runtime part. The
system-level pieces (zram, sysctl, systemd-oomd) are separate files in
`/etc/systemd/` and `/etc/sysctl.d/` and can be removed on their own.
