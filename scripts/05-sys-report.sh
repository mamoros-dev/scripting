#!/bin/bash
set -euo pipefail

# Usa comandos nativos de Linux que ya deberías conocer de tu experiencia como SysAdmin
# df -h, free -h, uptime, o top/ps).
# Haz que el script redirija toda esa información hacia un fichero reporte-sistema.txt.
# REPORT="05-system-report.txt"
REPORT="05-system-report-$(date +%Y%m%d-%H%M%S).txt"

printf "[INFO] CREANDO REPORTE DE SYSTEMA #\n"

{
    printf "========================================\n"
    printf " REPORTE DE ESTADO DEL SISTEMA\n"
    printf " Fecha: %s\n" "$(date)"
    printf "========================================\n\n"

    printf "# 1. DISK FREE #\n"
    df -h
    printf "\n"

    printf "# 2. MEMORY FREE #\n"
    free -h
    printf "\n"

    printf "# 3. SYSTEM UPTIME #\n"
    uptime
    printf "\n"

    printf "# 4. TOP PROCESSES #\n"
    # "Top 10" de los procesos que más memoria RAM están consumiendo
    ps aux --sort=-%mem | head -n 10
    printf "\n"
}> "$REPORT"  # <--- Redirigimos TODO el bloque al archivo de una sola vez (sobrescribiéndolo)

printf "[INFO] REPORTE DE SYSTEMA FINALIZADO! Guardado en %s\n" "$REPORT"