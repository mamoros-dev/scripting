# Módulo 6: El bisturí del Cloud (jq)

## Comando JQ

+ `jq` es **exclusivo para JSON** (su nombre viene de JSON Query). No sirve para leer XML, YAML puro o texto plano (para eso tenemos grep, awk o sed).

+ Cuando ejecutas un comando como `aws ec2 describe-instances`, la nube te escupe una cantidad monstruosa de texto en formato JSON. Leer eso a ojo es imposible. Aquí es donde entra `jq`.

+ Herramientas como `kubectl o aws` tienen múltiples salidas por defecto (tablas bonitas para humanos). Para que `jq` pueda leerlos, siempre debemos forzar que devuelvan JSON crudo (`-o json` en Kubernetes, `--output json` en AWS, o `--format '{{json .}}'` en Docker). Si no le das JSON, jq fallará.

+ `jq` es una herramienta de línea de comandos que actúa como un filtro de precisión quirúrgica para extraer exactamente el dato que necesitas (por ejemplo, dame solo la `IP pública` de la instancia con `ID i-12345678`).
    - jq es una utilidad ligera que se instala directamente en tu terminal (Linux, macOS o WSL en Windows). Dependiendo de tu sistema operativo, se instala con un solo comando:
    ```bash
    # Ubuntu/debian
    sudo apt-get update && sudo apt-get install -y jq

    # Centos/Fedora
    sudo dnf install jq

    # MAC
    brew install jq
    ```
    > Para comprobar que se ha instalado bien: Escribe `jq --version` en tu terminal

+ Imagina que el formato JSON (el lenguaje universal en el que se comunican las aplicaciones y la nube) es una caja fuerte llena de cajones dentro de otros cajones.
Si intentas leer un JSON gigante en la terminal, te saldrá un bloque infinito de texto ilegible.

+ `jq` es tu llave maestra. Le dices exactamente qué cajón quieres abrir y te devuelve solo el dato exacto que pides, limpio y sin adornos.

### Ejemplo Simulado Simple Paso a Paso JQ

+ Ejemplo Json:
```JSON
{
  "id": "i-0abc123456789xyz",
  "estado": "running",
  "tipo": "t3.medium",
  "tags": {
    "Name": "web-production-01",
    "Environment": "prod"
  },
  "ip_publica": "54.210.15.88"
}
```

+ **Extraer un campo simple**: Si solo quieres saber el estado del servidor, usas un `punto seguido` de la clave:
```bash
❯ jq '.estado' servidor.json
"running"

❯ jq ".tipo" servidor.json 
"t3.medium"
```

+ **Navegar por objetos anidados (Cajones dentro de cajones)**: Fíjate que el campo `tags` tiene dentro `otro objeto (Name, Environment)`. Para entrar dentro de tags y sacar el nombre del servidor, encadenamos los puntos:
```bash
> jq '.tags.Name' servidor.json
"web-production-01"

❯ jq .tags.Environment servidor.json
"prod"
```
> Cuándo NO necesitas comillas: Si el nombre de la propiedad es una palabra normal sin espacios ni caracteres raros (como estado, id, cpu_usage), escribes directamente .estado.  

> Cuándo SÍ necesitas comillas: Si una clave del JSON tiene espacios, guiones medios o caracteres especiales (por ejemplo, si la clave fuera "cpu-usage" o "ip publica"), jq se confundiría si escribes .ip publica. En esos casos obligatorios, debes usar comillas dobles dentro de las dobles de Bash o escapar, ej: ."ip publica" o ."cpu-usage".

+ **Limpiar las comillas (`-r` de Raw)**: Por defecto, jq te devuelve los resultados con comillas dobles (porque respeta el formato JSON). Si quieres que te devuelva el texto limpio para guardarlo en una variable de Bash, añades la bandera `-r`:
```bash
❯ jq -r '.ip_publica' servidor.json
54.210.15.88

❯ jq -r ".tipo" servidor.json 
t3.medium
```

### Ejemplo Simulado Complejo Paso a Paso JQ

+ Ejemplo que te devuelven listas o arrays (múltiples servidores, múltiples pods, múltiples discos):
```SQL
{
  "region": "eu-west-1",
  "servers": [
    { "id": "i-001", "name": "web-prod-01", "estado": "running", "cpu_usage": 45 },
    { "id": "i-002", "name": "web-prod-02", "estado": "stopped", "cpu_usage": 0 },
    { "id": "i-003", "name": "db-prod-01", "estado": "running", "cpu_usage": 88 },
    { "id": "i-004", "name": "cache-01", "estado": "running", "cpu_usage": 12 }
  ]
}
```

+ **El operador de despaquetado de listas ([])**: Si intentas hacer `jq '.servers.name'`, jq se quejará porque servers es una lista (un array entre corchetes [...]), no un objeto directo. Para decirle a jq: "Entra en la lista y mira cada uno de sus elementos", utilizamos el `operador de despaquetado []`:
```bash
❯ jq -r '.region' servers-list.json 
eu-west-1

❯ jq -r '.servers[].name' servers-list.json
web-prod-01
web-prod-02
db-prod-01
cache-01

❯ jq -r '.servers[0].name' servers-list.json
web-prod-01

❯ jq '.servers[-1].name' servers-list.json
"cache-01"
```
> Qué ha hecho: Ha recorrido la lista entera y ha extraído el nombre de cada servidor uno a uno.

+ **Filtrar elementos con la función select() (El "if" de jq)**: Imagina que quieres que el script te devuelva únicamente los servidores que están parados (stopped) para saber cuáles encender. Para eso usamos la función select() combinada con una condición:
```Bash
❯ jq '.servers[] | select(.estado == "stopped")' servers-list.json
{
  "id": "i-002",
  "name": "web-prod-02",
  "estado": "stopped",
  "cpu_usage": 0
}

❯ jq '.servers[] | select('.estado' == "running")' servers-list.json
{
  "id": "i-001",
  "name": "web-prod-01",
  "estado": "running",
  "cpu_usage": 45
}
{
  "id": "i-003",
  "name": "db-prod-01",
  "estado": "running",
  "cpu_usage": 88
}
{
  "id": "i-004",
  "name": "cache-01",
  "estado": "running",
  "cpu_usage": 12
}
```
> Qué ha hecho: El símbolo de tubería `(|)` pasa los elementos de la lista al comando `select()`, el cual filtra y muestra solo el objeto que cumple la condición `(.estado == "stopped")`.

+ **Extracción quirúrgica combinada (Filtro + Dato específico)**: Siguiendo con el ejemplo anterior, imagínate que no quieres ver todo el bloque JSON del servidor parado, sino solo su ID para pasárselo a otro comando de automatización. Solo tienes que encadenar el punto al final:
```bash
❯ jq '.servers[] | select(.estado == "stopped").id' servers-list.json
"i-002"

❯ jq -r '.servers[] | select(.estado == "stopped").id' servers-list.json
i-002

❯ jq -r '.servers[] | select(.estado == "stopped").name' servers-list.json
web-prod-02

❯ jq -r '.servers[] | select(.estado == "running").id' servers-list.json
i-001
i-003
i-004
❯ jq -r '.servers[] | select(.estado == "running") | .id' servers-list.json
i-001
i-003
i-004
```
> Ambas devuelven exactamente el mismo resultado. Los ingenieros suelen usar la segunda opción (select(...).id) porque es más corta y limpia de escribir en la terminal, pero ambas son 100% válidas.

### Simulación Práctica: El Desafío de Monitoreo Cloud

+ Imagina que eres el SRE de guardia y recibes un reporte del estado de los servidores de producción (servers-list.json). Tu jefe te pide que obtengas los nombres (name) de todos aquellos servidores cuyo uso de CPU sea superior al 40%.

+ Para resolverlo, tendrás que combinar tres herramientas de jq que ya hemos visto:
    - Despaquetar la lista ([]).
    - Filtrar usando un operador numérico en el select() (por ejemplo, > 40).
    - Extraer de forma limpia solo el nombre (.name) sin comillas (-r).
```bash
❯ jq -r '.servers[] | select(.cpu_usage > 40).name' servers-list.json
web-prod-01
db-prod-01
```
> la lista despaquetada, el operador numérico con el select(), el atajo del punto para extraer .name y el -r para limpiar las comillas. El resultado (web-prod-01 y db-prod-01) es exactamente el correcto.

## Integración de jq con CLIs Cloud (AWS y Kubernetes)

+ En el mundo real, no guardamos los JSONs en archivos locales como servers-list.json. Los comandos oficiales de la nube (`aws` para Amazon Web Services y `kubectl` para Kubernetes) le piden la información directamente a los servidores de la infraestructura y te devuelven un chorro masivo de datos en formato JSON en tiempo real.

+ Vamos a ver cómo se conecta la tubería de Bash (`|`) con `jq` para automatizar tareas reales en entornos Cloud.

### Escenario 1: Automatización en AWS (Amazon Web Services)

+ Imagina que necesitas que un script compruebe automáticamente si hay instancias EC2 (servidores virtuales) que se hayan quedado encendidas por error en un entorno de desarrollo para apagarlas y ahorrar costes.

+ El comando de AWS para listar las instancias es `aws ec2 describe-instances`. Como eso devuelve un JSON gigantesco, lo filtramos al vuelo con `jq`:
```bash
# Ver el estado de todas tus instancias en una tabla limpia:
aws ec2 describe-instances \
    --query "Reservations[*].Instances[*].{ID: InstanceId, Tipo: InstanceType, Estado: State.Name}" \
    --output json
```
> Nota: Aunque AWS tiene su propio parámetro `--query` usando JMESPath, los ingenieros muchas veces prefieren capturar el JSON bruto y delegar el filtrado final a `jq` para tener un control total de la lógica en Bash

+ Imagina que quieres extraer únicamente los IDs de las instancias EC2 que están en estado stopped para meterlas en una variable de tu script y arrancarlas:
```bash
# El comando real combinando Bash, AWS CLI y jq:
#!/bin/bash
set -euo pipefail

printf "%s\n" "--- BUSCANDO INSTANCIAS PARADAS EN AWS ---"

# Ejecutamos el comando de AWS y lo canalizamos directamente a jq
ids_paradas=$(aws ec2 describe-instances --output json | jq -r '.Reservations[].Instances[] | select(.State.Name == "stopped") | .InstanceId')

if [[ -z "$ids_paradas" ]]; then
    printf "%s\n" "No hay ninguna instancia parada."
else
    printf "Instancias encontradas para arrancar:\n%s\n" "$ids_paradas"
fi

######
bash ids_paradas.sh 
--- BUSCANDO INSTANCIAS PARADAS EN AWS ---
No hay ninguna instancia parada.
```
> El comando de AWS escupe el JSON, la tubería (`|`) lo transporta al instante hacia `jq`, este filtra los estados, extrae el `InstanceId`, limpia las comillas (`-r`) y guarda el resultado limpio dentro de la variable de Bash `$ids_parada`s. ¡Magia pura de automatización Cloud!

### Escenario 2: Automatización en Kubernetes (kubectl)

+ En Kubernetes, la herramienta de comandos es kubectl. Trabajar con pods, deployments y servicios en producción exige monitorización constante.

+ Imagina que quieres que tu script revise si hay algún Pod en tu clúster que haya fallado y esté en estado CrashLoopBackOff o Error para registrarlo.
```bash
# Obtener la lista de Pods en formato JSON:
kubectl get pods -n production -o json
```

+ El comando con jq para extraer los pods caídos:
```bash
#!/bin/bash
set -euo pipefail

printf "%s\n" "--- AUDITANDO PODS EN KUBERNETES ---"

# Extraemos el nombre de los pods cuyo estado no sea "Running" o "Completed"
pods_problematicos=$(kubectl get pods -n production -o json | jq -r '.items[] | select(.status.phase != "Running" and .status.phase != "Completed") | .metadata.name')

if [[ -z "$pods_problematicos" ]]; then
    printf "%s\n" "¡Todo perfecto! No hay pods con problemas."
else
    printf "[ALERTA] Se han detectado los siguientes pods con incidencias:\n%s\n" "$pods_problematicos"
fi
```

## El Patrón Universal Cloud + Bash + jq

+ Fíjate que el patrón de ingeniería es siempre idéntico, independientemente de si usas AWS, Kubernetes, la API de GitHub o Docker:
```bash
[Herramienta Cloud CLI] --> [pipe] (|) --> [jq con filtros y select] --> [Variable / Lógica en Bash]
```
1. Pides los datos a la nube en JSON (aws... o kubectl...).  
2. Los envías por tubería a jq (| jq -r ...).  
3. Filtras con select() y extraes el campo que necesitas.  
4. Lo guardas en una variable de Bash para tomar decisiones (alertar, reiniciar, borrar, etc.).  