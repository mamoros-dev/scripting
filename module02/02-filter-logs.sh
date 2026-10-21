#!/bin/bash

# Crea un script llamado 02-filter-logs.sh que haga lo siguiente:

# Simule la generación de un flujo de logs 
# http-logs.log --- fichero creado con logs
echo "500 Error xxxxx" >> flujo-logs.log
echo "505 error xxxxx" >> flujo-logs.log
echo "404 Error xxxxx" >> flujo-logs.log
echo "405 Error xxxxx" >> flujo-logs.log
echo "404 error xxxxx" >> flujo-logs.log

# Filtre únicamente las líneas que contengan errores del servidor (códigos que empiezan por 5 o la palabra Error).
# Guarde exclusivamente esos errores limpios en un archivo de salida llamado production-errors.log 
grep -E "^5|Error" http-logs.log > production-errors.log
grep -E "^5|Error" flujo-logs.log > manual-production-errors.log

# Muestre un mensaje por pantalla indicando cuántos errores se han encontrado y registrado.
NUMBER_ERRORS=$(wc -l production-errors.log | awk '{print $1}')
NUMBER_ERRORS_FLUJO=$(wc -l manual-production-errors.log | awk '{print $1}')

printf "[INFO] Se han encontrado y registros: %s errores\n" "$NUMBER_ERRORS"
printf "[INFO] Se han encontrado y registros: %s errores\n" "$NUMBER_ERRORS_FLUJO"