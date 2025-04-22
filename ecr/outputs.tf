output "image_uri" {
  description = "URI de la imagen de Docker"
  value = aws_ecr_repository.ecr_repo.repository_url
}

output "repo_name" {
  description = "Nombre del repositorio creado"
  value = aws_ecr_repository.ecr_repo.name
}