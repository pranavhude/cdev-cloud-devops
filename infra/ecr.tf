# -----------------------------
# ECR - Elastic Container Registry
# -----------------------------

# Create an ECR repository to store your app container images
resource "aws_ecr_repository" "app" {
  name = "${var.project}-app" # e.g. cdev-app

  image_scanning_configuration {
    scan_on_push = true # automatically scan new images for vulnerabilities
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project}-ecr"
  }
}

# Optional: Lifecycle policy to clean up old image tags
resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images, delete older ones",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

