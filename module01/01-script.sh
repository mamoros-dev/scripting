#!/bin/bash

# Declare una variable llamada ENVIRONMENT con el valor production.
ENVIRONMENT="production"

# Declare una variable llamada SERVER_IP que obtenga dinámicamente la IP local de la máquina (puedes usar el comando hostname -I o ip route).
SERVER_IP=$(hostname -I | awk '{print $1}')

# Muestre un mensaje por pantalla con el siguiente formato exacto:
#[INFO] Generando reporte para el entorno: [valor_de_variable] en la IP [valor_de_variable]
printf "[INFO] Generando reporte para el entorno: %s en la IP %s\n" "$ENVIRONMENT" "$SERVER_IP"