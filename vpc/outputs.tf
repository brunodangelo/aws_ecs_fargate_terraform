output "public_subnets" {
  description = "Subredes publicas"
  value = aws_subnet.public_subnets.*.id
}

output "vpc_id" {
  description = "ID de la VPC"
  value = aws_vpc.vpc.id
}