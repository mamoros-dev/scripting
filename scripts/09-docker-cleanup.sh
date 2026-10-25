#!/bin/bash
set -euo pipefail

printf "### LIMPIANDO DOCKER.... ###\n"

printf "[INFO] limpiando residuos...\n"
docker system prune -f --volumes

printf "### LIMPIEZA FINALIZADA CON ÉXITO! ###\n"