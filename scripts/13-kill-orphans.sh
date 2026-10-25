#!/bin/bash
set -euo pipefail

# Analiza los procesos del sistema mediante ps, filtra los que superan el 50% de CPU y llevan más de 5 horas (18000 segundos) ejecutándose, y los elimina de forma segura.
printf "[INFO] Buscando procesos con >50%% CPU y >5 horas de ejecución...\n"

# ps -eo: pid, %cpu, etimes (tiempo transcurrido en segundos), comm (nombre)
# etimes de 5 horas = 5 * 3600 = 18000 segundos
ps -eo pid,%cpu,etimes,comm --sort=-%cpu | awk 'NR>1 {
    if ($2 > 50 && $3 > 18000) {
        print "Matando PID: " $1 " (Comando: " $4 " | CPU: " $2 "% | Tiempo: " $3 "s)"
        system("kill -9 " $1)
    }
}'

printf "[OK] Auditoría y limpieza de procesos finalizada.\n"