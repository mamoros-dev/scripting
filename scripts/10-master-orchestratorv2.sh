#!/bin/bash
set -euo pipefail

printf "### ORQUESTADOR DE SCRIPTS MAESTRO ###\n\n"

# Definimos todos los scripts en orden estricto de ejecución dentro de un array
SCRIPTS=(
    "./01-script-env-validatorv2.sh"
    "./02-script-health-checker.sh"
    "./03-log-rotatorv2.sh"
    "./04-secure-deploy.sh"
    "./05-sys-report.sh"
    "./06-log-error-searcher.sh"
    "./07-aws-resource-extractor.sh"
    "./08-auto-backup.sh"
    "./09-docker-cleanupv2.sh"
)

# Recorremos el array de forma limpia y automatizada
for script in "${SCRIPTS[@]}"; do
    printf "[INFO] Ejecutando: %s ...\n" "$script"
    
    # Comprobamos si el script existe y es ejecutable antes de lanzarlo
    if [[ -x "$script" ]]; then
        # ejecuta el script
        if "$script"; then
            printf "[OK] %s completado con éxito.\n\n" "$script"
        else
            printf "[ERROR] El script %s devolvió un código de error. Abortando orquestación.\n" "$script"
            exit 1
        fi
    else
        printf "[ERROR] El fichero %s no existe o no tiene permisos de ejecución (+x).\n" "$script"
        exit 1
    fi
done

printf "### ¡ORQUESTADOR FINALIZADO CON ÉXITO TOTAL! ###\n"