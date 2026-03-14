# Hyprland Cava Underlay

A highly customized and optimized Layer Shell implementation of the [cava](https://github.com/karlstav/cava) audio visualizer perfectly anchored to the bottom of Kitty or Foot terminals in Hyprland.

This project modifies `wallpaper-cava` to accurately track single terminal windows per workspace, ensuring the visualizer gracefully underlays your terminal.

## Features
- Dynamic workspace tracking (supports `foot` and `kitty`).
- Zero window-drift custom anchoring system (Phase 8.4 Bottom Anchor).
- Dense 160-bar "One Dark" visualizer preset.
- Optimized active window busyness sensing via `cava-bg-daemon`.

## Prerequisites
- **Hyprland** (Wayland compositor)
- **Rust/Cargo** (for building the modified renderer)
- `jq`, `socat`, `fish`
- `pgrep` & `ps` (usually pre-installed via procps)

## Installation

An automated installation script is provided. Simply run:
```bash
./install.sh
```
This will compile the rust binary, move the daemon and configs to `~/.local/bin/` and `~/.config/hyprland-cava-underlay/`, and install the systemd service.

## Configuration Requirements

For the visualizer to be seen, your terminal **must have slight transparency** (e.g., `0.9` opacity) and you must have the appropriate `hyprland.conf` window rules to float and anchor the visualizer layer shell window.

### 1. Terminal Opacity
**Foot (`~/.config/foot/foot.ini`)**
```ini
alpha=0.9
```

**Kitty (`~/.config/kitty/kitty.conf`)**
```conf
background_opacity 0.9
```

### 2. Hyprland Window Rules
Add this to your `~/.config/hypr/hyprland.conf`:

```hyprlang
# Terminal Transparency
windowrule {
    name = foot-style
    match:class = ^(foot)
    opacity = 1.0 0.85 1.0
}
windowrule {
    name = kitty-style
    match:class = ^(kitty)$
    opacity = 1.0 0.85 1.0
}

# Cava Layer Rules
windowrule {
    name = cava-bg
    match:class = foot-cava-bg
    float = true
    rounding = 0
    border_size = 0
    focus_on_activate = false
    opacity = 1.0 override 1.0 override
}
```

## How It Works
The `cava-bg-daemon` (written in Fish) runs as a `systemd --user` service. It uses `socat` to listen to Hyprland's IPC socket for active window changes. When an isolated `foot` or `kitty` terminal is focused (and audio is actively playing via `pactl`/`asound`), it calculates the geometric bottom window margin and spawns the modified `wallpaper-cava` executable directly beneath the terminal.

## Acknowledgements
- Based on `wallpaper-cava` (A Rust layer-shell renderer for cava).
- Made with ❤️ alongside Antigravity AI.
