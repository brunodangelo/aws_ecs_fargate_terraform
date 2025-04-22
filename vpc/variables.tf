variable "cidr_block_vpc" {
  description = "CIDR Block de la VPC"
  type = string
}

variable "cidr_block_public_subnets" {
  description = "CIDR block para las subredes publicas"
  type = list(string)
}

variable "availability_zones" {
  description = "Zonas de disponibilidad utilizadas"
  type = list(string)
}