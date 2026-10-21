
# 🛠️ Los 4 Scripts "Clásicos" de Entrevista (¡Practícalos!)

En una entrevista para el perfil que mostraste, los entrevistadores querrán ver si sabes automatizar tareas operativas. Intenta programar estos 4 escenarios por tu cuenta:

## Reto 1: El limpiador de discos (Bash)

• El problema: Un servidor EC2 se queda sin espacio constantemente debido a los logs de la aplicación.
• Tu script debe: Buscar en el directorio /var/log todos los archivos que terminen en .log, verificar si tienen más de 7 días de antigüedad y, si es así, comprimirlos (gzip) o eliminarlos automáticamente. Además, si el espacio en disco sigue estando por encima del 80%, debe enviar una alerta en pantalla.

## Reto 2: Consumir una API y parsear JSON (Python o Bash + jq)

• El problema: Kubernetes o AWS te devuelven una salida gigante en formato JSON y necesitas extraer un dato específico de producción rápido.
• Tu script debe: Hacer un curl a una API pública (o leer un archivo local) y extraer únicamente las IP públicas de los servidores que estén en estado "running".

## Reto 3: Matar procesos huérfanos (Bash)

• El problema: Una aplicación consume demasiada CPU y deja procesos bloqueados consumiendo RAM.
• Tu script debe: Listar los procesos del sistema, identificar aquellos que lleven ejecutándose más de 5 horas consumiendo más del 50% de CPU y enviarles un comando de terminación (kill -9).

## Reto 4: Automatizar AWS con Python (boto3)

• El problema: Olvidarse instancias EC2 encendidas el fin de semana cuesta miles de dólares.
• Tu script debe: Conectarse a tu cuenta de AWS usando la librería boto3, buscar todas las instancias EC2 que tengan una etiqueta (Tag) que diga Ambiente=Desarrollo y apagarlas de forma masiva.

### 💡 Un consejo clave para escribir mejores scripts en DevOps

Cuando programes en Bash para entornos de producción, acostúmbrate siempre a poner estas tres líneas al inicio de tus scripts (justo debajo del shebang #!/bin/bash):
bash
set -e  # Hace que el script se detenga inmediatamente si cualquier comando falla.
set -u  # Lanza un error si intentas usar una variable que no ha sido definida.
set -o pipefail # Evita que los errores ocultos en tuberías (pipes '|') pasen desa

### 
🌐 Las mejores webs interactivas para practicar Scripting

1. SadServers (Imprescindible) https://sadservers.com/
	• ¿Qué es?: Un "Capture The Flag" (CTF) de servidores Linux reales.
	• Por qué te sirve: Te dan una máquina virtual estropeada (ej. "el servidor web no responde" o "el disco se ha llenado y no sabemos por qué"). Te obliga a meterte por SSH y usar comandos de terminal o crear mini-scripts Bash para diagnosticar y solucionar el problema en producción.
2. Exercism (Track de Bash) https://exercism.org/es-ES/tracks/bash
	• ¿Qué es?: Plataforma 100% gratuita con retos lógicos.
	• Por qué te sirve: Te ayuda a dominar la sintaxis pura de Bash (bucles, condicionales, manipulación de cadenas de texto y expresiones regulares) mediante retos guiados que se evalúan automáticamente.
3. Rebash (Python para DevOps) https://rebash.in/python/
	• ¿Qué es?: Una hoja de ruta y tutorial enfocado exclusivamente en el Python que de verdad usa un DevOps (manejo de archivos JSON/YAML, automatización de Linux con subprocess y llamadas a la API de AWS con boto3).