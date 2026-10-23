#!/bin/bash
set -euo pipefail

printf "%s\n" "--- BUSCANDO INSTANCIAS PARADAS EN AWS ---"

# Ejecutamos el comando de AWS y lo canalizamos directamente a jq
ids_paradas=$(aws ec2 describe-instances --output json | jq -r '.Reservations[].Instances[] | select(.State.Name == "stopped") | .InstanceId')

if [[ -z "$ids_paradas" ]]; then
    printf "%s\n" "No hay ninguna instancia parada."
else
    printf "Instancias encontradas para arrancar:\n%s\n" "$ids_paradas"
fi
