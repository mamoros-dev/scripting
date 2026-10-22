#!/bin/bash
# crea un script llamado 04-robust-deploy.sh que haga lo siguiente:
# Incluya el shebang clásico (#!/bin/bash) y obligatoriamente la línea set -euo pipefail justo debajo.
set -euo pipefail
# Defina una función llamada check_environment() que compruebe si una variable de entorno obligatoria (por ejemplo, DEPLOY_ENV) está definida. (Pista: puedes usar un condicional con [ -z "${DEPLOY_ENV:-}" ] para validar si está vacía).
# Si está vacía, que la función devuelva un error controlado. Si existe, que imprima un mensaje informando de que el despliegue es seguro.
check_environment() {
    if [ -z "$DEPLOY_ENV" ]; then
        printf "Error: La variable DEPLOY_ENV está vacía\n"
        #exit 1 # ya salta fallo y no continua el script
    else
        printf "Despliegue seguro para el entorno: %s\n" "$DEPLOY_ENV"
    fi
}

# Llame a esa función al ejecutar el script.
DEPLOY_ENV="" # Error: La variable DEPLOY_ENV está vacía
check_environment
DEPLOY_ENV="production" # Despliegue seguro para el entorno: production
check_environment

check_environmentv2() {
    if [ -z "$1" ]; then
        printf "Error: La variable DEPLOY_ENV está vacía\n"
    else
        printf "Despliegue seguro para el entorno: %s\n" "$1"
    fi
}

DEPLOY_ENV="" # Error: La variable DEPLOY_ENV está vacía
check_environmentv2 "$DEPLOY_ENV"
DEPLOY_ENV="production" # Despliegue seguro para el entorno: production
check_environmentv2 "$DEPLOY_ENV"

check_environmentv3() {
    local env_value="$1" # Guardamos el primer argumento en una variable local
    
    if [ -z "$env_value" ]; then
        printf "Error: El entorno está vacío\n"
        exit 1 # Forzamos la salida si falla
    else
        printf "Despliegue seguro. Entorno: %s\n" "$env_value"
    fi
}

# Llamamos a la función pasándole la variable
DEPLOY_ENV="production"
check_environment "$DEPLOY_ENV"