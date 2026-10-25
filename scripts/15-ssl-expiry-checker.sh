#!/bin/bash
# Comprueba los días restantes de validez de un certificado HTTPS en un dominio (openssl).
DOMAIN="mi-web.com"
EXPIRY_DATE=$(openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut -d= -f2)
printf "[INFO] El certificado de %s caduca el: %s\n" "$DOMAIN" "$EXPIRY_DATE"