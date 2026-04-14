# AWS Network Terraform Module

A reusable Terraform module that provisions a complete AWS network infrastructure, including a VPC, public and private subnets, internet gateway, NAT gateway, and route tables.

## Architecture

```
                          Internet
                             │
                       ┌─────▼─────┐
                       │    IGW    │
                       └─────┬─────┘
                             │
                    ┌────────▼────────┐
                    │      VPC        │
                    │                 │
                    │  ┌───────────┐  │
                    │  │  Public   │  │
                    │  │  Subnets  │  │
                    │  └─────┬─────┘  │
                    │        │        │
                    │  ┌─────▼─────┐  │
                    │  │    NAT    │  │
                    │  │  Gateway  │  │
                    │  └─────┬─────┘  │
                    │        │        │
                    │  ┌─────▼─────┐  │
                    │  │  Private  │  │
                    │  │  Subnets  │  │
                    │  └───────────┘  │
                    └─────────────────┘
```

## Resources Created

| Resource | Description |
|---|---|
| `aws_vpc` | The VPC container for all resources |
| `aws_subnet` (public) | Internet-facing subnets |
| `aws_subnet` (private) | Internal subnets (no direct internet access) |
| `aws_internet_gateway` | Enables internet access for public subnets |
| `aws_eip` | Elastic IP(s) attached to the NAT gateway |
| `aws_nat_gateway` | Enables outbound internet for private subnets |
| `aws_route_table` (public) | Routes public traffic to the IGW |
| `aws_route_table` (private) | Routes private traffic to the NAT gateway |
| `aws_route_table_association` | Links subnets to their respective route tables |

## Usage

```hcl
module "network" {
  source = "./vp-tf-network-module"

  vpc_cidr = "10.0.0.0/16"
  vpc_name = "my-vpc"

  subnet_data = {
    public = [
      { public = true, cidr = "10.0.1.0/24", availability_zone = "eu-west-3a" },
      { public = true, cidr = "10.0.2.0/24", availability_zone = "eu-west-3b" }
    ]
    private = [
      { public = false, cidr = "10.0.3.0/24", availability_zone = "eu-west-3a" },
      { public = false, cidr = "10.0.4.0/24", availability_zone = "eu-west-3b" }
    ]
  }

  need_nat_gateway        = true
  need_single_nat_gateway = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpc_cidr` | CIDR block for the VPC | `string` | — | yes |
| `subnet_data` | Map of public/private subnet definitions (see below) | `map(list(object))` | — | yes |
| `vpc_name` | Name tag for the VPC | `string` | `"tf-module-vpc-ecs"` | no |
| `region` | AWS region | `string` | `"eu-west-3"` | no |
| `primary_az` | Primary availability zone | `string` | `"eu-west-3a"` | no |
| `secondary_az` | Secondary availability zone | `string` | `"eu-west-3b"` | no |
| `need_nat_gateway` | Whether to create NAT gateway(s) | `bool` | `false` | no |
| `need_single_nat_gateway` | Create one shared NAT gateway instead of one per private subnet | `bool` | `true` | no |
| `project` | Project name used for tagging | `string` | `"AWS-Lens"` | no |

### `subnet_data` structure

```hcl
subnet_data = {
  public = [
    {
      public            = bool    # true for public subnets
      cidr              = string  # e.g. "10.0.1.0/24"
      availability_zone = string  # e.g. "eu-west-3a"
    }
  ]
  private = [
    {
      public            = bool    # false for private subnets
      cidr              = string
      availability_zone = string
    }
  ]
}
```

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the created VPC |
| `vpc_name` | Name of the VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |

## Requirements

| Tool | Version |
|------|---------|
| Terraform | >= 1.11 |
| AWS provider | ~> 6.0 |
