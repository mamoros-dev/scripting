#!/bin/bash

set -euo pipefail

printf "%s\n" "--- ANALIZANDO VARIABLES DE ENTORNO OBLIGATORIAS ---"

# while IFS='=' read -r clave valor || [[ -n "$clave" ]]; do si el fichero no acaba con salto de linea
while IFS='=' read -r clave valor; do 

    # 1. Filtros de líneas vacías o comentarios
    [[ -z "$clave" ]] && continue
    [[ "$clave" =~ ^# ]] && continue

    # 2. Comprobar si es una de las 3 variables OBLIGATORIAS
    if [[ "$clave" == "DB_HOST" || "$clave" == "DB_PORT" || "$clave" == "DB_PASSWORD" ]]; then
        # Si es obligatoria, su valor NO puede estar vacío bajo ningún concepto
        if [[ -z "$valor" ]]; then
            printf "ERROR! La variable %s obligatoria está vacía\n" "$clave"
            exit 1
        else
            printf "[OK] Variable obligatoria detectada correctamente: %s = %s\n" "$clave" "$valor"
        fi
    else
        # Es una variable opcional o extra (ej: DB_USER)
        if [[ -z "$valor" ]]; then
            printf "ERROR! La variable opcional %s está vacía\n" "$clave"
            exit 2
        else
            printf "[OK OPCIONAL] Variable detectada correctamente: %s = %s\n" "$clave" "$valor"
        fi
    fi  
done < "01-file.env"
printf "%s\n" "--- VALIDACIÓN COMPLETADA CON ÉXITO ---"
