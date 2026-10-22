#!/bin/bash
set -euo pipefail

deploy_app() {
    local target_env="$1"

    if [ -z "$target_env" ]; then
        printf "Error, el entorno está vacío\n"
        exit 1
    else
        printf "[INFO] El despliegue al entorno de %s ha comenzado [DEPLOYING]\n" "$target_env"
    fi
}

ENVIRONMENT=""
deploy_app "$ENVIRONMENT"
ENVIRONMENT="dev"
deploy_app "$ENVIRONMENT"
