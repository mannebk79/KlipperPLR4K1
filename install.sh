#!/bin/sh
# K1/K1C optimized Installation Script for KlipperPLR
# Use this script to install KlipperPLR on Creality K1 Series printers

# Define paths for K1 Series
PROJECT_DIR=$(pwd)
PRINTER_DATA_DIR="/usr/data/printer_data"
KLIPPER_DIR="/usr/share/klipper"
CONFIG_DIR="$PRINTER_DATA_DIR/config"
PLR_BIN_DIR="$PRINTER_DATA_DIR/plr"

echo "Starting Installation for Creality K1 Series..."

# 1. Create necessary directories
mkdir -p "$PLR_BIN_DIR"
mkdir -p "$PRINTER_DATA_DIR/gcodes/plr"

# 2. Install Shell Command extension for Klipper
# On K1, Klipper extras are located in /usr/share/klipper
echo "Installing gcode_shell_command.py..."
if [ -d "$KLIPPER_DIR/klippy/extras" ]; then
    cp "$PROJECT_DIR/gcode_shell_command.py" "$KLIPPER_DIR/klippy/extras/"
else
    echo "Error: Klipper extras directory not found!"
    exit 1
fi

# 3. Copy scripts and set execution permissions
echo "Copying PLR scripts to $PLR_BIN_DIR..."
cp "$PROJECT_DIR/plr.sh" "$PLR_BIN_DIR/"
cp "$PROJECT_DIR/clear_plr.sh" "$PLR_BIN_DIR/"
chmod +x "$PLR_BIN_DIR/"*.sh

# 4. Prepare and patch plr.cfg
echo "Configuring plr.cfg..."
cp "$PROJECT_DIR/plr.cfg" "$CONFIG_DIR/plr.cfg"

# Replace placeholders with actual K1 paths
sed -i "s|{USER_HOME}/printer_data|$PRINTER_DATA_DIR|g" "$CONFIG_DIR/plr.cfg"
sed -i "s|{PLR_DIR}|$PLR_BIN_DIR|g" "$CONFIG_DIR/plr.cfg"
sed -i "s|{USER_HOME}/printer_data|$PRINTER_DATA_DIR|g" "$PLR_BIN_DIR/plr.sh"
sed -i "s|{USER_HOME}/printer_data|$PRINTER_DATA_DIR|g" "$PLR_BIN_DIR/clear_plr.sh"

# 5. Ensure variables.cfg exists
if [ ! -f "$CONFIG_DIR/variables.cfg" ]; then
    echo "[Variables]" > "$CONFIG_DIR/variables.cfg"
    echo "Created initial variables.cfg"
fi

echo "-------------------------------------------------------"
echo "Installation complete!"
echo "1. Ensure '[include plr.cfg]' is added to your printer.cfg"
echo "2. Add '[save_variables]' block to your printer.cfg if not present:"
echo "   [save_variables]"
echo "   filename: /usr/data/printer_data/config/variables.cfg"
echo ""
echo "Restart Klipper with: /etc/init.d/S55klipper_service restart"
echo "-------------------------------------------------------"
