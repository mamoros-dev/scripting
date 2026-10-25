#!/bin/bash
set -euo pipefail

printf "%s\n" "--- 1. IDENTIFICANDO VERSIÓN ACTUAL ---"
VERSION_ACTUAL=$(cat 04-current/index.html)
printf "Versión en producción: %s\n\n" "$VERSION_ACTUAL"

printf "%s\n" "--- 2. SIMULANDO DESPLIEGUE DE LA NUEVA VERSIÓN ---"
# Copiamos la nueva versión (v2) a la carpeta current para probarla
cp 04-releases/v2/index.html 04-current/index.html

printf "%s\n" "--- 3. COMPROBACIÓN DE SALUD (HEALTH CHECK) ---"
# Simulamos una prueba: leemos el index.html buscando la palabra ERROR
if grep -q "ERROR" 04-current/index.html; then
    printf "[¡ALERTA!] La nueva versión ha fallado la prueba de salud.\n"
    printf "\n--- 4. EJECUTANDO ROLLBACK AUTOMÁTICO ---\n"
    
    # Restauramos la versión 1 estable
    echo "Hola, soy la version 1 ESTABLE" > 04-current/index.html
    
    printf "[ROLLBACK EXITOSO] El sistema ha vuelto a la versión estable anterior.\n"
    exit 1
else
    printf "[ÉXITO] Despliegue completado correctamente.\n"
fi