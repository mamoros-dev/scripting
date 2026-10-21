#!/bin/bash

# Crea un script llamado 03-check-config.sh que haga lo siguiente:

# Declare una variable llamada `CONFIG_FILE` con la ruta de un archivo simulado (por ejemplo, `/etc/app/config.env`).
CONFIG_FILE="/tmp/config.env" # Sí existe
CONFIG_FILE_ERROR="/tmp/config2.env" # No existe

# 1. Ejecutamos el test de archivo de forma independiente
[ -f "$CONFIG_FILE_ERROR" ]

# 2. Capturamos el código de salida INMEDIATAMENTE (aquí sí se guarda bien porque no hay asignaciones de por medio)
CONFIG_STATUS=$?

# 3. Ahora el if simplemente evalúa si nuestra variable numérica es 0 o distinta de 0
if [ "$CONFIG_STATUS" -eq 0 ]; then
    printf "El entorno está listo\n"
else
    printf "Error!! El entorno NO está listo y falta el fichero\n"
    printf "El código de error real devuelto fue: %d\n" "$CONFIG_STATUS"
fi