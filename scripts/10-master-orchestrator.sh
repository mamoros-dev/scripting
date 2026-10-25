#!/bin/bash
set -euo pipefail

printf "### ORQUESTADOR DE SCRIPTS ###\n"

printf "[INFO][SCRIPT-01] Ejecutando script...\n"
./01-script-env-validatorv2.sh
if [[ $? -eq 0 ]]; then
    printf "[OK] Script ejectuado correctamente\n"
else
    printf "[ERROR] Fallo en el script\n"
    exit 1
fi

printf "[INFO][SCRIPT-02] Ejecutando script...\n"
./02-script-health-checker.sh
if [[ $? -eq 0 ]]; then
    printf "[OK] Script ejectuado correctamente\n"
else
    printf "[ERROR] Fallo en el script\n"
    exit 1
fi

printf "[INFO][SCRIPT-03] Ejecutando script...\n"
./03-log-rotatorv2.sh
if [[ $? -eq 0 ]]; then
    printf "[OK] Script ejectuado correctamente\n"
else
    printf "[ERROR] Fallo en el script\n"
    exit 1
fi

printf "[INFO][SCRIPT-04] Ejecutando script...\n"
./04-secure-deploy.sh
if [[ $? -eq 0 ]]; then
    printf "[OK] Script ejectuado correctamente\n"
else
    printf "[ERROR] Fallo en el script\n"
    exit 1
fi

printf "[INFO][SCRIPT-05] Ejecutando script...\n"
./05-sys-report.sh
if [[ $? -eq 0 ]]; then
    printf "[OK] Script ejectuado correctamente\n"
else
    printf "[ERROR] Fallo en el script\n"
    exit 1
fi

printf "[INFO][SCRIPT-06] Ejecutando script...\n"
./06-log-error-searcher.sh
if [[ $? -eq 0 ]]; then
    printf "[OK] Script ejectuado correctamente\n"
else
    printf "[ERROR] Fallo en el script\n"
    exit 1
fi

printf "[INFO][SCRIPT-07] Ejecutando script...\n"
./07-aws-resource-extractor.sh
if [[ $? -eq 0 ]]; then
    printf "[OK] Script ejectuado correctamente\n"
else
    printf "[ERROR] Fallo en el script\n"
    exit 1
fi

printf "[INFO][SCRIPT-08] Ejecutando script...\n"
./08-auto-backup.sh
if [[ $? -eq 0 ]]; then
    printf "[OK] Script ejectuado correctamente\n"
else
    printf "[ERROR] Fallo en el script\n"
    exit 1
fi

printf "[INFO][SCRIPT-09] Ejecutando script...\n"
./09-docker-cleanupv2.sh
if [[ $? -eq 0 ]]; then
    printf "[OK] Script ejectuado correctamente\n"
else
    printf "[ERROR] Fallo en el script\n"
    exit 1
fi
printf "### ORQUESTADOR DE SCRIPTS FINALIZADO ###\n"