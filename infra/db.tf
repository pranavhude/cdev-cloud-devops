# -----------------------------
# RDS - MySQL Database
# -----------------------------

# Generate a strong random DB password
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Create a DB subnet group (for RDS in private subnets)
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = values(aws_subnet.private)[*].id

  tags = {
    Name = "${var.project}-db-subnet-group"
  }
}

# Create the MySQL RDS instance
resource "aws_db_instance" "mysql" {
  identifier             = "${var.project}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = var.db_allocated_storage
  username               = var.db_username
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "${var.project}-mysql"
  }

  depends_on = [aws_nat_gateway.nat]
}

