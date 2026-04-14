#!/bin/sh
# K1/K1C optimized Clear PLR Script
PLR_GCODE_DIR="/usr/data/printer_data/gcodes/plr"

if [ -d "$PLR_GCODE_DIR" ]; then
    rm -rf "$PLR_GCODE_DIR"/*
    echo "PLR recovery files cleared."
else
    echo "No PLR files to clear."
fi
