#!/bin/bash

# Un script llamado 03-server-check.sh que haga lo siguiente:
# Declare una lista con los nombres de tres servidores en una variable (por ejemplo: SERVERS="web-01 web-02 database-01").
SERVERS="web-01 web-02 database-01 127.0.0.1"

# Utilice un bucle for para recorrer cada servidor de esa lista.
# Dentro del bucle, simule una comprobación (puedes usar un mensaje por pantalla con printf que diga algo como [CHECK] Verificando estado del servidor [nombre_servidor]...).
# Añade una condición simulada dentro del bucle (o simplemente imprime un mensaje de que el servidor está ONLINE).
for server in $SERVERS; do
    printf "[CHECK] Verificando estado del servidor: %s\n" "$server"
    ping -c 1 "$server"
    STATUS=$?
    if [ "$STATUS" -eq 0 ]; then
        printf "El servidor %s está ONLINE\n" "$server"
    else
        printf "El servidor %s está OFFLINE\n" "$server"
    fi
done
