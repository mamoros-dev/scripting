#!/bin/bash
set -euo pipefail
printf "%s\n" "--- ANALIZANDO LOGS ---"
# Buscar en la carpeta logs/ aquellos ficheros que tengan una antigüedad superior a X días 
# Mostrar un mensaje indicando qué fichero se va a limpiar o borrar.
find ./03-logs/ -type f -mtime +7 | while IFS= read -r file; do
    printf "[INFO - DELETE]Borrando el fichero ---> %s\n" "$file"
    rm -f "$file"
done
printf "%s\n" "--- ANALISIS DE LOGS TERMINADO ---"
