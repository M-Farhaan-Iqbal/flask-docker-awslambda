# Create an IAM role for Lambda with necessary permissions
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



##
#
# AWS database instance
#
##

# Define local varibles that notate what the AWS free tier can do.
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
  identifier = "postgres_db-rds"

  # The name of the database to create when the DB instance is created.
  name = "postgres_db_db"

  # The RDS instance class.
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  instance_class       = local.aws_db_instance__instance_class__free_tier

  # The allocated storage in gibibytes.
  allocated_storage    = local.aws_db_instance__allocated_storage__free_tier

  # The database engine name such as "postgres", "mysql", "aurora", etc.
  # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  engine               = "postgres"

  # The master account username and password.
  # Note that these settings may show up in logs,
  # and will be stored in the state file in raw text.
  #
  # We strongly recommend doing this differently if you
  # are building a production system or secure system.
  #
  # These variables are set in the file .env.auto.tfvars
  # and you can see the example ffile .env.example.auto.tfvars.
  username             = var.aws_db_instance__postgres_db__username
  password             = var.aws_db_instance__postgres_db__password

  # We like to use the database with public tools such as DB admin apps.
  publicly_accessible = "true"

  # We like performance insights, which help us optimize the data use.
  performance_insights_enabled = "true"

  # We like to have the postgres_db database update to the current version.
  allow_major_version_upgrade = "true"

  # We like backup retention for as long as possible.
  backup_retention_period = "35"

  # Backup window time in UTC is in the middle of the night in the United States.
  backup_window = "08:00-09:00"

  # We prefer to preserve the backups if the database is accidentally deleted.
  delete_automated_backups = "false"

  # Maintenance window is after backup window, and on Sunday, and in the middle of the night.
  maintenance_window = "sun:09:00-sun:10:00"

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
  function_name = "my-lambda-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.lambda_handler"
  runtime       = "provided.al2"
  
  image_uri = "204952858947.dkr.ecr.us-east-1.amazonaws.com/flask-app-crud:latest"
  
  environment {
    variables = {
      PGHOST     = aws_db_instance.postgres_db.address
      PGPORT     = aws_db_instance.postgres_db.port
      PGDATABASE = aws_db_instance.postgres_db.name
      PGUSER     = aws_db_instance.postgres_db.username
      PGPASSWORD = aws_db_instance.postgres_db.password

      DATABASE_URL="postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGHOST}/${PGDATABASE}}"
    }
  }
}
