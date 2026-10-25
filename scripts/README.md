# SCRIPTS

+ El Listado de los 10 Scripts "Santo Grial"
    - Validador de .env en CI/CD 
    - Health Checker de Servidores / APIs (¡Empezamos ahora!)
    - Rotador y Limpiador de Logs
    - Desplegador Seguro con Rollback
    - Generador de Informes de Sistema
    - Buscador de Errores en Logs con grep/Regex
    - Extractor de Recursos AWS con jq
    - Auditor de Permisos y Ficheros Sensibles
    - Watcher de Espacio en Disco con Alerta Crítica
    - Automatizador de Backups a S3

+ Los 4 Retos Clave de Entrevista:
    - El limpiador de discos inteligente
    - Consumir una API y parsear JSON
    - Matar procesos huérfanos con alto consumo
    - Automatizar AWS con Python y Boto3

+ Los 10 Scripts Prácticos para el Día a Día:
    - SSL Expiry Checker
    - Database Backup & S3 Uploader
    - Automated User Provisioning
    - Port Availability & Service Probe
    - Log File Webhook Alerter
    - Git Repo Mass Updater
    - K8s CrashLoopDetector
    - AWS Tag Compliance Auditor
    - Temp File Safe Purger
    - Env Validator Sync


## Script 1: El Validador de Configuración para CI/CD (env-validator.sh)

+ El Problema Real: En los despliegues automáticos (CI/CD), si falta una variable de entorno crítica en el archivo .env del servidor (como DB_PASSWORD o API_KEY), la aplicación arrancará rota o fallará a mitad de la noche.

+ Tu Objetivo: Escribir un script en Bash que lea un archivo .env (o compruebe variables de entorno del sistema) y verifique de forma estricta si existen las 3 variables obligatorias siguientes:
```bash
DB_HOST
DB_PORT
DB_PASSWORD
```

+ [SCRIPT](./01-script-env-validatorv2.sh)  

+ Requisitos del script:
    - Debe usar set -euo pipefail.
    - Si alguna de las 3 variables no está definida o está vacía, el script debe imprimir un error claro en pantalla y morir con un código de salida distinto de cero (por ejemplo, exit 1) para que el pipeline de despliegue se cancele automáticamente.
    - Si todas están presentes, debe mostrar un mensaje de éxito ([OK] Configuración validada correctamente) y terminar con código 0.

+ Como se integraría en producción?
```bash
#!/bin/bash
set -euo pipefail

printf "%s\n" "=========================================="
printf "%s\n" "INICIANDO DESPLIEGUE AUTOMÁTICO DE LA APP"
printf "%s\n" "=========================================="

# PASO 1: Ejecutar el script validador que acabamos de crear
printf "%s\n" "[1/3] Validando configuración de entorno..."
./01-script-env-validator.sh

# Como nuestro validador tiene 'set -euo pipefail' y hace 'exit 3' si falla, 
# si la validación falla, el script de despliegue SE DETIENE AQUÍ AUTOMÁTICAMENTE.
# Jamás pasará al paso 2 si hay un error en las credenciales.

# PASO 2: Simular la subida de ficheros o arranque de contenedores
printf "%s\n" "[2/3] Arrancando contenedores Docker con la configuración validada..."
# docker compose up -d

# PASO 3: Mensaje final de éxito
printf "%s\n" "[3/3] ¡Despliegue completado con éxito!"
```
> Como SysAdmin: Lo pones en un cron job o en los scripts internos que usas al clonar un repositorio nuevo en un servidor de un cliente, asegurándote de que nadie olvide configurar las contraseñas en el archivo .env.  
> Como DevOps / Cloud: Se integra en la primera fase de un pipeline de CI/CD (por ejemplo, en GitHub Actions). La máquina virtual de GitHub descarga tu código, ejecuta tu 01-script-env-validator.sh contra el .env del entorno de producción, y si da error, la barra del pipeline se pone en rojo y avisa por Slack de que el despliegue ha sido abortado por configuración incompleta.  

## Script 2: El Health Checker de Servidores / APIs (health-checker.sh)

+ El Problema Real: Como SysAdmin o DevOps, una de tus tareas diarias más comunes es asegurarte de que los servicios críticos de la empresa (la web corporativa, la API de pagos, el panel de control) están vivos y respondiendo. No puedes estar comprobándolos a mano uno a uno todo el día.

+ Tu Objetivo: Escribir un script en Bash que lea una lista de URLs desde un archivo de texto plano (urls.txt), compruebe el código de estado HTTP que devuelve cada una usando la herramienta curl, y reporte si el servicio está operativo o caído.

+ Requisitos y pistas para empezar:
    - Crea un fichero llamado urls.txt con un par de direcciones web de prueba (por ejemplo: [https://google.com](https://google.com), [https://github.com](https://github.com), o una web inventada que falle).
    - En tu script, usa un bucle while read para leer el archivo urls.txt línea por línea.
    - Para averiguar el código HTTP con curl de forma limpia y silenciosa (sin que te escupa el código HTML de la página en la pantalla), investiga o recuerda cómo se usa el comando curl con las banderas -s -o /dev/null -w "%{http_code}".
    - Evalúa con un if si el código devuelto es 200 (éxito) u otro valor (error/caído).

+ [SCRIPT](02-script-health-checker.sh)  

+ Como se integraría en producción:
```bash
# El Despertador (Cron)
## Le dices a Linux: "Oye, ejecuta este script de health check automáticamente cada 5 minutos, las 24 horas del día".
*/5 * * * * /ruta/a/tu/02-script-health-checker.sh

# El Cerebro (Tu Script)
/ruta/a/tu/02-script-health-checker.sh

# El Mensajero (El Webhook o Email)
## Cuando el script detecta que una web devuelve un error e ordenas que haga una petición HTTP POST (un webhook) hacia un canal de Slack o Discord, o que envíe un correo.
else
        printf "[ERROR] La web %s está caída. Código: %d\n" "$linea" "$code"
        # --- AQUÍ ENTRA EL WEBHOOK REAL ---
        # Enviamos una alerta instantánea a un canal de Slack o Discord
        curl -s -X POST -H 'Content-Type: application/json' \
             -d '{"content": "🚨 ¡ALERTA DE PRODUCCIÓN! La web '"$linea"' devolvió el código '"$code"'"}' \
             "https://discord.com/api/webhooks/tu-url-secreta-aqui"

        echo "La web está caída" | mail -s "ALERTA: Servidor Caído" tu-correo@empresa.com
        exit 1
    fi
```
> ¿Qué hace esto? En el preciso instante en que el script detecta que una web falla, lanza un curl invisible hacia el servidor de Discord/Slack, y a ti te suena la notificación en el móvil al segundo.

## Script 3: El Rotador y Limpiador de Logs (log-rotator.sh)

+ El Problema Real: Las aplicaciones en producción escriben registros (logs) sin parar en ficheros como /var/log/miapp/app.log. Si pasa un mes y no haces nada, ese fichero puede pesar gigabytes, llenar por completo el disco duro del servidor y hacer que todo colapse (¡un clásico desastre de SysAdmin en plena madrugada!).

+ Tu Objetivo: Escribir un script en Bash que gestione una carpeta de logs simulada (./logs/), compruebe qué archivos de log son antiguos y los limpie o comprima.

+ Requisitos y pistas para empezar:
    - Crea una carpeta local llamada logs/ con un par de ficheros de texto de prueba (por ejemplo, app.log, access.log, error.log).
    - En el mundo real, los logs antiguos se borran basándose en su antigüedad (por ejemplo, ficheros que no se han modificado en más de 7 días).
    - La herramienta por excelencia en Linux para buscar ficheros por antigüedad es el comando find.
    - Para este ejercicio inicial, tu script debe:
        + Buscar en la carpeta logs/ aquellos ficheros que tengan una antigüedad superior a X días (o simplemente listar todos los ficheros de log para empezar a probar).
        ```bash
        touch -d "8 days ago" ./03-logs/app.log
        ```
        > Si ejecutas eso y luego lanzas tu script con -mtime +7, verás cómo mágicamente sí lo detecta. ¡Prueba a hacerlo!  
        + Mostrar un mensaje indicando qué fichero se va a limpiar o borrar.

+ [SCRIPT](./03-log-rotatorv2.sh)  

+ Integración en producción:
    - Al igual que el health checker, este script no se ejecuta a mano. Se programa en el Cron del servidor para que corra de madrugada, cuando el tráfico web es mínimo y el rendimiento del sistema no se ve afectado.
    ```bash
    # Configuración en Cron (por ejemplo, todos los días a las 03:00 AM):
    0 3 * * * /usr/local/bin/03-log-rotator.sh >/dev/null 2>&1
    ```
    > los SysAdmins rara vez escriben un script de Bash para rotar logs pesados del sistema; configuran logrotate y se olvidan. Sin embargo, tu script anterior con find es perfecto para limpiar cachés, archivos temporales o logs propios de contenedores donde logrotate no llega tan fácilmente.

+ **El estándar de la industria (La herramienta logrotate):** En Linux, para rotar logs gigantescos (comprimiéndolos en formato .gz en lugar de borrarlos directamente por si necesitas auditar algo del pasado), los SysAdmins suelen usar una utilidad nativa llamada logrotate. Sin embargo, saber escribir tu propio script de limpieza en Bash te da el control absoluto para automatizar limpiezas de ficheros temporales, cachés o logs propios de tus aplicaciones Docker.
```bash
# Ejemplo de un archivo de configuración de logrotate:
/var/log/miapp/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 640 root root
}

logrotate -f /etc/logrotate.d/miapp
```
> daily: Rota los logs todos los días.  
> rotate 7: Guarda únicamente los últimos 7 días de logs comprimidos y borra los más antiguos automáticamente.  
> compress: Comprime los logs antiguos en formato .gz para que ocupen poquísimo espacio.  
> missingok: Si un archivo de log no existe, no da error y continúa.  

## Script 4: El Desplegador Seguro con Rollback (secure-deploy.sh)

+ El Problema Real: Vas a desplegar una nueva versión de la aplicación web de la empresa en el servidor. Ejecutas el script de actualización, pero algo sale mal (un error de código, una librería rota) y la web se cae. El pánico se apodera de ti porque el servicio está interrumpido. Un DevOps profesional nunca hace un despliegue a pecho descubierto: siempre tiene preparado un plan de Rollback (volver a la versión anterior estable de forma instantánea).

+ Tu Objetivo: Diseñar la lógica de un script que simule un despliegue seguro, compruebe si el nuevo estado funciona, y si falla, revierta automáticamente al directorio o versión anterior.

+ Requisitos y pistas para empezar:
    - Simula dos carpetas en tu entorno de pruebas: ./current/ (la versión actual que está funcionando) y ./releases/nueva-version/ (la versión que quieres desplegar).
    - El script debe hacer lo siguiente:
        + Respaldar o recordar cuál era la versión estable actual.
        + Intentar "mover" o activar la nueva versión.
        + Simular una comprobación de salud (por ejemplo, comprobar si un fichero clave existe o si el servicio responde).
        + Si la comprobación falla, el script debe ejecutar un bloque de Rollback que devuelva instantáneamente el enlace o carpeta a la versión anterior.

+ [SCRIPT](./04-secure-deploy.sh)

+ Integración en producción:
    - En un entorno real de producción nunca copiamos ficheros sueltos con cp. Lo que acabamos de hacer es solo un modelo mental para entender la lógica de control (Intento ---> Comprobación ---> Rollback).
    - En el mundo real:
        + Con Nginx/Apache: Se usan enlaces simbólicos (symlinks). La carpeta `/var/www/live` apunta a `/releases/v1`. Al desplegar, se monta /releases/v2, se comprueba que responde, y el script solo cambia el puntero del symlink de golpe con `ln -sfn`. Si falla, vuelve a apuntar a `v1`.
        + Con Contenedores (Docker): Se cambia la etiqueta de la imagen en el `docker-compose.yml` (de `app:v2` a `app:v1`) y se relanza.
        + Con Kubernetes: Se usa el comando nativo `kubectl rollout undo deployment/miapp`, que hace exactamente esto mismo de forma automatizada a nivel de infraestructura de clúster.

## Script 5: Generador de Informes de Sistema (sys-report.sh)

+ El Problema Real: Cuando un servidor empieza a dar problemas de rendimiento o necesitas hacer una auditoría rápida de una máquina recién alquilada en la nube, necesitas extraer métricas clave al instante (quién consume CPU, cómo va el espacio en disco, qué puertos están abiertos, memoria RAM libre) sin volverte loco ejecutando diez comandos sueltos.

+ Tu Objetivo: Crear un script que recopile las métricas vitales del sistema y las escupa en un informe limpio en formato de texto.

+ Requisitos y pistas para empezar:
    - Usa comandos nativos de Linux que ya deberías conocer de tu experiencia como SysAdmin (como df -h, free -h, uptime, o top/ps).
    - Haz que el script redirija toda esa información estructurada con cabeceras printf hacia un fichero de informe, por ejemplo, reporte-sistema.txt.

+ Mejoras de nivel producción:
    - **El peligro del operador >> (Acumulación infinita):** Fíjate que estás usando >> para añadir al final del fichero (`05-system-report.txt`). Si ejecutas este script tres veces seguidas hoy, tu informe contendrá tres bloques idénticos uno detrás de otro porque el archivo nunca se limpia al empezar. En producción, el primer comando del informe debe abrirse con `>` (para sobrescribir y crear un informe fresco) y los siguientes con `>>`.
    + **Redirección de bloque único:** En lugar de abrir y cerrar el archivo 4 veces con `>>` en cada comando, en Bash puedes envolver todo el bloque de comandos entre llaves `{ ... }` y redirigir todo de golpe al final del archivo una sola vez. Es mucho más limpio y eficiente.

## Script 6: Buscador de Errores en Logs con grep/Regex (log-error-searcher.sh)

+ El Problema Real: Tienes un archivo de log en producción que pesa decenas de megabytes. Un cliente reporta un fallo a las 4 de la tarde. No puedes abrir el fichero entero a ojo; necesitas un script automático que barra el log quirúrgicamente, extraiga solo las líneas con `ERROR o CRITICAL`, cuente cuántas veces han ocurrido y te las guarde en un resumen para analizar el problema en segundos.

+ Tu Objetivo: Diseñar un script que analice un fichero de logs de prueba utilizando grep y expresiones regulares para aislar las alertas y errores graves.

+ Requisitos y pistas para empezar:
    - Crea un fichero de pruebas llamado `06-app.log` con varias líneas mezcladas (ej: mensajes `[INFO], [WARNING], [ERROR: Conexión fallida]`, etc.).
    - En tu script, usa el comando `grep` con banderas útiles como -i (para que no distinga entre mayúsculas y minúsculas) o `-E` (para expresiones regulares avanzadas).
    - Opcional: Intenta contar cuántas líneas de error ha encontrado usando el modificador `-c` de grep o guardando el resultado en una variable para mostrar un contador.

+ [SCRIPT](./06-log-error-searcher.sh)  

+ Integracion en producción:
    - El Filtro de Alerta: El script busca la palabra ERROR o CRITICAL en el archivo de log del día.
    - La Toma de Decisiones (El Umbral): Usas un condicional numérico para evaluar el contador.
        + Si errors_found es 0, el script termina silenciosamente (exit 0). Todo va bien.
        + Si errors_found es mayor de 5, significa que hay una incidencia masiva en la aplicación. En ese momento, el script hace saltar el mecanismo de alerta (como vimos en el Script 2: un Webhook automático a Slack o Discord notificando que el log escupió más de X errores).

## Script 7: Extractor de Recursos AWS con jq (aws-resource-extractor.sh)

+ El Problema Real: Como ingeniero Cloud o DevOps, te pasas el día interactuando con la CLI de AWS. Los comandos devuelven enormes bloques de datos en formato JSON imposibles de leer a ojo. Necesitas extraer datos concretos (por ejemplo, listar únicamente los nombres y las IPs públicas de todas tus instancias EC2 activas) para un informe o una auditoría rápida.

+ Tu Objetivo: Simular o procesar un JSON de respuesta de AWS utilizando jq para extraer campos específicos de forma limpia.

+ Requisitos y pistas para empezar:
    - Crea un archivo JSON de pruebas llamado `07-instances.json` con una estructura simulada de AWS EC2 (con objetos, arrays, nombres de instancias y estados).
    - En tu script, usa la herramienta `jq` para filtrar los datos. Recuerda cómo recorre `jq` las listas y extrae claves específicas (por ejemplo, usando puntos `.` y corchetes `[]`).

+ **Tu Reto con jq:** Vamos a empezar extrayendo información clave. Imagina que necesitas hacer un inventario rápido de este archivo y quieres sacar únicamente:
    - El nombre lógico del recurso (por ejemplo: WebInstance1, WebInstance2...)
    - Su tipo de instancia (InstanceType, que en todos es t3.micro).

+ [SCRIPT](./07-aws-resource-extractor.sh)  

+ Resumen maestro de lo que hemos aprendido con jq (Script 7)
    - jq es el "puñales de oro" para tratar con JSON en la terminal Linux sin necesidad de programar scripts complejos en Python o Node.js. Esto es lo que acabas de dominar:
        - La opción -r (Raw Output): Elimina las comillas dobles de los strings de salida para que el texto quede limpio y plano (ideal para pasarlo a variables o imprimirlos en pantalla).
        - Extraer claves de un objeto (keys[]): Cuando tienes un diccionario o objeto complejo (.Resources), usar .Resources | keys[] te permite listar las llaves principales (los nombres de tus recursos como WebInstance1, WebInstance2).
        - Desempaquetar arrays ([]): En JSON, los corchetes [...] son listas (arrays). Para entrar dentro de una lista y mirar sus elementos uno a uno (como los tags), tienes que añadir [] (por ejemplo, .Properties.Tags[]).
        - Filtrar con inteligencia (select(...) y ==):
            + select() actúa como un filtro estilo WHERE de bases de données.
            + Recuerda la regla de oro: = asigna (lo cual rompe el filtro porque acepta todo) y == compara estrictamente (el filtro quirúrgico que solo deja pasar lo que buscas).


## Script 8: Gestor de Copias de Seguridad Automatizadas (auto-backup.sh)

+ Dado que ya dominas la extracción, la gestión de logs y los despliegues, el siguiente pilar fundamental de cualquier SysAdmin es la persistencia y los respaldos (Backups).

+ El Problema Real: Las bases de datos y los ficheros de configuración críticos de los servidores deben respaldarse diariamente. Si el disco peta a las 3:00 AM, tu única salvación es un tarball comprimido (.tar.gz) bien estructurado y guardado en un directorio seguro (o enviado a un bucket S3).

+ Tu Objetivo: Diseñar un script en Bash que comprima una carpeta de datos de la aplicación, le añada un sello de tiempo único en el nombre y elimine las copias más antiguas de X días para no saturar el disco.

+ Requisitos y pistas para empezar:
    - Usa el comando tar con las banderas -czf para crear un archivo comprimido gzipped.
    - Usa el comando date +%Y%m%d_%H%M%S para que cada copia de seguridad tenga un nombre único e imposible de pisar.

+ [SCRIPT](./08-auto-backup.sh)  

+ **TAR:**
    - El `comando tar` (que viene de Tape Archive o Archivo de Cinta) es la herramienta por excelencia en el mundo Linux para empaquetar múltiples ficheros y carpetas en un solo archivo (conocido como tarball), ideal para respaldos o para mover código entre servidores.
    - `-c` (Create): Crea un archivo nuevo desde cero.
    - `-z` (Gzip): Pasa el archivo por el compresor gzip para reducir drásticamente su tamaño en disco (creando un .tar.gz).
    - `-f` (File): Indica que el siguiente argumento será el nombre del archivo que vamos a crear.
    > ⚠️ Regla de oro de Bash: La bandera -f siempre debe ser la última de la cadena antes de poner el nombre del archivo (ej: -czf nombre.tar.gz carpeta/, nunca -fcz).  
    - `-x` (Extract): Extrae o descomprime el contenido de un archivo .tar o .tar.gz en la carpeta actual.
    - `-v` (Verbose): Modo "parlanchín". Muestra en pantalla la lista de ficheros que va extrayendo uno a uno para que veas qué está pasando.
    - `-t` (List): Te permite ver el contenido de un archivo comprimido sin necesidad de extraerlo ni descomprimirlo en el disco
    > ahorrar espacio en disco y ancho de banda al transferir backups es sagrado, por lo que -czf es el estándar absoluto


## Script 9: Limpiador y Gestor de Contenedores Docker (docker-cleanup.sh)

+ Como estás enfocado en entornos Cloud, Terraform y Kubernetes, te habrás dado cuenta de que Docker es una herramienta diaria. Y tiene un defecto conocido: acumula basura a una velocidad pasmosiza.

+ El Problema Real: Cada vez que pruebas imágenes, descargas capas nuevas, levantas contenedores de prueba y los borras, Docker se queda con imágenes huérfanas (dangling), contenedores detenidos que ya no sirven y volúmenes huérfanos que devoran gigabytes de disco duro en silencio.

+ Tu Objetivo: Escribir un script en Bash que automatice la limpieza segura de este desorden utilizando comandos de mantenimiento de Docker.

+ Requisitos y pistas para empezar:
    - El comando definitivo en Docker para limpiar todo lo que no se está usando es docker system prune.
    - Para evitar sorpresas desagradables en producción, esta herramienta suele usarse con la bandera -f (force) combinada con el filtrado de volúmenes (--volumes).

+ [SCRIPT](./09-docker-cleanupv2.sh)  

+ Como integrarlo en producción:
    - Un script profesional debe incluir:
        + Métricas de impacto: Mostrar cuánto espacio libre había antes y después para ver si realmente era necesario limpiar.
        + Filtros de seguridad por tiempo: En lugar de borrar todo lo detenido, se suele borrar solo lo que lleva inactivo más de X tiempo (por ejemplo, 24 horas o 7 días) con la opción `--filter "until=24h"`.
        + Registro de auditoría (Logging): Guardar la fecha, la hora y los gigabytes liberados en un fichero de log para que quede constancia en el sistema.

## Script 10: El Orquestador Maestro de Mantenimiento (master-orchestrator.sh)

+ Has llegado a la cúspide de esta serie de scripts. Este último no hace tareas individuales; se encarga de unirlas todas.

+ El Problema Real: En producción, los SysAdmins no ejecutan diez scripts sueltos a mano cada día. Tienen un script "orquestador" principal que se ejecuta mediante Cron a las 3:00 AM y lanza las tareas en orden lógico, comprobando que si una falla (por ejemplo, el backup), el sistema avise y se detenga antes de romper algo más.

+ Tu Objetivo: Crear un script orquestador que llame de forma segura a tus scripts anteriores (o simule sus fases) controlando los códigos de salida ($?) y gestionando un registro global de la ejecución.

+ [SCRIPT](./10-master-orchestratorv2.sh)  

+ Integración en producción:
    - **Mantenimiento cero:** Si mañana metes el script 10, solo tienes que añadirlo a la lista superior sin tocar nada más de la lógica.
    - **Seguridad extra:** Incluye un control previo ([[ -x "$script" ]]) para asegurarte de que el script existe y no va a fallar por un error tipográfico en la ruta.
    - **El Patrón Rollback (Script 4):** Para cosas críticas como despliegues web, se usan mecanismos donde el script hace una copia de seguridad o un enlace simbólico temporal, y solo si todo sale bien confirma el cambio. Si algo falla a mitad, el propio script incluye una sección de "trampa" (trap o bloques de error) que revierte el cambio manualmente (por ejemplo, volviendo a apuntar el symlink al sitio antiguo).
    - **Atomicidad:** Las operaciones de producción se diseñan para que sean "atómicas" (o ocurren enteras de golpe, o no ocurren y no dejan el sistema a medias).