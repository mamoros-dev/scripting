#!/bin/bash
set -euo pipefail

printf "%s\n" "--- ANALIZANDO VARIABLES DE ENTORNO OBLIGATORIAS ---"

while IFS='=' read -r clave valor || [[ -n "$clave" ]]; do 

    # 1. Filtros de líneas vacías o comentarios
    [[ -z "$clave" ]] && continue
    [[ "$clave" =~ ^# ]] && continue

    # 2. Control de linea mal formada o variable sin asignar (DB_SOCKET o DB_SOCKET=)
    if [[ -z "${valor:-}" ]]; then
        printf "ERROR CRÍTICO: La variable [%s] no tiene ningún valor asignado (está vacía).\n" "$clave"
        exit 1
    fi

    # 3. Comprobar si es una de las 3 variables OBLIGATORIAS
    if [[ "$clave" == "DB_HOST" || "$clave" == "DB_PORT" || "$clave" == "DB_PASSWORD" ]]; then
        printf "[OK] Variable obligatoria detectada correctamente: %s = %s\n" "$clave" "$valor"
    else
        # Es una variable opcional o extra (ej: DB_USER)
        printf "[OK OPCIONAL] Variable detectada correctamente: %s = %s\n" "$clave" "$valor"
    fi  

done < "01-file.env"

printf "%s\n" "--- VALIDACIÓN COMPLETADA CON ÉXITO ---"