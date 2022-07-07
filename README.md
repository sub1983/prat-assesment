
# Assesment 2

Tools Used
 
 

## Tech Stack

**Tools:** AWS EKS, terraform, helm chart




## Installation

Setting up the project


Running Terraform to Create the infrastrcuture including network components and EKS cluster with nodes

```bash
  cd eks-terraform/s3-remote-state
  terraform init 
  terraform plan 
  terraform apply

  Run the above commands init

  eks-terraform folder
```
    
    
## Deploy the same application

To deploy this project run

#### configure kubectl to communicate with the eks cluster
#### install helm 

Configure helm repos
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts


helm repo update
helm install my-mysql bitnami/mysql
```

Installation of MySQL

```
helm install my-mysql bitnami/mysql --values ~/eks-teraform/mysql/values.yaml -n siteassignment

```

Installation of wordpress with helm chart with custom values.yaml file update the DB details to the DB we configured

update values.yaml file for DB details and hpa confugration

```

 helm install my-wordpress bitnami/wordpress --values ~/eks-teraform/wordpress/values.yaml -n siteassignment
 

```

Install the metrics server and HPA
```
helm install my-metrics bitnami/metrics-server -n siteassignment

helm upgrade --namespace siteassignment my-metrics bitnami/metrics-server \\n    --set apiService.create=true

```

Install the node expoerter and mysql expoerter

```

helm install prometheusnode prometheus-community/prometheus-node-exporter -n siteassignment
helm install prometheusmysql prometheus-community/prometheus-mysql-exporter  -n siteassignment

```


Email Notification

This can be achieved by using pushing monitoring metrics to grafana and emails can be triggered from there with alerts 
being configured.
