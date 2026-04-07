#vpc
resource "aws_vpc" "tf-ecs-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

#CICD planning
#public - 10.0.1.0/16 10.0.2.0/16
#private - 10.0.3.0/16 10.0.4.0/16
#rds - 10.0.5.0/16  10.0.6.0/16

/* 
resource "aws_subnet" "tf-ecs-public-subnet-2" {
  # dependency (implicit)
  vpc_id                  = aws_vpc.tf-ecs-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.secondary-az

  tags = {
    Name = "${var.vpc_name}-public-subnet-2"
  }
}
 */
####################################################PUBLIC######################################################
#2 public subnet
resource "aws_subnet" "tf-module-ecs-public-subnet" {
  count = length(var.subnet_data["public"])
  vpc_id                  = aws_vpc.tf-ecs-vpc.id
  cidr_block              = var.subnet_data["public"][count.index].cidr
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_data["public"][count.index].availability_zone

  tags = local.common_tags
}

#Creating internet gateway
resource "aws_internet_gateway" "tf-ecs-module-igw" {
  vpc_id = aws_vpc.tf-ecs-vpc.id

  tags = merge(local.common_tags, {
  Name = "IGW for public subnets"
})

}

#Creating public route tables
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.tf-ecs-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ecs-module-igw.id
  }

  tags = local.common_tags
}

#Creating route table association for public subnets
resource "aws_route_table_association" "public-rt-association" {
  count = length(var.subnet_data["public"])

  subnet_id = aws_subnet.tf-module-ecs-public-subnet[count.index].id
  route_table_id = aws_route_table.public-rt.id

  depends_on = [ aws_subnet.tf-module-ecs-public-subnet , aws_route_table.public-rt]
}

####################################################PRIVATE######################################################
/*
resource "aws_subnet" "tf-ecs-private-subnet-1" {
  # dependency (implicit)
  vpc_id                  = aws_vpc.tf-ecs-vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = var.primary-az

  tags = {
    Name = "${var.vpc_name}-private-subnet-1"
  }
}

*/
#Creating private subnets
resource "aws_subnet" "tf-module-ecs-private-subnet" {
  count = length(var.subnet_data["private"])
  vpc_id                  = aws_vpc.tf-ecs-vpc.id
  cidr_block              = var.subnet_data["private"][count.index].cidr
  map_public_ip_on_launch = false
  availability_zone       = var.subnet_data["private"][count.index].availability_zone

  tags = local.common_tags
}

#Creating private route tables
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.tf-ecs-vpc.id

  tags = local.common_tags

}

#Creating route table association for private subnets
resource "aws_route_table_association" "private-rt-association" {
  count = length(var.subnet_data["private"])

  subnet_id = aws_subnet.tf-module-ecs-private-subnet[count.index].id
  route_table_id = aws_route_table.private-rt.id

  depends_on = [ aws_subnet.tf-module-ecs-private-subnet , aws_route_table.private-rt]
}

# route for the route table private-rt
resource "aws_route" "private-rt-route" {
  count = var.need_nat_gateway ? (var.need_single_nat_gateway ? 1 : (null != var.subnet_data["private"] ? length(var.subnet_data["private"]) : 0)) : 0
  route_table_id            = aws_route_table.private-rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.tf-module-nat-gw[count.index].id
}

#Creating EIP for NAT gateway
resource "aws_eip" "tf-ecs-module-eip" {
  count = var.need_nat_gateway ? (var.need_single_nat_gateway ? 1 : (null != var.subnet_data["private"] ? length(var.subnet_data["private"]) : 0)) : 0
  #count = var.need_nat_gateway ? (var.need_single_nat_gateway ? 1 : length(lookup(var.subnet_data, "private", []))) : 0

  tags = {
    Name = "tf-ecs-module-eip"
  }
}

#Creating NAT gateway
resource "aws_nat_gateway" "tf-module-nat-gw" {
  count = var.need_nat_gateway ? (var.need_single_nat_gateway ? 1 : (null != var.subnet_data["private"] ? length(var.subnet_data["private"]) : 0)) : 0
  allocation_id = aws_eip.tf-ecs-module-eip[count.index].id
  subnet_id     = aws_subnet.tf-module-ecs-private-subnet[count.index].id
}

/*
#route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.tf-ecs-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ecs-igw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.tf-ecs-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-nat-gw.id
  }

  tags = {
    Name = "private"
  }
}

#route table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.tf-ecs-public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.tf-ecs-public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.tf-ecs-private-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.tf-ecs-private-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}
/*
resource "aws_route_table_association" "e" {
  subnet_id      = aws_subnet.tf-ecs-rds-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "f" {
  subnet_id      = aws_subnet.tf-ecs-rds-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}
*/

/*
#igw
resource "aws_internet_gateway" "tf-ecs-igw" {
  vpc_id = aws_vpc.tf-ecs-vpc.id

  tags = {
    Name = "tf-ecs-igw"
  }
}

#nat gateway
resource "aws_nat_gateway" "tf-nat-gw" {
  allocation_id = aws_eip.tf-eip.id
  subnet_id     = aws_subnet.tf-ecs-public-subnet-1.id
  
  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # explicit dependency 
  depends_on = [aws_internet_gateway.tf-ecs-igw]
}

#eip
resource "aws_eip" "tf-eip" {

  tags = {
    Name = "tf-eip"
  }
}


#2 private subnet
resource "aws_subnet" "tf-ecs-rds-subnet-1" {
  # dependency (implicit)
  vpc_id                  = aws_vpc.tf-ecs-vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = false
  availability_zone = var.primary-az

  tags = {
    Name = "${var.vpc_name}-rds-subnet-1"
  }
}

resource "aws_subnet" "tf-ecs-rds-subnet-2" {
  # dependency (implicit)
  vpc_id                  = aws_vpc.tf-ecs-vpc.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = false
  availability_zone = var.secondary-az

  tags = {
    Name = "${var.vpc_name}-rds-subnet-2"
  }
}
*/