terraform {
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  default = "defaultLog"
  type        = string
}