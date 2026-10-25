#!/bin/bash
set -euo pipefail

# Lee un CSV y crea usuarios en el sistema Linux.
while IFS=, read -r username shell; do
    if id "$username" &>/dev/null; then
        printf "[SKIP] El usuario %s ya existe.\n" "$username"
    else
        sudo useradd -m -s "$shell" "$username"
        printf "[CREATED] Usuario %s creado.\n" "$username"
    fi
done < usuarios.csv