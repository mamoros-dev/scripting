# Se conecta a la infraestructura de AWS usando la librería oficial boto3, busca instancias EC2 etiquetadas como entorno de desarrollo (Environment=Desarrollo) que estén encendidas y las apaga masivamente.
import boto3

def stop_development_instances():
    ec2 = boto3.resource('ec2')
    
    # Filtramos instancias corriendo que tengan el Tag Environment: Desarrollo
    instances = ec2.instances.filter(
        Filters=[
            {'Name': 'tag:Environment', 'Values': ['Desarrollo']},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )
    
    count = 0
    for instance in instances:
        print(f"[INFO] Apagando instancia EC2 ID: {instance.id}...")
        instance.stop()
        count += 1
        
    print(f"[OK] Se han enviado órdenes de apagado a {count} instancias de desarrollo.")

if __name__ == "__main__":
    stop_development_instances()