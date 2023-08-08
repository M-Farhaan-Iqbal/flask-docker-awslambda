# Create an ECR repository
resource "aws_ecr_repository" "flask-app-crud" {
  name = "flask-app-crud"
}