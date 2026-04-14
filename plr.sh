#!/bin/sh
# K1/K1C optimized PLR Script

GCODE_DIR="/usr/data/printer_data/gcodes"
PLR_DIR="$GCODE_DIR/plr"
Z_HEIGHT=$1
FILE_NAME=$2

FULL_PATH="$GCODE_DIR/$FILE_NAME"
TARGET_PATH="$PLR_DIR/$FILE_NAME"
mkdir -p "$(dirname "$TARGET_PATH")"

# Extrahierung der Temperaturen aus START_PRINT oder M104/M140
EXTRUDER_TEMP=$(grep "START_PRINT" "$FULL_PATH" | sed -n 's/.*EXTRUDER_TEMP=\([0-9]*\).*/\1/p' | head -n 1)
BED_TEMP=$(grep "START_PRINT" "$FULL_PATH" | sed -n 's/.*BED_TEMP=\([0-9]*\).*/\1/p' | head -n 1)

# Fallback Suche
if [ -z "$EXTRUDER_TEMP" ] || [ "$EXTRUDER_TEMP" = "0" ]; then
    EXTRUDER_TEMP=$(grep "M10 S" "$FULL_PATH" | grep -v "S0" | sed -n 's/.*S\([0-9]*\).*/\1/p' | head -n 1)
fi
if [ -z "$BED_TEMP" ] || [ "$BED_TEMP" = "0" ]; then
    BED_TEMP=$(grep "M14 S" "$FULL_PATH" | grep -v "S0" | sed -n 's/.*S\([0-9]*\).*/\1/p' | head -n 1)
fi

# Fallback Standards
[ -z "$BED_TEMP" ] || [ "$BED_TEMP" = "0" ] && BED_TEMP=65
[ -z "$EXTRUDER_TEMP" ] || [ "$EXTRUDER_TEMP" = "0" ] && EXTRUDER_TEMP=250

SAFE_Z=$(echo "$Z_HEIGHT + 5" | bc)

# Header-Erstellung
echo "; PLR RECOVERY START FOR K1 SERIES" > "$TARGET_PATH"
grep "EXCLUDE_OBJECT_DEFINE" "$FULL_PATH" >> "$TARGET_PATH"
echo "M140 S$BED_TEMP" >> "$TARGET_PATH"
echo "SET_KINEMATIC_POSITION Z=$Z_HEIGHT" >> "$TARGET_PATH"
echo "G90" >> "$TARGET_PATH"
echo "G1 Z$SAFE_Z F600" >> "$TARGET_PATH"
echo "G28 X Y" >> "$TARGET_PATH"
echo "M190 S$BED_TEMP" >> "$TARGET_PATH"
echo "M109 S$EXTRUDER_TEMP" >> "$TARGET_PATH"
echo "M83" >> "$TARGET_PATH"
echo "G1 Z$Z_HEIGHT F600" >> "$TARGET_PATH"

# Daten-Schnitt (Vorwärts-Suche für Geschwindigkeit auf dem K1)
sed -n "/G1.*Z$Z_HEIGHT/,\$p" "$FULL_PATH" >> "$TARGET_PATH"
