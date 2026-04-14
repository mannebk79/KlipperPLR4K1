#!/bin/sh
# K1/K1C optimized Uninstallation Script for KlipperPLR

PRINTER_DATA_DIR="/usr/data/printer_data"
KLIPPER_DIR="/usr/share/klipper"
CONFIG_DIR="$PRINTER_DATA_DIR/config"
PLR_BIN_DIR="$PRINTER_DATA_DIR/plr"

echo "Starte Deinstallation von KlipperPLR..."

# 1. Shell-Erweiterung entfernen
echo "Entferne gcode_shell_command..."
rm -f "$KLIPPER_DIR/klippy/extras/gcode_shell_command.py"

# 2. Skripte und temporäre Dateien entfernen
echo "Lösche PLR-Verzeichnisse..."
rm -rf "$PLR_BIN_DIR"
rm -rf "$PRINTER_DATA_DIR/gcodes/plr"

# 3. Konfigurationsdatei entfernen
echo "Entferne plr.cfg..."
rm -f "$CONFIG_DIR/plr.cfg"

echo "-------------------------------------------------------"
echo "Deinstallation abgeschlossen!"
echo "WICHTIG: Bitte entferne folgende Zeilen manuell aus deiner printer.cfg:"
echo "1. [include plr.cfg]"
echo "2. Den [save_variables] Block"
echo ""
echo "Danach Klipper neustarten: /etc/init.d/S55klipper_service restart"
echo "-------------------------------------------------------"
