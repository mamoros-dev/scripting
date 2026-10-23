#!/bin/bash
set -euo pipefail

printf "%s\n" "--- ANALIZANDO LOGS DEL SISTEMA ---"

# Contador de errores encontrados
contador_errores=0

while IFS= read -r linea; do
    
    # Usamos el operador =~ para buscar la palabra "ERROR" dentro de la línea
    if [[ "$linea" =~ ERROR ]]; then
        printf "[ALERTA] Línea sospechosa detectada -> %s\n" "$linea"
        contador_errores=$((contador_errores + 1)) # Incrementamos el contador
    fi

done < "app.log"

printf "Análisis finalizado. Total de errores críticos encontrados: %d\n" "$contador_errores"