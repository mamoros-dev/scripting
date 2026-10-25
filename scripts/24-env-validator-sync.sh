#!/bin/bash
set -euo pipefail

# Comprueba que todas las variables de .env.example existan en el .env real.
while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    var_name=$(echo "$line" | cut -d '=' -f 1)
    if ! grep -q "^$var_name=" .env; then
        printf "[ALERTA] La variable %s falta en el fichero .env de producción\n" "$var_name"
    fi
done < .env.example