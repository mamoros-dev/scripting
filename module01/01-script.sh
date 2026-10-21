#!/bin/bash

# Declare una variable llamada ENVIRONMENT con el valor production.
ENVIRONMENT="production"

# Declare una variable llamada SERVER_IP que obtenga dinámicamente la IP local de la máquina (puedes usar el comando hostname -I o ip route).
SERVER_IP=$(hostname -I | awk '{print $1}')

# Muestre un mensaje por pantalla con el siguiente formato exacto:
#[INFO] Generando reporte para el entorno: [valor_de_variable] en la IP [valor_de_variable]
printf "[INFO] Generando reporte para el entorno: %s en la IP %s\n" "$ENVIRONMENT" "$SERVER_IP"
echo "[INFO] Generando reporte para el entorno: $ENVIRONMENT en la IP $SERVER_IP\n"
echo -e "[INFO] Generando reporte para el entorno: $ENVIRONMENT en la IP $SERVER_IP\n"

# Resultado:
# bash module01/01-script.sh 
# [INFO] Generando reporte para el entorno: production en la IP 172.30.209.255
# [INFO] Generando reporte para el entorno: production en la IP 172.30.209.255\n
# [INFO] Generando reporte para el entorno: production en la IP 172.30.209.255

# scripting (main) ❯ 