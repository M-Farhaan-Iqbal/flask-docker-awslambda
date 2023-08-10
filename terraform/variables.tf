variable "my_repository" {
  description = "my_repository"
  type        = string
  default     = "flask-app-crud"
}
variable "docker_image_tag" {
  description = "Docker image tag for Lambda"
  default     = ""
  type        = string
}

variable "ecr_repo_url" {
  description = "ECR repository URL for Lambda Docker image"
  default     = ""
  type        = string
}
variable "lambda_name" {
  description = "Lambda function name"
  default     = ""
  type        = string
}
variable "db_username" {
  description = "Database username"
  default     = ""
  type        = string
}

variable "db_password" {
  description = "Database password"
  default     = ""
  type        = string
}

variable "db_host" {
  description = "Database host"
  default     = ""
  type        = string
}

variable "db_port" {
  description = "Database port"
  default     = 0
  type        = number
}

variable "db_name" {
  description = "Database name"
  default     = ""
  type        = string
}
