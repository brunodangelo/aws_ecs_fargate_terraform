variable "ecs_cluster_name" {
  description = "Nombre del Cluster en ECS a crear"
  type = string
}

variable "capacity_provider" {
  description = "Capacity provider (Ej.: FARGATE)"
  type = string
}

variable "cpu" {
  description = "CPU por cada tarea"
  type = number
}

variable "memory" {
  description = "Memoria por cada tarea"
  type = number
}

variable "container_name" {
  description = "Nombre de los contenedores a crear"
  type = string
}

variable "public_subnets" {
  description = "Subredes públicas"
  type = list(string)
}

variable "vpc_id" {
  description = "ID de la VPC"
  type = string
}

variable "ecs_execution_role_arn" {
  description = "ARN del executionRole"
  type = string
}

variable "image_uri" {
  description = "URI de la imagen de docker"
  type = string
}

variable "image_tag" {
  description = "Etiqueta de la imagen"
  type = string
}

variable "container_port" {
  description = "Puerto del contenedor"
  type = number
}

variable "host_port" {
  description = "Puerto del HOST"
  type = number
}

variable "ecs_service_name" {
  description = "Nombre del servicio de ECS"
  type = string
}

variable "task_definition_name" {
  description = "Nombre de la task definition"
  type = string
}