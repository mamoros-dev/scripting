#!/bin/bash
set -euo pipefail

# Nombres de las instancias (keys() para claves principales del objeto)
printf "[INFO] NOMBRES DE LAS INSTANCIAS:\n"
jq -r '.Resources | keys[]' 07-instances.json
# WebInstance1
# WebInstance2
# WebInstance3

# Su tipo de instancia (InstanceType)
printf "[INFO] TIPOS DE INSTANCIAS:\n"
jq -r ".Resources[].Properties.InstanceType" 07-instances.json 
# t3.micro
# t2.micro
# c1.medium

# extraer el Value del Tag que se llama "Name"
printf "[INFO] TAGS DE LAS INSTANCIAS:\n"
jq -r '.Resources[].Properties.Tags[] | select(.Key == "Name") | .Value' 07-instances.json 
# Servidor-Web-01
# Servidor-Web-02
# Servidor-Web-03