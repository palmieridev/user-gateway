# Lambda Module - Main Configuration

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-profile-handler"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# Package Lambda function
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/function/profile_handler.py"
  output_path = "${path.module}/function/profile_handler.zip"
}

# Lambda Function
resource "aws_lambda_function" "profile_handler" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "${var.project_name}-${var.environment}-profile-handler"
  role            = var.lambda_role_arn
  handler         = "profile_handler.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = merge(
      {
        ENVIRONMENT  = var.environment
        PROJECT_NAME = var.project_name
        LOG_LEVEL    = "INFO"
      },
      var.environment_variables
    )
  }

  tracing_config {
    mode = "Active"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-profile-handler"
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda
  ]
}

# Lambda Function Alias
resource "aws_lambda_alias" "profile_handler" {
  name             = var.environment
  description      = "Alias for ${var.environment} environment"
  function_name    = aws_lambda_function.profile_handler.function_name
  function_version = "$LATEST"
}
