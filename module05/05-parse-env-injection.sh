#!/bin/bash
set -euo pipefail

printf "### CARGANDO CONFIGURACIÓN DESDE .ENV ###\n"

while IFS='=' read -r clave valor; do
    
    # 1. Filtro: Si la línea está vacía, sáltala
    [[ -z "$clave" ]] && continue
    
    # 2. Filtro: Si empieza por '#', es un comentario, sáltala
    [[ "$clave" =~ ^# ]] && continue

    # 3. Inyección dinámica: Convertimos texto plano en una variable real de Bash
    declare "${clave}=${valor}"
    
    printf "Inyectada con éxito -> Variable: [%s] = [%s]\n" "$clave" "$valor"

done < "file.env"

printf "\n--- COMPROBANDO QUE LAS VARIABLES FUNCIONAN ---\n"
# Ahora podemos usar las variables directamente como si hubieran estado siempre ahí
printf "\n-> DB_HOST actual: %s\n" "$DB_HOST"
printf "\n-> DB_PORT actual: %s\n" "$DB_PORT"
printf "\n-> DB_NAME actual: %s\n" "$DB_NAME"