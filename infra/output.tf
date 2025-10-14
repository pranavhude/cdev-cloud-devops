# -----------------------------
# TERRAFORM OUTPUTS
# -----------------------------

# ECR Repository URL (for Docker pushes)
output "ecr_repo_url" {
  description = "ECR repository URL to push your Docker images"
  value       = aws_ecr_repository.app.repository_url
}

# RDS Database endpoint
output "rds_endpoint" {
  description = "Private RDS MySQL endpoint (connect internally)"
  value       = aws_db_instance.mysql.address
}

# Bastion Host Public IP
output "bastion_public_ip" {
  description = "Public IP of Bastion Host (use for SSH access)"
  value       = aws_instance.bastion.public_ip
}

# EKS Cluster Name
output "eks_cluster_name" {
  description = "EKS cluster name (used for configuring kubectl)"
  value       = aws_eks_cluster.eks.name
}

# EKS API Server Endpoint
output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

# AWS Secrets Manager Secret Name
output "db_secret_name" {
  description = "Secrets Manager secret name storing DB credentials"
  value       = aws_secretsmanager_secret.db_secret.name
}

