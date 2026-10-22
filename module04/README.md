# Módulo 4: Funciones, Argumentos y Robustez en Producción (set -euo pipefail)

+ Ahora entramos en el Módulo 4, donde aprenderás a escribir código reutilizable mediante funciones y, sobre todo, a blindar tus scripts con el santo grial de la ingeniería DevOps: set -euo pipefail.

## Concepto Teórico Breve: ¿Qué hace `set -euo pipefail`?

+ Por defecto, si un comando falla dentro de un script de Bash, el script continúa ejecutándose como si nada, lo cual en un entorno de producción puede ser catastrófico (por ejemplo, si falla la creación de una base de datos y el script continúa borrando tablas).

+ Poner `set -euo pipefail` en la cabecera de tus scripts activa tres seguros de vida obligatorios en cualquier empresa tecnológica:
    - `-e (Exit on error)`: Si cualquier comando del script falla (devuelve un código distinto de 0), el script se detiene de inmediato.
    - `-u (Unbound variable)`: Si intentas usar una variable que no ha sido declarada o está vacía, el script aborta para evitar comportamientos inesperados.
    - `-o pipefail`: Si estás usando pipes `(comando1 | comando2)`, el script detectará el error si cualquiera de los comandos del pipe falla, no solo el último.

## Funciones en Bash

+ Igual que en Python, JavaScript o cualquier otro lenguaje, una función es un bloque de código reutilizable que encapsula una tarea específica. En lugar de repetir el mismo código 5 veces en un script, lo escribes una vez dentro de una función y lo llamas tantas veces como quieras.

1. ¿Cómo se define una función?
```bash
mi_nombre_de_funcion() {
    # Aquí dentro va el código que ejecutará la función
    printf "Hola desde dentro de la función\n"
}
```
> La regla de oro: El nombre de la función seguido obligatoriamente de paréntesis vacíos (), y el bloque de código encerrado entre llaves { }.

2. ¿Cómo se llama (ejecuta) una función?
- Para invocarla, simplemente escribes su nombre en cualquier parte del script que esté por debajo de donde la definiste.
    - ⚠️ ¡Ojo con esto! A diferencia de otros lenguajes, cuando llamas a una función en Bash, no se le ponen paréntesis.
        + ❌ Mal: mi_nombre_de_funcion()
        + ✔️ Bien: mi_nombre_de_funcion

3. ¿Cómo reciben datos (Argumentos)?
- Aquí está la mayor diferencia con lenguajes como Python. En Bash, las funciones no declaran parámetros dentro de los paréntesis (porque en la definición se escriben siempre vacíos ()).
- ¿Cómo le pasamos datos entonces? A través de variables posicionales ($1, $2, $3...), exactamente igual que si le pasaras argumentos al propio script desde la terminal:
```bash
# Definición de la función que saluda a alguien
saludar() {
    # $1 recoge el primer argumento que le pasemos al llamar a la función
    printf "¡Hola, %s!\n" "$1"
}

# Llamada a la función pasándole el argumento "Carlos"
saludar "Carlos"
```
> Si ejecutas eso, la variable $1 dentro de la función tomará el valor "Carlos" y el resultado por pantalla será: ¡Hola, Carlos!.

4. Variables globales y locales:
    - **MAYÚSCULAS** (`DEPLOY_ENV, PATH, HOME`): Se reservan por convenio para variables de entorno del sistema, constantes o variables globales que afectan a todo el script.
    - **minúsculas** (`target_env, count, server`): Se usan para variables locales dentro de funciones o variables temporales de un solo uso. Esto ayuda a simple vista a saber qué vive solo en una función y qué es global.

## Tu Reto Práctico del Módulo 4

+ Para empezar con este nivel senior, crea un script llamado `04-robust-deploy.sh` que haga lo siguiente:
    - Incluya el shebang clásico (`#!/bin/bash`) y obligatoriamente la línea `set -euo pipefail` justo debajo.
    - Defina una función llamada `check_environment()` que compruebe si una variable de entorno obligatoria (por ejemplo, `DEPLOY_ENV`) está definida. (Pista: puedes usar un condicional con `[ -z "${DEPLOY_ENV:-}" ]` para validar si está vacía).
    - Si está vacía, que la función devuelva un error controlado. Si existe, que imprima un mensaje informando de que el despliegue es seguro.
    - Llame a esa función al ejecutar el script.

+ Version 1 simple:
```bash
#!/bin/bash
set -euo pipefail

check_environment() {
    if [ -z "$DEPLOY_ENV" ]; then
        printf "Error: La variable DEPLOY_ENV está vacía\n"
        #exit 1 # ya salta fallo y no continua el script
    else
        printf "Despliegue seguro para el entorno: %s\n" "$DEPLOY_ENV"
    fi
}
# Llame a esa función al ejecutar el script.
DEPLOY_ENV="" # Error: La variable DEPLOY_ENV está vacía
check_environment
DEPLOY_ENV="production" # Despliegue seguro para el entorno: production
check_environment
```
> Si está vacía sigue haciendo el script y te da el printf correspondiente. Si le ponemos el exit 1 entonces sería mejor forma porque no queremos que esté vacía e interrumpa la ejecución  
> Si no definimos la variable nos muestra error del comando `set -euo pipefail": 04-robust-deploy.sh: line 10: DEPLOY_ENV: unbound variable

+ Version 2 pasando variable:
```bash
check_environmentv2() {
    if [ -z "$1" ]; then
        printf "Error: La variable DEPLOY_ENV está vacía\n"
        exit 1
    else
        printf "Despliegue seguro para el entorno: %s\n" "$1"
    fi
}

DEPLOY_ENV="" # Error: La variable DEPLOY_ENV está vacía
check_environmentv2 "$DEPLOY_ENV"
DEPLOY_ENV="production" # Despliegue seguro para el entorno: production
check_environmentv2 "$DEPLOY_ENV"
```
> Si pasamos la variable, si es solo una toma posición de argumento `$1` y así sucesivamente `$2, $3...`

+ Version 3 y buena pasando variable local y codigo de error:
```bash
check_environmentv3() {
    local env_value="$1" # Guardamos el primer argumento en una variable local
    
    if [ -z "$env_value" ]; then
        printf "Error: El entorno está vacío\n"
        exit 1 # Forzamos la salida si falla
    else
        printf "Despliegue seguro. Entorno: %s\n" "$env_value"
    fi
}

# Llamamos a la función pasándole la variable
DEPLOY_ENV="production"
check_environment "$DEPLOY_ENV"
```
> Cuando usas local mi_variable="$1", le estás diciendo a la función: "Trabaja solo con lo tuyo, aísla este dato y protégelo del resto del script". Hace que tu código sea modular, limpio y fácil de depurar cuando hay fallos.  
> El peligro de las variables globales (sin local): Si tu script crece y tiene 20 funciones, y todas leen y escriben sobre las mismas variables globales (como DEPLOY_ENV), es muy fácil que una función cambie el valor sin querer y rompa otra parte del script. Es lo que llamamos efectos secundarios ocultos (side effects).  
> Al añadir ese exit 1 dentro del bloque de error de tu función, ejecuta el script con una variable vacía, y verás cómo el script se aborta de golpe protegiendo el sistema.

## El Gran Reto del Módulo 4: El Script de Despliegue Blindado
+ Crea un script llamado 04-robust-deploy.sh que cumpla con los siguientes requisitos profesionales:
    - Seguridad absoluta: Debe incluir el shebang y la línea set -euo pipefail en la cabecera.
    - Modularización: Debe contener una función llamada deploy_app().
    - Paso de parámetros: La función debe recibir la variable de entorno a través de un argumento ($1) y guardarlo en una variable local (local target_env="$1").
    - Validación robusta: Usando la condición -z, la función debe comprobar si el entorno recibido está vacío. Si lo está, debe imprimir un error crítico por pantalla y detener el script de inmediato con un exit 1.
    - Ejecución limpia: Si el entorno es correcto, debe imprimir un mensaje de éxito simulando que el despliegue a producción ha comenzado.
    - Llamada final: Al final del script, llama a la función pasándole una variable real (puedes probar primero a dejarla vacía para ver cómo salta el set -u / exit 1, y luego con un valor como "production").
```bash
#!/bin/bash
set -euo pipefail

deploy_app() {
    local target_env="$1"

    if [ -z "$target_env" ]; then
        printf "Error, el entorno está vacío\n"
        exit 1
    else
        printf "[INFO] El despliegue al entorno de %s ha comenzado [DEPLOYING]\n" "$target_env"
    fi
}

ENVIRONMENT=""
deploy_app "$ENVIRONMENT"
ENVIRONMENT="dev"
deploy_app "$ENVIRONMENT"
```