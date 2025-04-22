# aws_ecs_fargate_terraform
Despliegue de Aplicación con ECS Fargate. Infraestructura como Código con Terraform. 
Se utiliza como infraestructura base del proyecto en GITHBUB ACTIONS: https://github.com/brunodangelo/cicd_github_actions_aws

### Resources / Recursos
1 ECS Cluster
1 ECS Service
1 ECR repository
1 Load Balancer
1 Targets groups
1 LB Listeners
2 App Auto Scaling policies
2 CloudWatch Alarms
1 VPC
2 Public Subnets
1 Internet Gateway
1 S3 bucket
IAM policies

### Commands / Comandos

```
terraform init
```

```
terraform plan
```

```
terraform apply
```

