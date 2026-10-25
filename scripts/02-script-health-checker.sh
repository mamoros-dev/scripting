#!/bin/bash
set -euo pipefail

printf "%s\n" "--- ANALIZANDO LAS URLs ---"
while IFS= read -r linea; do 

    # 1. Filtros de líneas vacías o comentarios
    [[ -z "$linea" ]] && continue
    [[ "$linea" =~ ^# ]] && continue

    # 2. Para averiguar el código HTTP con curl de forma limpia y silenciosa
    # 200 OK o 301/302 Redireccion OK (-L)
    # si quieres usar como user-agent se añade -A "Mozilla/5.0"
    # para esperar más tiempo --max-time 5
    code=$(curl -s -L -o /dev/null -w "%{http_code}\n" "$linea")

    # Evalúa con un if si el código devuelto es 200 (éxito) u otro valor (error/caído).
    if [[ "$code" == 200 ]]; then
        printf "[INFO - OK] El código devuelto es 200\n"
    else
        # --- AQUÍ ENTRA EL WEBHOOK REAL ---
        # Enviamos una alerta instantánea a un canal de Slack o Discord
        # curl -s -X POST -H 'Content-Type: application/json' \
        #      -d '{"content": "🚨 ¡ALERTA DE PRODUCCIÓN! La web '"$linea"' devolvió el código '"$code"'"}' \
        #      "https://discord.com/api/webhooks/tu-url-secreta-aqui"
        printf "[ERROR] La web %s tiene un código de error o caído. El valor es %d\n" "$linea" "$code"
        exit 1
    fi
done < "02-urls.txt"
printf "%s\n" "--- VALIDACIÓN COMPLETADA CON ÉXITO ---"