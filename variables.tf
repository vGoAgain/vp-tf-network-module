#vpc cidr



variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# vpc name
variable "vpc_name" {
    description = "Name of the VPC"
    type        = string    
}

# subnet_data
# list = ["asd", "qwe", "jkl"]
# map = {"key1" = "value1", "key2" = "value2"}
# object = {"key1" = "value1", "key2" = "value2"}
variable "subnet_data" {
  type = list(object({
    name = string
    cidr = string
    availability_zone = string
  }))
  description = "List of subent to create"
}

variable "If_public_subnet" {
  type = bool
  description = "Whether you want a public subnet or not"
  default = true
}