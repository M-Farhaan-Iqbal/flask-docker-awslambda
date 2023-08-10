terraform {
  # Run init/plan/apply with "backend" commented-out (ueses local backend) to provision Resources (Bucket, Table)
  # Then uncomment "backend" and run init, apply after Resources have been created (uses AWS)
  backend "s3" {
    bucket         = "cc-tf-state-backend-ci-cd"
    key            = "tf-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


module "tf-state" {
  source      = "./modules/tf-state"
  bucket_name = "cc-tf-state-backend-ci-cd"
}



module "ecr" {
  source = "./modules/ecr"
}
output "ecr_repo_url" {
  value = module.ecr.ecr_repo_url
}

module "lambda_api_cloudwatch" {
  source           = "./modules/lambdaApiCloudwatch"
  docker_image_tag = var.docker_image_tag
  ecr_repo_url     = module.ecr.ecr_repo_url
  lambda_name      = var.lambda_name

  db_username = var.db_username
  db_password = var.db_password
  db_host     = var.db_host
  db_port     = var.db_port
  db_name     = var.db_name
}
