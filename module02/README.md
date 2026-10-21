# Módulo 2: Redirecciones, Pipes y Manejo de Errores

+ En producción, un script nunca corre en el vacío: genera salidas estándar (`stdout`), errores (`stderr`), y muchas veces queremos combinar comandos para filtrar información en tiempo real (por ejemplo, buscar cuántas conexiones activas hay o qué errores suelta un servicio).

## Concepto Teórico Breve

+ **Salidas estándar y errores:** Linux maneja canales numéricos. El `1` es la salida estándar (`stdout`) y el `2` es la salida de errores (`stderr`).
+ **Redirecciones (> vs >>):**
    - `> file` sobrescribe un archivo con la salida.
    - `>> file` añade (append) el contenido al final del archivo sin borrar lo anterior.
    - `2>&1` redirige los errores hacia el mismo sitio que la salida estándar (vital para logs).
+ **Pipes (`|`):** Conecta la salida de un comando directamente con la entrada de otro (ej. `cat archivo.log | grep "ERROR"`).

## Tu Reto Práctico del Módulo 2 (Situación de Producción)

+ Imagina que estás revisando los logs de acceso de una aplicación web corporativa y necesitas extraer información crítica de forma rápida para un análisis de seguridad.

+ El Reto: **Crea un script llamado 02-filter-logs.sh que haga lo siguiente:**
    - Simule la generación de un flujo de logs (o lee de una pequeña cadena simulada dentro del script usando un echo o printf con varias líneas de ejemplo que contengan códigos de estado HTTP, por ejemplo: 200 OK, 404 Not Found, 500 Internal Server Error).
    - Filtre únicamente las líneas que contengan errores del servidor (códigos que empiezan por 5 o la palabra Error).
    - Guarde exclusivamente esos errores limpios en un archivo de salida llamado production-errors.log (asegúrate de que si se vuelve a ejecutar el script, el archivo no acumule duplicados extraños si usas > o que los maneje bien).
    - Muestre un mensaje por pantalla indicando cuántos errores se han encontrado y registrado.

+ Resultado:
```bash
#!/bin/bash

# Crea un script llamado 02-filter-logs.sh que haga lo siguiente:

# Simule la generación de un flujo de logs 
# http-logs.log --- fichero creado con logs

# Filtre únicamente las líneas que contengan errores del servidor (códigos que empiezan por 5 o la palabra Error).
# Guarde exclusivamente esos errores limpios en un archivo de salida llamado production-errors.log 
grep -E "^5|Error" http-logs.log > production-errors.log

# Muestre un mensaje por pantalla indicando cuántos errores se han encontrado y registrado.
NUMBER_ERRORS=$(wc -l production-errors.log | awk '{print $1}')
printf "[INFO] Se han encontrado y registros: %s errores\n" "$NUMBER_ERRORS"
```

+ Ejemplo simulando un flujo de datos:
```bash
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
grep -E "^5|Error" flujo-logs.log > manual-production-errors.log

# Muestre un mensaje por pantalla indicando cuántos errores se han encontrado y registrado.
NUMBER_ERRORS_FLUJO=$(wc -l manual-production-errors.log | awk '{print $1}')

printf "[INFO] Se han encontrado y registros: %s errores\n" "$NUMBER_ERRORS_FLUJO"
```

## FILTRO CON GREP
+ **GREP:**
    - `grep -e ^5 http-logs.log | grep -e "Error" http-logs.log > production-errors.log`
    > Qué está pasando: Al poner http-logs.log al final del segundo grep, estás ignorando por completo el pipe (|). El segundo grep pasa olímpicamente de lo que le envía el primer comando y vuelve a leer el archivo original desde cero. El primer grep (el de "Error") no está haciendo realmente nada en ese flujo.
    - `grep -e "Error" -e "5" http-logs.log > production-errors.log`
    > Se usa para definir un patrón de búsqueda de forma explícita. Es especialmente útil si tu patrón empieza por un guion (para que grep no se piense que es un parámetro de configuración) o si quieres usar múltiples -e para buscar varias cosas distintas de forma separada.
    - `grep -E "^5|Error" http-logs.log > production-errors.log`
    > Por qué funciona ahora: Al poner las comillas dobles ^5|Error desde el principio hasta el final, le dices a Bash: "Ey, esto es una sola cadena de texto, no dividas nada". Y luego grep con la opción -E recibe esa cadena y dice: "Perfecto, busco las líneas que empiecen por 5 O que contengan la palabra Error".
    - `grep -E -i "^5|error" http-logs.log > production-errors.log`
    > Haría que tanto Error, error como ERROR encajaran perfectamente. Haríamos si quisiéramos que "error" (en cualquier combinación de mayúsculas/minúsculas) también fuera independiente añadiendo el modificador `-i (ignore-case)`

## Un Flujo de Logs Real en Entornos de Producción

+ En una empresa real, los logs no suelen estar en un archivo estático plano esperando a ser leídos, sino que se generan de forma masiva y continua (por ejemplo, en contenedores Docker, pods de Kubernetes o servidores Nginx).

+ Un script de automatización real para un sysadmin procesando logs de Nginx en producción se vería más o menos así:

```bash
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log/nginx"
ERROR_REPORT="/var/log/reports/security-alerts.log"

# 1. Buscar errores críticos (códigos 5xx) en tiempo real o en el último log rotado
# y añadirles una marca de tiempo (timestamp) corporativa para auditoría.
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Analizando accesos..." >> "$ERROR_REPORT"

# Usamos grep extendido para filtrar códigos 502, 503 y 504
if grep -E "HTTP/1.[01]\" (5[0-9]{2})" "$LOG_DIR/access.log" > /tmp/critical_errors.tmp; then
    TOTAL_ERRORS=$(wc -l < /tmp/critical_errors.tmp)
    printf "[ALERTA] Se detectaron %s errores críticos en el balanceador.\n" "$TOTAL_ERRORS"
    
    # Enviar reporte o mover a producción
    cat /tmp/critical_errors.tmp >> "$ERROR_REPORT"
else
    printf "[INFO] Sistema estable. No se detectaron errores 5xx.\n"
fi

# Limpieza de ficheros temporales
rm -f /tmp/critical_errors.tmp
```
> `set -euo pipefail:` Esto lo veremos a fondo en el Módulo 4. Son "banderas de seguridad" para el script: si un comando falla o hay una variable vacía, el script se aborta automáticamente en lugar de seguir ejecutándose a lo loco por el servidor.  

> `LOG_DIR= y ERROR_REPORT=` "Variables de rutas: En entornos profesionales, las rutas fijas se guardan en variables al principio del script. Si mañana cambian los logs de sitio, solo lo modificas en una línea.  

> `$(date '+%Y-%m-%d %H:%M:%S'):` Esto ejecuta el comando date con un formato específico para inyectar una marca de tiempo exacta de cuándo se ejecutó el análisis.  

> `if ...; then:` Esto es exactamente lo que aprenderemos en el Módulo 3. Un condicional clásico: "Si el comando de dentro se ejecuta con éxito (encuentra coincidencias), haz A; si no, haz B".  

> `5[0-9]{2}`: Esto es una expresión regular avanzada: El `5` busca los códigos que empiezan por 5. `[0-9]` significa "cualquier dígito del 0 al 9". `{2}` significa "repite lo anterior exactamente 2 veces". Resultado: Esto busca automáticamente cualquier código HTTP entre 500 y 599 (502, 503, 504, etc.) sin tener que escribirlos uno a uno.

> `El bloque else y conteo:` Si grep encontró errores, cuenta las líneas con wc -l, avisa por pantalla y vuelca el archivo temporal al registro oficial. Si no encontró nada (el grep devuelve código de salida de fallo), imprime que el sistema está estable.

> `Limpieza de archivos temporales (rm -f):` Una regla de oro de cualquier script de sysadmin en producción es limpiar la casa antes de irse. Borramos el archivo temporal para no dejar basura acumulada en el servidor.