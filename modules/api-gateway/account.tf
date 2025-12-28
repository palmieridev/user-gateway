# API Gateway Account Settings and CloudWatch Logging Role

# IAM Role for API Gateway to push logs to CloudWatch
resource "aws_iam_role" "apigw_cloudwatch_role" {
  name = "${var.project_name}-${var.environment}-apigw-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-apigw-cloudwatch-role"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Attach the AWS managed policy that allows API Gateway to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "apigw_cloudwatch_role_attach" {
  role       = aws_iam_role.apigw_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Configure API Gateway account-level settings to use the CloudWatch logging role
resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch_role.arn

  depends_on = [
    aws_iam_role_policy_attachment.apigw_cloudwatch_role_attach
  ]
}
