# Used to decalre the value of the variables used in the main.tf file

vpc_cidr = "10.0.0.0/16"
vpc_name = "tf-ecs-vpc"

subnet_data = [ {
  name = "public-subnet-1"
  cidr = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
} ,
{
  name = "public-subnet-2"
  cidr = "10.0.2.0/24"
  availability_zone = "eu-west-1b"
}]