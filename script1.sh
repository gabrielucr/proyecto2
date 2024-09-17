#!/bin/bash

# Verificar que se haya proporcionado un ID de proceso
if [ "$#" -ne 1 ]; then
  echo "Uso: $0 <ID del proceso>"
  exit 1
fi

PID=$1

# Verificar que el ID del proceso sea numérico
if ! [[ "$PID" =~ ^[0-9]+$ ]]; then
  echo "Error: El ID del proceso debe ser un número."
  exit 1
fi

# Comprobar si el proceso existe
if ! ps -p "$PID" > /dev/null 2>&1; then
  echo "Error: El proceso con ID $PID no existe."
  exit 1
fi

# Obtener la información del proceso
NAME=$(ps -p "$PID" -o comm=)
PPID=$(ps -p "$PID" -o ppid=)
USER=$(ps -p "$PID" -o uname=)
CPU=$(ps -p "$PID" -o %cpu=)
MEMORY=$(ps -p "$PID" -o %mem=)
STATUS=$(ps -p "$PID" -o stat=)
EXEC_PATH=$(readlink -f /proc/$PID/exe)

# Imprimir la información
echo "Nombre del proceso: $NAME"
echo "ID del proceso: $PID"
echo "Parent process ID: $PPID"
echo "Usuario propietario: $USER"
echo "Porcentaje de uso de CPU: $CPU"
echo "Consumo de memoria: $MEMORY"
echo "Estado (status): $STATUS"
echo "Path del ejecutable: $EXEC_PATH"

