#!/bin/bash
set -euo pipefail

#Realiza un volcado de PostgreSQL, lo comprime y lo sube a AWS S3.
BACKUP_FILE="db_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
pg_dump -U postgres mibase | gzip > "/tmp/$BACKUP_FILE"
aws s3 cp "/tmp/$BACKUP_FILE" "s3://mi-bucket-backups/db/$BACKUP_FILE"
rm -f "/tmp/$BACKUP_FILE"
printf "[OK] Backup de BD subido a S3 con éxito.\n"