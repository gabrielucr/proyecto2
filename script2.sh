#!/bin/bash

# Verifica si se pasaron los argumentos correctos
if [ $# -lt 2 ]; then
  echo "Uso: $0 <nombre_del_proceso> <comando_para_ejecutar>"
  exit 1
fi

# Variables
nombre_proceso=$1
comando_ejecutar=$2

# Función para verificar si el proceso está corriendo
esta_corriendo() {
  pgrep -x "$nombre_proceso" > /dev/null
  return $?
}

# Bucle infinito para monitorear el proceso
while true; do
  # Revisa si el proceso está corriendo
  if ! esta_corriendo; then
    echo "El proceso '$nombre_proceso' no está corriendo. Reiniciando..."
    # Ejecuta el comando para reiniciar el proceso
    $comando_ejecutar &
    echo "Proceso '$nombre_proceso' reiniciado."
  else
    echo "El proceso '$nombre_proceso' está corriendo."
  fi
  
  # Espera 10 segundos antes de volver a revisar
  sleep 10
done
