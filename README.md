# Etapa 1 - Programa 

O programa que printa a variável de ambiente do SO a cada 20s foi escrito em Python:

```python
import os
import time

timeout = 20.0
 
db_usr = os.getenv('USERNAME')
 
db_pass = os.getenv('PASSWORD')

def twenty_seconds_log():
    print(db_pass)    

while True:
    twenty_seconds_log()
    time.sleep(timeout)
```

As variáveis [USERNAME, PASSWORD] serão incluídas nos recursos dos deployments como Secrets.

# Etapa 2 - Criação do container e upload da imagem Docker

Criei o container utilizando o Docker, o arquivo Dockerfile ficou desse jeito:

```Dockfile
FROM python:latest

COPY main.py /

CMD ["python","-u","main.py"]
``` 

Utilizei também o [Docker Hub](https://hub.docker.com/repository/docker/thilogost123/2rpnet) como container registry para poder realizar o upload da imagem Docker: 

![](images/dockerhub.JPG)

# Etapa 3 - Instância do cluster Kubernetes

Utilizei o [minikube](https://minikube.sigs.k8s.io/docs/start/) para criar o Kubernetes local, abaixo se encontram os deployments, services e secrets:

OBS: A aplicação final é a env2rp, as outras serviram de teste.

### Deployments

![](images/deployments.JPG)

### Services

![](images/services.JPG)

### Secrets

![](images/secrets.JPG)

# Etapa 4 - Variável de ambiente e logs

Abaixo se encontra a adição da secret 'db-user-pass' como variável de ambiente no container:

      containers:
        - name: 2rpnet
          image: thilogost123/2rpnet:4.0
          env:
            - name: USERNAME
              valueFrom:
                secretKeyRef:
                  name: db-user-pass
                  key: username
            - name: PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-user-pass
                  key: password
          resources: {}

### Pod

![](images/pod.JPG)

### Logs com timestamps ativo

![](images/logs.JPG)
