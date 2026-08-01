# Manual installs (non-pacman/AUR)

Tools installed outside pacman/yay — not covered by `pkglist.txt`/`aurlist.txt`.
Rerun the install command to restore on a fresh machine.

## herdr
Terminal agent multiplexer (tmux-style panes for coding agents, detach/reattach, socket API). https://herdr.dev

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

Installs to `~/.local/bin/herdr` (already on `$PATH` via `.zshrc`). No shell rc changes needed.
