module "ecs" {
  source = "./ecs"
  public_subnets = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id
  ecs_execution_role_arn = module.iam.execution_role_arn
  ecs_cluster_name = "ecs-cluster-cicd"
  ecs_service_name = "app-cicd-service"
  capacity_provider = "FARGATE"
  cpu = 512
  memory = 1024
  image_uri = module.ecr.image_uri
  image_tag = "latest"
  container_name = "app-cicd-container"
  task_definition_name = "app-cicd-td"
  container_port = 3000
  host_port = 3000
}

module "vpc" {
  source = "./vpc"
  cidr_block_public_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  cidr_block_vpc = "10.0.0.0/16"
  availability_zones = ["us-east-1a","us-east-1b"]
}

module "ecr" {
    source = "./ecr"
    ecr_repo_name = "repo_cicd_app"
}

module "iam" {
  source = "./iam"
}