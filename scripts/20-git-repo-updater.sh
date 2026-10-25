#!/bin/bash

# Recorre carpetas locales y ejecuta un git pull masivo.
for dir in /home/usuario/proyectos/*/; do
    if [ -d "$dir/.git" ]; then
        printf "[INFO] Actualizando repositorio en %s\n" "$dir"
        git -C "$dir" pull
    fi
done