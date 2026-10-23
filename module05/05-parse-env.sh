#!/bin/bash

set -euo pipefail

# ejercicio leyendo y procesando linea a linea
while IFS= read -r linea; do
    printf "[CONFIG] Leído -> %s\n" "$linea"
done < "file.env"

# ejercicio leyendo y procesando linea a linea, separando la linea con clave/valor
while IFS='=' read -r clave valor; do
    printf "Clave detectada: %s con valor: %s\n" "$clave" "$valor"
done < "file.env"

## ejercicio leyendo y procesando linea a linea, obviando lineas comentadas
printf "### INICIO DEL PROCESAMIENTO LIMPIO ###\n"
while IFS='=' read -r clave valor; do
    
    # 1. Filtro: Si la línea está vacía, sáltala
    [[ -z "$clave" ]] && continue
    
    # 2. Filtro: Si la clave empieza por '#', es un comentario, sáltala
    # Usamos "=~" que es el operador de expresiones regulares (significa "empieza por #")
    [[ "$clave" =~ ^# ]] && continue

    # Si pasa los filtros, procesamos la clave y el valor de forma limpia
    printf "Configuración válida -> Clave: [%s] | Valor: [%s]\n" "$clave" "$valor"

done < "file.env"