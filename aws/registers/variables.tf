variable "aws_region" {
  default = "eu-west-1"
}

// VPC Configuration

variable "vpc_name" {
  description = "VPC name"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
}

variable "read_api_rds_username" {
  default = "postgres"
}

/*
 * Subnets
*/

// Public network used by ELBs and NAT instance
variable "public_cidr_blocks" { type = "list" }

variable "admin_ips" { type = "list" }

// RDS Configuration
variable "rds_parameter_group_name" {
  default = {
    "openregister" = "postgresrdsgroup-9-5-2"
  }
}

variable "rds_allocated_storage" {
  default = {
    "openregister" = 5
  }
}

// openregister app
variable "openregister_cidr_blocks" { type = "list" }
variable "openregister_database_cidr_blocks" { type = "list" }
variable "openregister_database_class_instance" {
  default = "db.t2.micro"
}
variable "openregister_database_master_password" {}
variable "openregister_database_apply_immediately" { default = false }

/*

 === Register toggles ===

 This *instance_count* block defines default registers

 Setting a register to 0 will disable register (or remove if register was already provisioned)

 To toggle register(s) per environment use registers/environments/<name>.tfvars instead, e.g.:

 $ grep instance_count environments/alpha.tfvars

 > instance_count.school = 1
 > instance_count.street = 1

 will provision school and street with single EC2 instances for each register.

*/

variable "instance_count" {
  default = {
    // Core registers
    "datatype" = 1
    "field" = 1
    "public-body" = 0
    "register" = 1

    // Cabinet Office
    "government-domain" = 0

    // Companies House registers
    "company" = 0

    // Department for Education registers
    "diocese" = 0
    "religious-character" = 0
    "school" = 0
    "school-admissions-policy" = 0
    "school-authority" = 0
    "school-eng" = 0
    "school-federation" = 0
    "school-gender" = 0
    "school-phase" = 0
    "school-tag" = 0
    "school-trust" = 0
    "school-type" = 0

    // Department for Communities and Local Government registers
    "local-authority" = 0
    "local-authority-eng" = 0
    "local-authority-nir" = 0
    "local-authority-sct" = 0
    "local-authority-wls" = 0
    "local-authority-type" = 0

    // Food Standards Agency registers
    "food-authority" = 0
    "food-premises" = 0
    "food-premises-type" = 0
    "food-premises-rating" = 0

    // Foreign & Commonwealth registers
    "country" = 0
    "territory" = 0
    "uk" = 0

    // Office for National Statistics registers
    "address" = 0
    "industry" = 0
    "denomination" = 0

    // Valuation Office Agency registers
    "premises" = 0

    // Address registers
    "street" = 0
    "place" = 0
  }
}

// CodeDeploy
variable "codedeploy_service_role_arn" {
  default = "arn:aws:iam::022990953738:role/code-deploy-role"
}

// https
variable "elb_certificate_arn" {}
