# Klipper Power Loss Recovery (PLR) - Creality K1 Edition

Dieser Fork des BigTreeTech KlipperPLR-Systems wurde speziell für die **Creality K1-Serie (K1, K1 Max, K1C)** optimiert. Er behebt Pfadprobleme, Inkompatibilitäten mit der BusyBox-Umgebung und verbessert die Performance auf dem K1-SoC.

## Features
- **K1-Native Pfade:** Voll kompatibel mit `/usr/data/printer_data`.
- **Schnelle Recovery:** Nutzt optimierte Vorwärts-Suche statt langsamer `tac`-Befehle.
- **Auto-Temperatur:** Erkennt Temperaturen automatisch aus Slicer-Makros (`START_PRINT`) oder Standard-G-Code.
- **Exclude Object:** Erhält die Objekt-Abwahl auch in der Rettungsdatei.
- **Sicherer Ablauf:** Automatisches X/Y-Homing nach einem Sicherheits-Z-Hop.

## Installation (SSH erforderlich)

1. Verbinde dich per SSH mit deinem Drucker.
2. Klone das Repository in deinen Config-Ordner:
   ```bash
    cd /usr/data/printer_data/config
    git clone https://github.com PLR
    cd PLR
    chmod +x install.sh
    ./install.sh
   ```

## Konfiguration

1. printer.cfg
   
- Füge folgende Zeilen zu deiner printer.cfg hinzu:

    ```gcode
    [include plr.cfg]
    
    [save_variables]
    filename: /usr/data/printer_data/config/variables.cfg
    ```

2. Slicer-Einstellungen

- Damit der Drucker die Position speichert, muss im Slicer (Orca, Creality Print etc.) unter "G-Code vor Schichtwechsel" (Before Layer Change G-Code) folgendes stehen:

    ```gcode

    LOG_Z
    ```

## Benutzung im Ernstfall (Recovery)

Falls der Strom ausgefallen ist oder der Drucker über den Hauptschalter ausgeschaltet wurde, während ein Druck lief:

⚠️ WICHTIG: Die Z-Achse (Betthöhe) darf nach dem Ausschalten nicht manuell verstellt werden! Die X- und Y-Achsen werden automatisch neu referenziert, aber die Z-Höhe basiert rein auf dem zuletzt gespeicherten Wert.

Ablauf der Wiederherstellung:

1. Start: Drucker einschalten und warten, bis das Webinterface (Mainsail/Fluidd) geladen ist.
2. Befehl: In der Konsole den Befehl `RESUME_INTERRUPTED` eingeben.
3. **Automatischer Ablauf:**
   - Thermo-Management: Das Skript extrahiert die Soll-Temperaturen aus dem G-Code. Zuerst heizt das Bett auf, um die Haftung des Modells zu reaktivieren.
   - Sicherheits-Check: Der Drucker setzt die Z-Position virtuell und hebt den Kopf um 5mm an (Sicherheitsabstand zum Modell).
   - Kalibrierung: Es erfolgt ein Homing für X und Y, um Schrittverluste durch den Stromausfall auszugleichen.
   - Finales Aufheizen: Sobald die Düse ihre Zieltemperatur erreicht hat, fährt der Kopf auf die Abbruch-Höhe.
   - Fortsetzung: Der Drucker startet den G-Code genau am Anfang des Layers, in dem er unterbrochen wurde.

💡 Was während der ersten Schicht zu beachten ist:

Da der Stromausfall meistens mitten in einer Schicht passiert, das Skript den Druck aber am Anfang dieser Schicht (Layer-Start) wieder aufnimmt, ergeben sich zwei Besonderheiten:

   - Doppelter Materialauftrag: Der Drucker fährt die Linien, die er vor dem Abbruch bereits gedruckt hat, noch einmal ab. Da dort bereits erkaltetes Plastik liegt, kann die Düse leichte Schleifgeräusche machen. Das ist normal und hört auf, sobald der Drucker den eigentlichen Abbruchpunkt erreicht hat.
   - Z-Offset Feintuning: Je nachdem, wie stark das Material beim Abkühlen geschrumpft ist, kann es nötig sein, das Z-Offset während der ersten 1-2 Runden minimal (0.05 - 0.1mm) nach zu justieren, um die Düse zu schonen, schäden am Druck zu vermeiden, etc.

##  Schlusswort & Feedback

Dieses Projekt ist aus der Praxis für die Praxis entstanden. 

Mein Creality K1C läuft aktuell auf der Firmware-Version 1.3.3.46 und wurde mithilfe des Helper-Scripts von Guilouz https://github.com/Guilouz/Creality-Helper-Script-Wiki vollständig "entbrandet".

Durch das Deaktivieren der Creality-Dienste und die Nutzung einer reinen Klipper-Umgebung mit Moonraker, Mainsail/Fluidd und GuppyScreen bot mir dieser PLR-Fork die bestmögliche Stabilität und Performance für Power-Loss-Resume bzw. Hauptschalter-Aus Notfall Situationen.

Ich freue mich über Feedback, Verbesserungsvorschläge oder Fehlerberichte aus der Community! 

Wenn ihr Optimierungen für die K1-Serie habt, lasst es mich wissen oder öffnet einen Pull-Request.

Viel Erfolg bei euren Drucken – und keine Panik mehr beim nächsten Stromausfall!
