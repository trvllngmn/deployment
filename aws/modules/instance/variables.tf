variable "id" {}
variable "role" {}
variable "vpc_id" {}
variable "vpc_name" {}

// Instance properties

variable "instance_ami" {
  default = "ami-a10897d6"
}

variable "instance_count" {
  default = 1
}

variable "instance_type" {
  default = "t2.micro"
}

variable "iam_instance_profile" {}

variable "zones" {
  default = {
    "0" = "eu-west-1a"
    "1" = "eu-west-1b"
    "2" = "eu-west-1c"
  }
}

variable "user_data" {}
variable "subnet_ids" {}

variable "security_group_ids" {}