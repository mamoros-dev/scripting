#!/bin/bash
set -euo pipefail

# Realiza una petición curl a una API pública y extrae quirúrgicamente un campo específico usando jq.
API_URL="https://api.ipify.org?format=json"

printf "[INFO] Consultando IP pública...\n"
PUBLIC_IP=$(curl -s "$API_URL" | jq -r '.ip')

printf "[OK] IP Pública obtenida con éxito: %s\n" "$PUBLIC_IP"