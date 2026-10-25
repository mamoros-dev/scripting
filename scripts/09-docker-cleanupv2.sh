#!/bin/bash
set -euo pipefail

LOG_FILE="09-docker-cleanup.log"

printf "[INFO] Iniciando auditoría y limpieza segura de Docker...\n"

# 1. Medir espacio en disco dedicado a Docker antes de limpiar
# ❯ docker system df
# TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
# Images          7         0         4.945GB   3.054GB (61%)
# Containers      0         0         0B        0B
# Local Volumes   2         0         370.8MB   370.8MB (100%)
# Build Cache     3         0         23.64MB   0B
espacio_antes=$(docker system df --format "{{.Size}}" | head -n 1)
printf "[INFO] Espacio ocupado por Docker ANTES: %s\n" "$espacio_antes"

# 2. Limpieza inteligente y segura:
# - Borramos contenedores detenidos hace más de 24 horas (evita borrar cosas de hace 5 minutos que alguien está revisando)
# - Borramos imágenes huérfanas (dangling)
printf "[INFO] Purgando contenedores detenidos (>24h) e imágenes huérfanas...\n"
docker container prune -f --filter "until=24h" > /dev/null
docker image prune -f > /dev/null

# (Opcional y peligroso: los volúmenes solo se tocan si hay política estricta, 
#  porque borrar volúmenes por error puede destruir bases de datos huérfanas pero necesarias).
# docker volume prune -f

# 3. Medir espacio después de la limpieza
espacio_despues=$(docker system df --format "{{.Size}}" | head -n 1)
printf "[INFO] Espacio ocupado por Docker DESPUÉS: %s\n" "$espacio_despues"

# 4. Registrar en el log de auditoría
printf "[%s] Limpieza ejecutada con éxito. Espacio antes: %s | Espacio después: %s\n" \
    "$(date '+%Y-%m-%d %H:%M:%S')" "$espacio_antes" "$espacio_despues" >> "$LOG_FILE"

printf "### MANTENIMIENTO DE DOCKER COMPLETADO CON ÉXITO ###\n"