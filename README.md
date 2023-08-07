# Assignment: Build and Deploy an API as a Container using Python, CI Pipeline on Github, and Deployment via Terraform Pipeline to AWS Lambda behind an API Gateway with CloudWatch Logs, and Test using Postman.

## Objective
The objective of this assignment is to create a containerized API using Python, integrate a CI pipeline on Github, deploy the container to AWS Lambda via a Terraform pipeline, ensure the Lambda function is secure behind an API Gateway, and send access logs to CloudWatch. Additionally, the API will be tested using Postman.

## Requirements

- Design an API in Python:
  - The API should be a simple RESTful API with endpoints to create, read, update, and delete resources.
  - The API should use the Flask framework.

- Containerize the API:
  - The API should be containerized using Docker.
  - The Docker container should be able to run the Flask application.

- Create a CI Pipeline on Github:
  - The CI pipeline should be triggered automatically when changes are pushed to the Github repository.
  - The CI pipeline should build the Docker container and run tests to ensure the container is functioning correctly.

- Deploy the API to AWS Lambda:
  - Use Terraform to create a pipeline that deploys the Docker container to AWS Lambda.
  - Configure the Terraform pipeline to deploy to a Lambda function.

- Secure the API with API Gateway:
  - Ensure that the Lambda function is secured behind an API Gateway using AWS IAM policies.
  - Configure the API Gateway to accept incoming requests and route them to the Lambda function.

- Send logs to CloudWatch:
  - Configure the Lambda function to send access logs to CloudWatch.
  - Ensure that the logs contain relevant information such as the API endpoint, request method, status code, and response time.

- Test the API using Postman:
  - Use Postman to test the API and ensure that it is functioning correctly.
