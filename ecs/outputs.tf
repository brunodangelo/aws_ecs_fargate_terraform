output "ecs_cluster_name" {
  description = "Nombre del cluster creado"
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
  description = "Nombre del servicio creado"
  value = aws_ecs_service.ecs_service.name
}

output "task_definition_name" {
  description = "Nombre de la task definition"
  value = aws_ecs_task_definition.ecs_td.family
}