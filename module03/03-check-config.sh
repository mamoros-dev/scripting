#!/bin/bash

# Crea un script llamado 03-check-config.sh que haga lo siguiente:

# Declare una variable llamada `CONFIG_FILE` con la ruta de un archivo simulado (por ejemplo, `/etc/app/config.env`).
CONFIG_FILE="/tmp/config.env" # Sí existe
CONFIG_FILE_ERROR="/tmp/config2.env" # No existe


# Utilice una estructura condicional `if/else` junto con el operador de comprobación de ficheros adecuado `(-f)` para verificar si ese archivo existe físicamente en el sistema.
# `Si existe`, que imprima por pantalla un mensaje de éxito indicando que el entorno está listo y devuelva un código de salida exitoso.
# `Si no existe`, que imprima un mensaje de error crítico por pantalla avisando de que falta el fichero y termine la ejecución de forma controlada.
if [ -f "$CONFIG_FILE_ERROR" ]; then
    printf "El entorno está listo\n"
else
    printf "Error!! El entorno NO está listo y falta el fichero\n"
fi