variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project" {
  description = "Project prefix"
  type        = string
  default     = "cdev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs (for ALB, Bastion)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs (for EKS, RDS)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "instance_type" {
  description = "Instance type for EKS nodes or Bastion"
  type        = string
  default     = "t3.small"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes in EKS"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_allocated_storage" {
  description = "Database allocated storage in GB"
  type        = number
  default     = 20
}

variable "public_key_path" {
  description = "Path to your SSH public key (for Bastion EC2 login)"
  type        = string
  default     = "/home/ec2-user/.ssh/id_rsa.pub"
}

