#!/bin/bash

# Busca errores críticos en logs y avisa vía webhook (Slack/Discord).
LOG="/var/log/app/current.log"
if grep -q "FATAL" "$LOG"; then
    curl -X POST -H 'Content-Type: application/json' \
         --data '{"text":"¡Alerta CRÍTICA detectada en los logs del servidor!"}' \
         "https://hooks.slack.com/services/T00/B00/XX"
fi