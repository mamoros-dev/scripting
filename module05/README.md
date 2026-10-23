# Módulo 5: Procesamiento de Archivos y Automatización de Configuraciones

+ Has aprendido a crear scripts seguros, lógicos y modulares. En el Módulo 5, daremos el salto a una necesidad real del día a día de un Cloud/DevOps Engineer: leer, parsear y manipular ficheros de configuración y logs (como ficheros .env, JSON, o archivos de configuración de infraestructura).

+ Cuando tienes un archivo de configuración o una lista de IPs/servidores guardada en un fichero externo (por ejemplo, servers.txt), el estándar de oro en Bash para leerlo sin romperte la cabeza con los espacios o saltos de línea es combinar un bucle while con el comando read y una redirección de entrada (<):
```bash
while IFS= read -r linea; do
    printf "Procesando línea: %s\n" "$linea"
done < "servers.txt"
```
> Es simplemente un bucle que dice: "Mientras queden líneas en el archivo .env, mételas una a una en la variable $linea (sin alterar los espacios) para que yo pueda hacer algo con ellas en la pantalla".  
+ Desglose de los términos clave:
    - **IFS= (Internal Field Separator vacía)**: Evita que Bash elimine los espacios en blanco que pueda haber al principio o al final de cada línea del archivo. Es una buena práctica obligatoria.
    - **-r (Raw)**: Evita que Bash interprete las barras invertidas (\) como caracteres de escape (por ejemplo, si en el archivo hay rutas de Windows o caracteres especiales).
    - **< "servers.txt"**: Le alimenta el contenido del archivo línea por línea al bucle.

## Cómo Bash lee y manipula archivos

+ A diferencia de lenguajes como Python, donde abres un archivo con open() y tienes un objeto lleno de métodos, en Bash trabajamos con el **Flujo de Entrada/Salida Estándar (I/O Streams)** heredado directamente de Unix.

**1. El concepto de "Redirección" (`<`)**
+ En Linux, los comandos suelen leer de la entrada estándar (tu teclado) y escribir en la salida estándar (la pantalla).
    - Si quieres que un comando lea el contenido de un archivo en lugar del teclado, utilizas el operador < (Redirección de entrada).
    - Ejemplo: `cat < archivo.txt` le dice a `cat`: "No esperes a que escriba nada, lee el contenido de este archivo y muéstralo".

**2. El comando `read` (El lector de líneas)**
+ El comando read lee una sola línea de texto de la entrada y la guarda en una variable.
    - Si ejecutas `read mi_variable`, Bash se quedará esperando a que escribas algo en la terminal y pulses Enter. Lo que escribas se guardará en `mi_variable`.

**3. ¿Por qué usamos esa estructura tan rara (`while IFS= read -r`)?**
+ Cuando juntas el bucle while con read y un archivo redirigido, estás creando un lector de archivos hipereficiente que consume muy poca memoria (ideal para servidores con recursos ajustados). Vamos a desglosar pieza por pieza lo que significa cada palabra:
    - `while IFS= read -r linea; do`:
        + `read -r linea`: Lee una línea del archivo y la mete en la variable llamada `linea`. El `-r (raw)` es vital porque le prohíbe a Bash volverse loco si encuentra barras invertidas (`\`) en el texto.
        + `IFS= (Internal Field Separator vacío)`: Aquí está el mayor misterio. IFS es una variable interna de Bash que decide qué se considera un "separador" (por defecto son los espacios, tabuladores y saltos de línea). Si dejas el `IFS` por defecto, cuando Bash lee una línea con espacios al principio o al final, los recorta y borra. Al escribir `IFS=` justo antes del `read`, le decimos: "Por favor, lee la línea tal cual está, respetando cada espacio en blanco".
    - `done < ".env"`: Le indica al bucle `while` que la fuente de alimentación de datos no es la terminal, sino el archivo `.env` que le estamos inyectando por la tubería de entrada (`<`).

## Tu Reto Práctico del Módulo 5

+ Imagina que tienes un archivo de configuración de entorno simulado llamado .env en la raíz de tu proyecto, con este contenido:
```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=production_db
```

+ El Reto: **Crea un script llamado `05-parse-env.sh` que haga lo siguiente:**
    - Incluya la cabecera de seguridad obligatoria (`#!/bin/bash y set -euo pipefail`).
    - Cree o asuma la existencia de un fichero `.env` (puedes hacer que el propio script cree el fichero con esas tres líneas usando redirecciones como `cat << EOF > .env`, o crearlo tú a mano).
    - Utilice el bucle `while IFS= read -r linea; do ... done < .env` para leer el archivo línea por línea.
    - Dentro del bucle, imprima por pantalla cada línea formateada limpiamente (por ejemplo: `[CONFIG] Leído -> [línea]`).
```bash
#!/bin/bash
set -euo pipefail

while IFS= read -r linea; do
    printf "[CONFIG] Leído -> %s\n" "$linea"
done < "file.env"
```
> [CONFIG] Leído -> DB_HOST=localhost  
> [CONFIG] Leído -> DB_PORT=5432  
> [CONFIG] Leído -> DB_NAME=production_db  

+ Separando datos por clave/valor:
```bash
#!/bin/bash
set -euo pipefail

# ejercicio separando la linea con clave/valor
while IFS='=' read -r clave valor; do
    printf "Clave detectada: %s con valor: %s\n" "$clave" "$valor"
done < "file.env"
```
> Clave detectada: DB_HOST con valor: localhost  
> Clave detectada: DB_PORT con valor: 5432  
> Clave detectada: DB_NAME con valor: production_db  

## Cómo filtrar comentarios y líneas vacías (El estándar profesional)

+ Para solucionar esto, añadimos pequeños filtros condicionales al principio de cada vuelta del bucle utilizando doble corchete [[ ... ]] y la orden continue (que le dice a Bash: "Salta esta línea y vete directamente a la siguiente").
```bash
#!/bin/bash
set -euo pipefail

printf "--- INICIO DEL PROCESAMIENTO LIMPIO ---\n"

while IFS='=' read -r clave valor; do
    
    # 1. Filtro: Si la línea está vacía, sáltala
    [[ -z "$clave" ]] && continue
    
    # 2. Filtro: Si la clave empieza por '#', es un comentario, sáltala
    # Usamos "=~" que es el operador de expresiones regulares (significa "empieza por #")
    [[ "$clave" =~ ^# ]] && continue

    # Si pasa los filtros, procesamos la clave y el valor de forma limpia
    printf "Configuración válida -> Clave: [%s] | Valor: [%s]\n" "$clave" "$valor"

done < "file.env"
```
> ### INICIO DEL PROCESAMIENTO LIMPIO ###  
> Configuración válida -> Clave: [DB_HOST] | Valor: [localhost]  
> Configuración válida -> Clave: [DB_PORT] | Valor: [5432]  
> Configuración válida -> Clave: [DB_NAME] | Valor: [production_db]  

+ Desglose de las nuevas herramientas:
    - [[ ... ]] && continue: Es una forma abreviada en Bash de escribir un if de una sola línea. Significa: "Si se cumple esta condición, ejecuta el continue".
    - [[ "$clave" =~ ^# ]]:
        + ^ en expresiones regulares significa "principio de la línea".
        + Por lo tanto, ^# le dice a Bash: "Comprueba si esta variable comienza exactamente con el carácter almohadilla". Si es así, lo identifica como comentario y lo descarta.

## Catálogo de Operadores en Bash

```bash
A. Operadores de Cadenas de Texto (Strings)
[ -z "$var" ]: Verdadero si la cadena está vacía (longitud 0).
[ -n "$var" ]: Verdadero si la cadena no está vacía (tiene contenido).
[[ "$var1" == "$var2" ]]: Verdadero si ambas cadenas son idénticas.
[[ "$var1" != "$var2" ]]: Verdadero si las cadenas son distintas.
[[ "$var" =~ regex ]]: Verdadero si la cadena coincide con una expresión regular.

B. Operadores Numéricos (Enteros)
-eq (Equal): Igual a (==)
-ne (Not equal): Distinto de (!=)
-gt (Greater than): Mayor que (>)
-lt (Less than): Menor que (<)
-ge / -le: Mayor o igual / Menor o igual.

C. Operadores de Ficheros (SysAdmin & DevOps)
[ -f "$archivo" ]: Verdadero si el archivo existe y es un fichero ordinario.
[ -d "$directorio" ]: Verdadero si el directorio existe.
[ -s "$archivo" ]: Verdadero si el archivo existe y su tamaño es mayor a 0 (no está vacío).
```

## Inyección Dinámica de Variables (declare)

+ En Bash, puedes crear variables al vuelo utilizando el comando `declare` (o export si quieres que los procesos hijos también las hereden). Esto nos permite coger la `$clave y el $valor` que hemos leído del archivo y convertirlos en una variable real del sistema.
```bash
#!/bin/bash
set -euo pipefail
printf "### CARGANDO CONFIGURACIÓN DESDE .ENV ###\n"
while IFS='=' read -r clave valor; do
    
    # 1. Filtro: Si la línea está vacía, sáltala
    [[ -z "$clave" ]] && continue
    
    # 2. Filtro: Si empieza por '#', es un comentario, sáltala
    [[ "$clave" =~ ^# ]] && continue

    # 3. Inyección dinámica: Convertimos texto plano en una variable real de Bash
    declare "${clave}=${valor}"
    
    printf "Inyectada con éxito -> Variable: [%s] = [%s]\n" "$clave" "$valor"

done < "file.env"

printf "\n--- COMPROBANDO QUE LAS VARIABLES FUNCIONAN ---\n"
# Ahora podemos usar las variables directamente como si hubieran estado siempre ahí
printf "\n-> DB_HOST actual: %s\n" "$DB_HOST"
printf "\n-> DB_PORT actual: %s\n" "$DB_PORT"
printf "\n-> DB_NAME actual: %s\n" "$DB_NAME"
```
+ Resultados:
```bash
### CARGANDO CONFIGURACIÓN DESDE .ENV ###
Inyectada con éxito -> Variable: [DB_HOST] = [localhost]
Inyectada con éxito -> Variable: [DB_PORT] = [5432]
Inyectada con éxito -> Variable: [DB_NAME] = [production_db]
--- COMPROBANDO QUE LAS VARIABLES FUNCIONAN ---
-> DB_HOST actual: localhost
-> DB_PORT actual: 5432
-> DB_NAME actual: production_db
```

## Filtrado de Logs y Patrones con grep en Bash

+ Cuando te enfrentas a un servidor caído, lo primero que haces es mirar los ficheros de logs (/var/log/...). Leerlos enteros es imposible; necesitamos que nuestros scripts busquen palabras clave (como ERROR, FATAL, o una IP concreta) de forma quirúrgica.

**1. El gran peligro de grep con set -euo pipefail**  
+ Antes de ver el código, recuerda que tenemos activo el -e (salir si un comando falla).
El comando grep tiene una particularidad: si busca un patrón y NO lo encuentra, devuelve un código de salida 1 (indicando que no hubo coincidencias). Si pones un grep a pelo en tu script y no encuentra la palabra "ERROR", el script morirá al instante pensando que ha habido un fallo grave. Para evitarlo, los profesionales suelen usar un truco: añadir || true al final del grep para indicarle a Bash que si no encuentra nada, no pasa nada grave.

**2. Ejemplo Práctico: El Analizador de Logs**  
+ Imagina que tenemos un archivo de log simulado llamado app.log con este contenido:
```bash
[2026-10-23 10:00:01] [INFO] Servidor iniciado correctamente en puerto 8080
[2026-10-23 10:05:12] [WARN] Conexión lenta a la base de datos (latencia 450ms)
[2026-10-23 10:10:33] [ERROR] Fallo crítico al autenticar contra el servicio LDAP
[2026-10-23 10:15:00] [INFO] Petición HTTP GET /healthcheck OK (200)
[2026-10-23 10:20:45] [ERROR] Timeout de conexión con la API externa de pagos
```

+ Podemos crear un script llamado 05-parse-logs.sh que combine lo que ya sabemos (bucle while read) con patrones de búsqueda para extraer solo los errores y lanzar alertas:
```bash
#!/bin/bash
set -euo pipefail

printf "%s\n" "--- ANALIZANDO LOGS DEL SISTEMA ---"

# Contador de errores encontrados
contador_errores=0

while IFS= read -r linea; do
    
    # Usamos el operador =~ para buscar la palabra "ERROR" dentro de la línea
    if [[ "$linea" =~ ERROR ]]; then
        printf "[ALERTA] Línea sospechosa detectada -> %s\n" "$linea"
        contador_errores=$((contador_errores + 1)) # Incrementamos el contador
    fi

done < "app.log"

printf "%s\n" "-----------------------------------"
printf "Análisis finalizado. Total de errores críticos encontrados: %d\n" "$contador_errores"
```
> Ponemos IFS= (con el igual pero sin valor después) para dejar la variable IFS vacía.  
> Al dejarlo vacío (IFS=), le quitamos esa propiedad a Bash exclusivamente durante esa línea de lectura. De esta forma, obligamos al comando read a leer la línea entera tal cual viene, respetando cada espacio o tabulación que tenga al principio o al final, sin recortar nada.

```bash
bash 05-parse-env-grep.sh 
--- ANALIZANDO LOGS DEL SISTEMA ---
[ALERTA] Línea sospechosa detectada -> [2026-10-23 10:10:33] [ERROR] Fallo crítico al autenticar contrael servicio LDAP
[ALERTA] Línea sospechosa detectada -> [2026-10-23 10:20:45] [ERROR] Timeout de conexión con la API externa de pagos
Análisis finalizado. Total de errores críticos encontrados: 2
```