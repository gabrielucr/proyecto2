#!/bin/bash

# Directorio a monitorear
DIRECTORIO="/home/gabriel/monitor"

# Archivo de log
LOGFILE="$DIRECTORIO/log.txt"

# Comando inotifywait para monitorear el directorio
inotifywait -m -e create -e modify -e delete --exclude 'log.txt' "$DIRECTORIO" | while read path action file; do
    echo "$(date): $action en $file" >> "$LOGFILE"
done

