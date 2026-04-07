# This file defines the output values for the VPC module.
# Outputs expose resource attributes so they can be referenced by other modules or root configurations.

# The VPC ID - needed by any resource that must be deployed inside this VPC (subnets, security groups, etc.)
output "vpc_id" {
  value = aws_vpc.tf-ecs-vpc.id
}

# The VPC name - useful for tagging or naming dependent resources consistently
output "vpc_name" {
  value = var.vpc_name
}

# List of public subnet IDs - used by internet-facing resources such as load balancers, bastion hosts, NAT gateways
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.tf-module-ecs-public-subnet[*].id
}

# List of private subnet IDs - used by internal resources such as ECS tasks, RDS instances, Lambda functions
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.tf-module-ecs-private-subnet[*].id
}
