#!/bin/bash
set -euo pipefail

printf "%s\n" "--- AUDITANDO PODS EN KUBERNETES ---"

# Extraemos el nombre de los pods cuyo estado no sea "Running" o "Completed"
pods_problematicos=$(kubectl get pods -n production -o json | jq -r '.items[] | select(.status.phase != "Running" and .status.phase != "Completed") | .metadata.name')

if [[ -z "$pods_problematicos" ]]; then
    printf "%s\n" "¡Todo perfecto! No hay pods con problemas."
else
    printf "[ALERTA] Se han detectado los siguientes pods con incidencias:\n%s\n" "$pods_problematicos"
fi
