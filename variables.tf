variable "region" {
  default = "us-east-1"
  description = "Region to deploy the infrastructure"
  type = string
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
  description = "Availability zones to deploy the infrastructure"
  type = list(string)
}

variable "project_name" {
  default = "API in EC2 instance"
  description = "Project name to use in resource names"
  type = string
}

variable "ec2_prod_backend_retention_days" {
  default = 30
  description = "Retention period for backend logs"
  type = number
}

variable "prod_rds_db_name" {
  default = "api_aws"
  description = "RDS database name"
  type = string
}

variable "prod_rds_username" {
  default = "domruan"
  description = "RDS database username"
  type = string
}

variable "prod_rds_password" {
  description = "postgres password for production DB"
  type = string
}

variable "prod_rds_instance_class" {
  default = "db.t2.micro"
  description = "RDS instance type"
  type = string
}
