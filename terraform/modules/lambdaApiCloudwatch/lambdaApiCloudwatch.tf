# Create an IAM role for Lambda with necessary permissions

variable "db_name" {
  description = "Database name"
  type        = string
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = var.cloudwatch_log_group_name
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


# Attach necessary policies to Lambda role (adjust policies as needed)
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name = "lambda-policy-attachment"
  roles = [aws_iam_role.lambda_role.name]

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


locals {
  aws_db_instance__instance_class__free_tier = "db.t2.micro"
  aws_db_instance__allocated_storage__free_tier = "20"
}

variable "aws_db_instance__postgres_db__username" {
  default = "postgres"
}

variable "aws_db_instance__postgres_db__password" {
  default = "postgres"
}

resource "aws_db_instance" "postgres_db" {

  # The name of the RDS instance.
  # Letters and hyphens are allowed; underscores are not.
  # Terraform default is  a random, unique identifier.
  identifier = var.db_name
  # The name of the database to create when the DB instance is created.
  name = var.db_name

  # The RDS instance class.
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  instance_class       = "db.t3.micro"

  # The allocated storage in gibibytes.
  allocated_storage    = 20

  # The database engine name such as "postgres", "mysql", "aurora", etc.
  # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  engine               = "postgres"
  engine_version = "15.3"


  # The master account username and password.
  # Note that these settings may show up in logs,
  # and will be stored in the state file in raw text.
  #
  # We strongly recommend doing this differently if you
  # are building a production system or secure system.
  #
  # These variables are set in the file .env.auto.tfvars
  # and you can see the example ffile .env.example.auto.tfvars.
  username             = var.db_username
  password             = var.db_password

  # We like to use the database with public tools such as DB admin apps.
  skip_final_snapshot = "true"
  publicly_accessible = "true"

}
output "db_instance_endpoint" {
  value       = aws_db_instance.postgres_db.endpoint
  description = "The endpoint URL of the RDS instance"
}

output "db_instance_username" {
  value       = aws_db_instance.postgres_db.username
  description = "The username of the RDS instance"
}

output "db_instance_name" {
  value       = aws_db_instance.postgres_db.name
  description = "The name of the RDS database"
}

output "db_instance_port" {
  value       = aws_db_instance.postgres_db.port
  description = "The port on which the RDS instance is listening"
}


# Create AWS Lambda function using the Docker image from ECR
resource "aws_lambda_function" "my_lambda_function" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_role.arn
  image_uri     = "${var.ecr_repo_url}:${var.docker_image_tag}"
  package_type  = "Image"

  environment {
    variables = {
      PGHOST     = aws_db_instance.postgres_db.address
      PGPORT     = aws_db_instance.postgres_db.port
      PGDATABASE = aws_db_instance.postgres_db.name
      PGUSER     = var.db_username
      PGPASSWORD = var.db_password
    }
  }
    tracing_config {
    mode = "Active"
  }

  depends_on = [aws_cloudwatch_log_group.lambda_log_group]
}
