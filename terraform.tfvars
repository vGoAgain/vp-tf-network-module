# Used to decalre the value of the variables used in the main.tf file

vpc_cidr = "10.0.0.0/16"
vpc_name = "tf-module-ecs-vpc"

subnet_data = {
  "private" = [
    {
      cidr= "10.0.1.0/24"
      public = false
      availability_zone = "eu-west-3a"
    },
    {
      cidr= "10.0.2.0/24"
      public = false
      availability_zone = "eu-west-3b"
    }],
  "public" = [
    {
      cidr= "10.0.3.0/24"
      public= true
      availability_zone = "eu-west-3a"
    },
    {
      cidr = "10.0.4.0/24"
      public = true
      availability_zone = "eu-west-3b"
    }]

}