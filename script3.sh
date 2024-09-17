#!/bin/bash

# Verificar que se ha pasado un ejecutable como parámetro
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <ejecutable>"
    exit 1
fi

EJECUTABLE=$1
LOGFILE="monitor.log"
INTERVALO=5  # Intervalo en segundos entre lecturas

# Verificar si el ejecutable existe
if [ ! -x "$EJECUTABLE" ]; then
    echo "El archivo $EJECUTABLE no es un ejecutable o no existe."
    exit 1
fi

# Ejecutar el binario en segundo plano
"$EJECUTABLE" &
PID=$!

# Esperar un momento para asegurar que el proceso se inicie
sleep 5

# Encontrar el PID del proceso principal basado en el nombre del ejecutable
PID=$(pgrep -o -x "$(basename "$EJECUTABLE")")

if [ -z "$PID" ]; then
    echo "No se pudo encontrar el PID del proceso principal de $(basename "$EJECUTABLE")."
    exit 1
fi

echo "Monitoreando el proceso con PID $PID..."

# Borrar el archivo de log si existe
> "$LOGFILE"

# Monitorear el proceso
while kill -0 "$PID" 2>/dev/null; do
    USO_CPU=$(ps -p "$PID" -o %cpu=)
    USO_MEMORIA=$(ps -p "$PID" -o %mem=)
    TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$TIMESTAMP $USO_CPU $USO_MEMORIA" >> "$LOGFILE"
    sleep "$INTERVALO"
done

echo "El proceso ha terminado. Generando gráfico..."

# Crear un archivo de script para gnuplot
GNUPLOT_SCRIPT="grafico.gnuplot"

cat <<EOL > "$GNUPLOT_SCRIPT"
set terminal pngcairo
set output 'grafico.png'
set title 'Consumo de CPU y Memoria de $(basename "$EJECUTABLE")'
set xlabel 'Tiempo'
set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'  # Definir el formato de tiempo en los datos de entrada
set format x '%H:%M:%S'          # Mostrar solo la hora en el eje X
set ylabel 'Uso de CPU (%)'
set y2label 'Uso de Memoria (%)'
set y2tics
set grid
set autoscale

# Graficar los datos
plot '$LOGFILE' using 1:2 axes x1y1 with lines title 'Uso de CPU', \
     '' using 1:3 axes x1y2 with lines title 'Uso de Memoria'

EOL

# Generar el gráfico
gnuplot "$GNUPLOT_SCRIPT"

echo "Gráfico generado como grafico.png"
