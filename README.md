# project objective
deploy a sonarqube app and integrate in the CI pipeline.

# infrastructure provisioning 
i used terraform to create the aks cluster and the postgres database on azure cloud.  
ps: the variables.tf is not in the repository for security reasons.  
the code below is the aks creation:  
```terraform
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.k8s_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name           = "agentpool"
    node_count     = var.agent_count
    vm_size        = "Standard_B2s"
  }

  tags = {
    Environment = "dev"
  }
}
```
azure portal after ```terraform apply```

img

# deploying the sonarqube application

the deployment is the ```manifests/sonar-dp.yaml```, i used a PersistentVolumeClaim (sonar-pvc.yaml) with 20gb of storage.  
the code below is where the deployment references the database using secrets (sonar-sec.yaml):
```
 envFrom:
  - secretRef:
     name: sonarqube-tif-sec
```
then i created a loadbalancer service to expose the application:  

img svc

accessing the external-ip address we can see the application running:

img login

# using sonarqube in the CI with azure pipelines

this is a section of the pipeline yaml file:

```yaml
stages:
- stage: Build
  displayName: Build and push stage
  jobs:
  - job: Build
    displayName: Build
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: Docker@2
      displayName: Build and push an image to container registry
      inputs:
        command: buildAndPush
        buildContext: '$(Build.Repository.LocalPath)'
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)
        tags: |
          1.0.$(semanticBuildNumber)
          latest
    - task: SonarQubePrepare@5
      inputs:
        SonarQube: 'Analyze "************"'
        scannerMode: 'CLI'
        configMode: 'manual'
        cliProjectKey: '**********************'
        cliSources: '.'
    - task: SonarQubeAnalyze@5
    - task: SonarQubePublish@5
      inputs:
        pollingTimeoutSec: '300'
 ```
after commiting in the project repository, the pipeline runs:

img pipeline

the pipeline:  
build and push the image, analyze and publish code analysis on sonarqube:

img sonarqube


python
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
