#!/bin/bash

# Comprueba si los puertos críticos responden.
HOST="127.0.0.1"
for port in 80 443 5432; do
    if nc -z -w 2 "$HOST" "$port"; then
        printf "[OK] Puerto %d abierto en %s\n" "$port" "$HOST"
    else
        printf "[ERROR] Puerto %d cerrado o inaccesible en %s\n" "$port" "$HOST"
    fi
done