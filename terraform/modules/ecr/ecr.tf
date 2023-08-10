# Create an ECR repository
resource "aws_ecr_repository" "flask-app-crud" {
  name = "flask-app-crud"
}
output "ecr_repo_url" {
  value = aws_ecr_repository.flask-app-crud.repository_url
}
