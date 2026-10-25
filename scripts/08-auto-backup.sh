#!/bin/bash
set -euo pipefail

# Usa tar con las banderas -czf para crear un archivo comprimido gzipped.
# Usa el comando date +%Y%m%d_%H%M%S para que cada copia d un nombre único
tar -czf backup-$(date +%Y%m%d_%H%M%S).tar 03-logs

# una política de retención que borre únicamente los backups que tengan más de 30 días de antigüedad:
# find /backup -name "*.tar.gz" -mtime +30 -delete).