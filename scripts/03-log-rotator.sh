#!/bin/bash
set -euo pipefail

# Buscar en la carpeta logs/ aquellos ficheros que tengan una antigüedad superior a X días 
printf "%s\n" "--- ANALIZANDO LOGS ---"
FILES=$(find ./03-logs/ -type f -mtime +7) # solo sirve si los ficheros son sin espacios. sino v2 siempre

[[ -z "$FILES" ]] && printf "No hay archivos tan antiguos\n" && exit 0

# Mostrar un mensaje indicando qué fichero se va a limpiar o borrar.
for file in $FILES; do
    printf "[INFO - DELETE]Borrando el fichero ---> %s\n" "$file"
    printf "echo rm -rf %s\n" "$file"
done
