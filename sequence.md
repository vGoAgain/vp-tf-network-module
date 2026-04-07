# AWS Network Resources - Dependency Diagram

```mermaid
graph TD
    VPC["🏗️ aws_vpc\ntf-ecs-vpc"]

    subgraph PUBLIC ["PUBLIC TIER"]
        PUB_SUBNET["🌐 aws_subnet\ntf-module-ecs-public-subnet\n(count = public subnets)"]
        IGW["🌍 aws_internet_gateway\ntf-ecs-module-igw"]
        PUB_RT["📋 aws_route_table\npublic-rt\n(route: 0.0.0.0/0 → IGW)"]
        PUB_ASSOC["🔗 aws_route_table_association\npublic-rt-association"]
    end

    subgraph PRIVATE ["PRIVATE TIER"]
        PRIV_SUBNET["🔒 aws_subnet\ntf-module-ecs-private-subnet\n(count = private subnets)"]
        PRIV_RT["📋 aws_route_table\nprivate-rt\n(route: 0.0.0.0/0 → NAT GW)"]
        PRIV_ASSOC["🔗 aws_route_table_association\nprivate-rt-association"]
        PRIV_ROUTE["🛣️ aws_route\nprivate-rt-route"]
    end

    subgraph NAT ["NAT (conditional on need_nat_gateway)"]
        EIP["📌 aws_eip\ntf-ecs-module-eip\n(count: 1 or N or 0)"]
        NAT_GW["🔀 aws_nat_gateway\ntf-module-nat-gw"]
    end

    VPC --> PUB_SUBNET
    VPC --> IGW
    VPC --> PUB_RT
    VPC --> PRIV_SUBNET
    VPC --> PRIV_RT

    IGW --> PUB_RT

    PUB_SUBNET --> PUB_ASSOC
    PUB_RT --> PUB_ASSOC

    PRIV_SUBNET --> PRIV_ASSOC
    PRIV_RT --> PRIV_ASSOC

    EIP --> NAT_GW
    PRIV_SUBNET --> NAT_GW

    NAT_GW --> PRIV_ROUTE
    PRIV_RT --> PRIV_ROUTE
```

## Resource Summary

| Resource | Count | Purpose |
|---|---|---|
| `aws_vpc` | 1 | Root network container |
| `aws_subnet` (public) | N | Public-facing subnets |
| `aws_internet_gateway` | 1 | Outbound internet for public subnets |
| `aws_route_table` (public) | 1 | Routes public traffic → IGW |
| `aws_route_table_association` (public) | N | Links each public subnet to public RT |
| `aws_subnet` (private) | N | Internal subnets (no direct internet) |
| `aws_eip` | 0–N | Static IP(s) for NAT gateway |
| `aws_nat_gateway` | 0–N | Outbound internet for private subnets |
| `aws_route_table` (private) | 1 | Routes private traffic → NAT GW |
| `aws_route` (private) | 1 | Default route entry in private RT |
| `aws_route_table_association` (private) | N | Links each private subnet to private RT |
