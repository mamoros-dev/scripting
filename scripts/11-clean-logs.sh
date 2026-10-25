#!/bin/bash
set -euo pipefail

# Busca logs con más de 7 días, los comprime en formato gzip para liberar espacio y verifica si el uso general del disco supera el 80% para lanzar una alerta visual.

LOG_DIR="/var/log"
DAYS=7

printf "[INFO] Buscando logs con más de %d días en %s...\n" "$DAYS" "$LOG_DIR"
find "$LOG_DIR" -name "*.log" -mtime "+$DAYS" -exec gzip {} \;

# Comprobar uso del disco raíz
USAGE=$(df / --output=pcent | tail -n 1 | tr -d ' %')
printf "[INFO] Uso actual del disco raíz: %s%%\n" "$USAGE"

if [ "$USAGE" -gt 80 ]; then
    printf "[ALERTA] ¡El disco está por encima del 80%% de su capacidad (%s%%)! Requiere atención.\n" "$USAGE"
else
    printf "[OK] Espacio en disco bajo control.\n"
fi
