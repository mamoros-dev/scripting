#!/bin/bash

# Limpia archivos temporales en /tmp con más de 3 días de inactividad.
find /type mtime +3 -exec rm -f {} + 2>/dev/null || true
printf "[OK] Ficheros temporales antiguos eliminados.\n"