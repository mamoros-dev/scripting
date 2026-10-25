#!/bin/bash
set -euo pipefail
FILE="06-app.log"

# OPCION DIRECTA CONTADOR
errors_found=$(grep -i -E "ERROR|CRITICAL" 06-app.log | wc -l)
printf "Ha encontrado un total de: %s errores\n" "$errors_found"
printf "%s\n" "--- DETALLE DE LOS ERRORES ---"
grep -i -E "ERROR|CRITICAL" "$FILE" | while IFS= read -r linea; do
    [[ -z "$linea" ]] && continue
    [[ "$linea" =~ ^# ]] && continue
    printf "[ERROR] %s\n" "$linea"
done
printf "%s\n" "--- ANÁLISIS TERMINADO ---"


###################################################

# OPCION PRINTANDO FALLO Y CONTADOR
contador=0
printf "%s\n" "--- ANALIZANDO LOGS ---"
while IFS= read -r linea; do
    # ignoramos lineas vacías o comentarios #
    [[ -z "$linea" ]] && continue
    [[ "$linea" =~ ^# ]] && continue

    printf "[ERROR] Hay un Error en: %s\n" "$linea"
    contador=$((contador + 1))
done < <(grep -i -E "ERROR|CRITICAL" "$FILE")
printf "Se han encontrado un total de: %d errores\n" "$contador"
printf "%s\n" "--- ANALISIS DE LOGS TERMINADO ---"