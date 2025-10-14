# -----------------------------
# AWS SECRETS MANAGER
# -----------------------------

# Create a Secrets Manager secret to store DB credentials
resource "aws_secretsmanager_secret" "db_secret" {
  name        = "${var.project}-db-credentials"
  description = "Database credentials for ${var.project} app"

  tags = {
    Name = "${var.project}-db-secret"
  }
}

# Store the secret values (username, password, host, dbname, port)
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    host     = aws_db_instance.mysql.address
    dbname   = var.db_name
    port     = 3306
  })
}

