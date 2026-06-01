terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "aws_s3_bucket" "content" {
  bucket = "${local.name_prefix}-content"
}

resource "aws_s3_bucket_public_access_block" "content" {
  bucket                  = aws_s3_bucket.content.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "content" {
  name                              = "${local.name_prefix}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_dynamodb_table" "models" {
  name         = "${local.name_prefix}-models"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "modelId"

  attribute {
    name = "modelId"
    type = "S"
  }
}

resource "aws_lambda_function" "api" {
  function_name = "${local.name_prefix}-api"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename         = "${path.module}/../backend/lambda/dist.zip"
  source_code_hash = fileexists("${path.module}/../backend/lambda/dist.zip") ? filebase64sha256("${path.module}/../backend/lambda/dist.zip") : null

  lifecycle {
    ignore_changes = [source_code_hash]
  }

  environment {
    variables = {
      MODELS_TABLE = aws_dynamodb_table.models.name
      CONTENT_BUCKET = aws_s3_bucket.content.bucket
    }
  }
}

resource "aws_iam_role" "lambda" {
  name = "${local.name_prefix}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_api" "http" {
  name          = "${local.name_prefix}-http"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "models" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /models"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_cognito_user_pool" "main" {
  name = "${local.name_prefix}-users"
}

resource "aws_cognito_user_pool_client" "app" {
  name         = "${local.name_prefix}-app"
  user_pool_id = aws_cognito_user_pool.main.id
  generate_secret = false
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.http.api_endpoint
}

output "content_bucket" {
  value = aws_s3_bucket.content.bucket
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.main.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.app.id
}
