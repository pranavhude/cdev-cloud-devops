# -----------------------------
# SECURITY GROUPS
# -----------------------------

# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project}-bastion-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow SSH access to bastion host"

  ingress {
    description = "Allow SSH from your IP (replace 0.0.0.0/0)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # CHANGE this to your IP e.g. "1.2.3.4/32"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-bastion-sg" }
}

# EKS Nodes Security Group
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.project}-eks-nodes-sg"
  vpc_id      = aws_vpc.this.id
  description = "EKS node group SG - allow node and pod traffic"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow internal VPC traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-eks-nodes-sg" }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow HTTP from internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-alb-sg" }
}

# RDS Security Group (allow MySQL only from EKS nodes)
resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow MySQL from EKS nodes only"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
    description     = "Allow MySQL from EKS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-rds-sg" }
}

