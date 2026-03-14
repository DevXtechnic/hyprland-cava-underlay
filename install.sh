#!/usr/bin/env bash

set -e

# Colors
GREEN='\032[0;32m'
BLUE='\032[0;34m'
RED='\032[0;31m'
NC='\032[0m'

echo -e "${BLUE}=== Hyprland Cava Underlay Installer ===${NC}"

# 1. Dependency Check
echo -e "\n${BLUE}[1/4] Checking dependencies...${NC}"
DEPENDENCIES=("cargo" "jq" "socat" "fish")
for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: Required command '$cmd' is not installed.${NC}"
        echo "Please install it using your system's package manager and run this script again."
        exit 1
    fi
done
echo -e "${GREEN}All dependencies met.${NC}"

# 2. Build the Renderer
echo -e "\n${BLUE}[2/4] Building modified wallpaper-cava (this may take a minute)...${NC}"
cd renderer || exit 1
cargo build --release
cd ..
echo -e "${GREEN}Build complete.${NC}"

# 3. Install Files
echo -e "\n${BLUE}[3/4] Installing files...${NC}"

BIN_DIR="$HOME/.local/bin"
CONF_DIR="$HOME/.config/hyprland-cava-underlay"
SYSTEMD_DIR="$HOME/.config/systemd/user"

mkdir -p "$BIN_DIR" "$CONF_DIR" "$SYSTEMD_DIR"

# Install binaries
cp renderer/target/release/wallpaper-cava "$BIN_DIR/"
cp daemon/cava-bg-daemon "$BIN_DIR/"
chmod +x "$BIN_DIR/wallpaper-cava" "$BIN_DIR/cava-bg-daemon"

# Install config
cp renderer/config.toml "$CONF_DIR/"

# Update daemon to reference the new config and binary paths
sed -i "s|/home/neo/.gemini/antigravity/scratch/wallpaper-cava-project/wallpaper-cava/target/release/wallpaper-cava|$BIN_DIR/wallpaper-cava|g" "$BIN_DIR/cava-bg-daemon"
sed -i "s|/home/neo/.gemini/antigravity/scratch/wallpaper-cava-project/wallpaper-cava/config.toml|$CONF_DIR/config.toml|g" "$BIN_DIR/cava-bg-daemon"

# Install systemd service
cp systemd/cava-background.service "$SYSTEMD_DIR/"
systemctl --user daemon-reload

echo -e "${GREEN}Files installed.${NC}"

# 4. Enable Service
echo -e "\n${BLUE}[4/4] Enabling and starting systemd service...${NC}"
systemctl --user enable --now cava-background.service
echo -e "${GREEN}Service 'cava-background.service' started.${NC}"

echo -e "\n${BLUE}=== Installation Complete! ===${NC}"
echo -e "Make sure you have added the required window rules to your Hyprland configuration."
echo -e "See ${GREEN}README.md${NC} for details."
