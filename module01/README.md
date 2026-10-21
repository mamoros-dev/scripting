# Módulo 1: Sintaxis Básica, Variables y Primeros Comandos

+ Vamos a arrancar con los cimientos. En Bash, todo gira en torno a ejecutar comandos del sistema, capturar sus salidas y reutilizarlos mediante variables.

##  Concepto Teórico Breve

+ Un script de Bash comienza siempre con un shebang `(#!/bin/bash)` que le indica al sistema operativo qué intérprete debe ejecutar el código. 
+ Las variables se definen sin espacios alrededor del `signo = (ej. NOMBRE="produccion")` y se referencian anteponiendo un dólar `($NOMBRE)`. 
+ Además, para automatizar en servidores, es vital saber capturar el resultado de la ejecución de un comando dentro de una variable usando sustitución de comandos: `FECHA=$(date +%F)`.

### Tu Primer Reto Práctico (Situación de Producción)

+ Estás conectándote por SSH a una instancia EC2 crítica y necesitas generar un reporte rápido del estado del sistema para un ticket de incidencias.

+ El Reto:
    - Escribe un script en Bash que haga lo siguiente:
        + Declare una variable llamada ENVIRONMENT con el valor production.
        + Declare una variable llamada SERVER_IP que obtenga dinámicamente la IP local de la máquina (puedes usar el comando hostname -I o ip route).
        + Muestre un mensaje por pantalla con el siguiente formato exacto:
        `[INFO] Generando reporte para el entorno: [valor_de_variable] en la IP [valor_de_variable]`

+ Resultado:
```bash
#!/bin/bash

# Declare una variable llamada ENVIRONMENT con el valor production.
ENVIRONMENT="production"

# Declare una variable llamada SERVER_IP que obtenga dinámicamente la IP local de la máquina (puedes usar el comando hostname -I o ip route).
SERVER_IP=$(hostname -I | awk '{print $1}')

# Muestre un mensaje por pantalla con el siguiente formato exacto:
#[INFO] Generando reporte para el entorno: [valor_de_variable] en la IP [valor_de_variable]
printf "[INFO] Generando reporte para el entorno: %s en la IP %s\n" "$ENVIRONMENT" "$SERVER_IP"
```

### Sobre awk, cut y sed

+ Has mencionado cut y sed, lo que demuestra que recuerdas cosas de ASIX. Aquí va la diferencia clave en el mundo DevOps:
    - `hostname -I` a veces devuelve varias IPs si la máquina tiene múltiples interfaces (ej. `192.168.1.50 172.17.0.1`).
    - `awk '{print $1}'`: Piensa en awk como una navaja suiza que divide la línea por espacios en blanco automáticamente en "columnas" (`$1` es la primera columna, `$2` la segunda, etc.). Es rapidísimo para esto.
    - `cut`: También sirve (harías algo como `hostname -I | cut -d' ' -f1)`, pero awk maneja mejor los espacios múltiples sin volverse loco.
    - `sed`: Se usa más para buscar y reemplazar textos (expresiones regulares), por ejemplo, cambiar una palabra en un archivo de configuración de Nginx.

### Sobre los permisos (chmod +x) y la seguridad

+ **Por qué se hace:** El archivo por defecto no tiene el bit de ejecución activo por motivos de seguridad del sistema operativo (para evitar que un archivo descargado o creado al azar se ejecute solo). Hacer chmod +x le otorga permisos de ejecución al fichero.

+ **Consideraciones de seguridad en producción:** Lo peligroso no es darle chmod +x a un script tuyo, sino a qué usuarios les das permisos. En servidores de producción, los scripts ejecutables deben tener permisos restrictivos (por ejemplo, chmod 750 o 700) para que solo el usuario root o el usuario del servicio (como nginx o jenkins) pueda ejecutarlos, evitando que otros usuarios del sistema manipulen la infraestructura.

+ Dar `chmod +x` a secas (que equivale a `chmod a+x o ugo+x`) le da permiso de ejecución a todos los usuarios del sistema (propietario, grupo y otros).
    - En tu entorno local o de laboratorio: No pasa nada, es cómodo y no hay riesgo.
    - En un servidor de producción: Si hay más usuarios o servicios corriendo, no quieres que cualquiera pueda ejecutar un script que automatiza tareas críticas o despliegues.

+ Los comandos más habituales que usarás en producción son:
    - `chmod 700 nombre_script.sh`: Solo el usuario propietario (tú o el usuario del sistema que lo ejecuta) puede leer, escribir y ejecutar. (El más seguro para scripts administrativos).
    - `chmod 750 nombre_script.sh`: El propietario tiene control total, y los usuarios del mismo grupo (ej. el grupo `sysadmin o devops`) pueden leerlo y ejecutarlo, pero los externos no.
    - `chmod +x`: Se usa para desarrollo o cuando el script necesita ser ejecutado por el demonio del sistema (como un servicio de systemd).

### Sintaxis de printf vs echo

+ Has dado en el clavo con la sintaxis.
    - `printf` no lleva paréntesis (a diferencia de lenguajes como Python o C). Se escribe `printf "formato" "variables"`.

+ La diferencia clave con echo:
    - `echo` es más simple, pero se comporta de forma distinta según el sistema operativo o la versión de Bash cuando imprimes caracteres especiales (como saltos de línea o barras invertidas). Además, si imprimes algo que empieza por un guion (ej. `echo "-n"interpreta cosas raras`), `echo` puede confundirlo con una opción del propio comando.
    - `printf` es mucho más robusto y predecible (heredado de C). Te obliga a definir un formato estricto (usando `%s` para strings, `%d` para enteros) y no añade un salto de línea automático `(\n)`, por lo que tienes que ponérselo tú explícitamente al final.

+ ¿Cuál se usa en cada caso?
    - **En scripts de producción**, la comunidad DevOps recomienda siempre `printf` por seguridad y consistencia multiplataforma.
    - `echo` se suele usar en el día a día para pruebas rápidas en la terminal, pero para automatización seria, printf evita sorpresas desagradables.