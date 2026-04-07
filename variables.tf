# AWS region
variable "region" {
  default     = "eu-west-3"
  description = "The AWS region to create resources in"
}

#vpc cidr
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# vpc name
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "tf-module-vpc-ecs"
}

variable "primary_az" {
  type        = string
  description = "primary availability zone"
  default     = "eu-west-3a"
}

variable "secondary_az" {
  type        = string
  description = "secondary availability zone"
  default     = "eu-west-3b"
}

# subnet_data
# list = ["asd", "qwe", "jkl"]
# map = {"key1" = "value1", "key2" = "value2"}
# object = {"key1" = "value1", "key2" = "value2"}

variable "subnet_data" {
  type = map(list(object({
    public            = bool
    cidr              = string
    availability_zone = string
  })))
}


variable "If_public_subnet" {
  type        = bool
  description = "Whether you want a public subnet or not"
  default     = true
}

variable "need_nat_gateway" {
  type        = bool
  description = "Whether you want a nat gateway or not"
  default     = true
}

variable "need_single_nat_gateway" {
  type        = bool
  description = "Whether you want a single nat gateway or multiple"
  default     = true
}