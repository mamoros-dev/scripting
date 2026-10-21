# Módulo 3: Control de Flujo (Condicionales y Códigos de Salida)

+ Hasta ahora nuestros scripts ejecutaban las líneas de arriba a abajo sin pararse a pensar. En producción, un script necesita tomar decisiones: "Si el servidor responde, haz esto; si falla, avisa por Slack o aborta la ejecución".

## El secreto de Linux: El Código de Salida (`$?`)

+ Todo, absolutamente todo lo que ejecutas en una terminal de Linux (un comando, un script, un binario) devuelve un número invisible al terminar de ejecutarse llamado Código de Salida (Exit Code).
    - `0`: Significa **Éxito total**. El comando se ejecutó sin errores.
    - Cualquier número entre `1 y 255`: Significa **Fallo**. Cada número indica un tipo de error diferente según el programa.

+ Puedes ver el código de salida del último comando ejecutado escribiendo inmediatamente en tu terminal:
```bash
echo $?
```
> Si funciona bien (verás un `0`) y después de uno que falle (verás un `1` u otro número). Los scripts de Bash utilizan este código para saber si deben continuar o detenerse.

## La estructura del `if / else` en Bash

+ La estructura básica para tomar decisiones en Bash tiene esta forma:
```Bash
if [ condición ]; then
    # Código que se ejecuta si la condición es VERDADERA (Exit Code 0)
else
    # Código que se ejecuta si la condición es FALSA (Exit Code distinto de 0)
fi
```
> (Nota de oro: Fíjate que el bloque se cierra obligatoriamente con la palabra al revés: fi).

### Los operadores de comparación más usados en el mundo real

+ Dentro de los corchetes `[ ]` evaluamos cosas. Dependiendo de qué estemos comparando, usamos unos símbolos u otros:

+ **Para cadenas de texto (Strings):**
    - `[ "$VAR" = "produccion" ]`: Comprueba si la variable es exactamente igual a la palabra "produccion".
    - `[ -z "$VAR" ]`: Comprueba si la variable está vacía (muy útil para validar si alguien olvidó pasar un parámetro).

+ **Para números:**
    - `[ "$NUMERO" -gt 10 ]`: Comprueba si el número es Greater Than (mayor que) 10.
    - `[ "$NUMERO" -eq 0 ]`: Comprueba si el número es Equal (igual a) 0.

+ **Para archivos y directorios (¡Súper vital para despliegues!):**
    - `[ -f "/etc/nginx/nginx.conf" ]`: Comprueba si el archivo existe y es un fichero válido.
    - `[ -d "/var/log/app" ]`: Comprueba si el directorio existe.


### Tu Reto Práctico del Módulo 3 (Situación de Producción)

+ Imagina que estás automatizando un script de despliegue para una aplicación en una instancia EC2. Antes de arrancar el servicio de la aplicación, el script tiene que verificar de forma obligatoria que el archivo de configuración del entorno existe en el servidor. Si no existe, no puede continuar porque rompería la aplicación.

+ El Reto:**Crea un script llamado 03-check-config.sh que haga lo siguiente:**
    - Declare una variable llamada `CONFIG_FILE` con la ruta de un archivo simulado (por ejemplo, `/etc/app/config.env`).
    - Utilice una estructura condicional `if/else` junto con el operador de comprobación de ficheros adecuado `(-f)` para verificar si ese archivo existe físicamente en el sistema.
    - `Si existe`, que imprima por pantalla un mensaje de éxito indicando que el entorno está listo y devuelva un código de salida exitoso.
    - `Si no existe`, que imprima un mensaje de error crítico por pantalla avisando de que falta el fichero y termine la ejecución de forma controlada.

```bash
#!/bin/bash

# Crea un script llamado 03-check-config.sh que haga lo siguiente:

# Declare una variable llamada `CONFIG_FILE` con la ruta de un archivo simulado (por ejemplo, `/etc/app/config.env`).
CONFIG_FILE="/tmp/config.env" # Sí existe
CONFIG_FILE_ERROR="/tmp/config2.env" # No existe

# Utilice una estructura condicional `if/else` junto con el operador de comprobación de ficheros adecuado `(-f)` para verificar si ese archivo existe físicamente en el sistema.
# `Si existe`, que imprima por pantalla un mensaje de éxito indicando que el entorno está listo y devuelva un código de salida exitoso.
# `Si no existe`, que imprima un mensaje de error crítico por pantalla avisando de que falta el fichero y termine la ejecución de forma controlada.
if [ -f "$CONFIG_FILE_ERROR" ]; then
    printf "El entorno está listo\n"
else
    printf "Error!! El entorno NO está listo y falta el fichero\n"
fi
```

+ La Solución Pro: Separar la comprobación del if
    - Para evitar este tipo de comportamientos extraños en scripts de producción, los ingenieros profesionales no evalúan el comando directamente dentro del if cuando necesitan guardar el código de salida.
    - En su lugar, ejecutan la comprobación en una línea independiente, capturan el estado al instante, y luego usan un if clásico basado en números:

```bash
#!/bin/bash

# Crea un script llamado 03-check-config.sh que haga lo siguiente:

# Declare una variable llamada `CONFIG_FILE` con la ruta de un archivo simulado (por ejemplo, `/etc/app/config.env`).
CONFIG_FILE="/tmp/config.env" # Sí existe
CONFIG_FILE_ERROR="/tmp/config2.env" # No existe

# 1. Ejecutamos el test de archivo de forma independiente
[ -f "$CONFIG_FILE_ERROR" ]

# 2. Capturamos el código de salida INMEDIATAMENTE (aquí sí se guarda bien porque no hay asignaciones de por medio)
CONFIG_STATUS=$?

# 3. Ahora el if simplemente evalúa si nuestra variable numérica es 0 o distinta de 0
if [ "$CONFIG_STATUS" -eq 0 ]; then
    printf "El entorno está listo\n"
else
    printf "Error!! El entorno NO está listo y falta el fichero\n"
    printf "El código de error real devuelto fue: %d\n" "$CONFIG_STATUS"
fi
```

## Bucles y Automatización Masiva

+ En producción, un sysadmin o cloud engineer rara vez hace las cosas una por una. Si tienes que revisar 50 servidores, vaciar 20 directorios de logs o comprobar si 10 microservicios responden, escribir el mismo comando 10 veces es una pesadilla ineficiente. Para eso están los bucles.

### El bucle for (Ideal para listas conocidas)

+ El bucle `for` te permite recorrer una lista estática de elementos (como nombres de servidores, IPs, archivos o extensiones).
```bash
for elemento in item1 item2 item3; do
    printf "Procesando: %s\n" "$elemento"
done
```
> Qué significa: En cada vuelta del bucle, la variable `elemento` toma el valor de uno de los ítems de la lista y ejecuta el bloque de código comprendido entre `do y done`.

### El bucle while (Ideal para condiciones dinámicas y polling)

+ El bucle `while` se ejecuta mientras una condición sea verdadera. Se usa muchísimo en DevOps para hacer health checks (esperar a que una base de datos o un contenedor se ponga en marcha antes de continuar el despliegue).
```bash
CONTADOR=1
while [ "$CONTADOR" -le 3 ]; do
    printf "Intentos de conexión número: %s\n" "$CONTADOR"
    # Incrementamos el contador
    CONTADOR=$((CONTADOR + 1))
done
```

### Tu Reto Práctico del Módulo 3 (Bucles en Producción)

+ Imagina que eres el DevOps de guardia y necesitas realizar un chequeo rápido de conectividad (simulado) a una lista de servidores críticos de la infraestructura antes de lanzar una actualización masiva.

+ El Reto: **Crea un script llamado 03-server-check.sh que haga lo siguiente:**
    - Declare una lista con los nombres de tres servidores en una variable (por ejemplo: SERVERS="web-01 web-02 database-01").
    - Utilice un bucle for para recorrer cada servidor de esa lista.
    - Dentro del bucle, simule una comprobación (puedes usar un mensaje por pantalla con printf que diga algo como [CHECK] Verificando estado del servidor [nombre_servidor]...).
    - Añade una condición simulada dentro del bucle (o simplemente imprime un mensaje de que el servidor está ONLINE).
```bash
#!/bin/bash

# Un script llamado 03-server-check.sh que haga lo siguiente:
# Declare una lista con los nombres de tres servidores en una variable (por ejemplo: SERVERS="web-01 web-02 database-01").
SERVERS="web-01 web-02 database-01 127.0.0.1"

# Utilice un bucle for para recorrer cada servidor de esa lista.
# Dentro del bucle, simule una comprobación (puedes usar un mensaje por pantalla con printf que diga algo como [CHECK] Verificando estado del servidor [nombre_servidor]...).
# Añade una condición simulada dentro del bucle (o simplemente imprime un mensaje de que el servidor está ONLINE).
for server in $SERVERS; do
    printf "[CHECK] Verificando estado del servidor: %s\n" "$server"
    ping -c 1 "$server"
    STATUS=$?
    if [ "$STATUS" -eq 0 ]; then
        printf "El servidor %s está ONLINE\n" "$server"
    else
        printf "El servidor %s está OFFLINE\n" "$server"
    fi
done
```

+ Resultado:
```bash
bash 03-server-check.sh 
[CHECK] Verificando estado del servidor: web-01
ping: web-01: Name or service not known
El servidor web-01 está OFFLINE
[CHECK] Verificando estado del servidor: web-02
ping: web-02: Name or service not known
El servidor web-02 está OFFLINE
[CHECK] Verificando estado del servidor: database-01
ping: database-01: Name or service not known
El servidor database-01 está OFFLINE
[CHECK] Verificando estado del servidor: 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=1.54 ms

--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.542/1.542/1.542/0.000 ms
El servidor 127.0.0.1 está ONLINE
```