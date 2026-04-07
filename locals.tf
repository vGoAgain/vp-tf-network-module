variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "AWS-Lens"
}

locals {
  prefix = "${var.project}-tf-module"
  common_tags = {
    ManagedBy = "Terraform module"
    Project   = "AWS Lens"
  }
}