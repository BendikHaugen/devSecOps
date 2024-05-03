provider "aws" {
  region = "eu-north-1"
}

resource "aws_lambda_function" "guardduty_handler" {
  filename         = "guardduty_handler.zip"
  function_name    = "guardduty_handler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "python3.8"
}

resource "aws_cloudwatch_event_rule" "guardduty_event" {
  name        = "GuardDutyEvent"
  description = "Capture GuardDuty Findings for Lambda Processing"
  event_pattern = jsonencode({
    source     = ["aws.guardduty"],
    "detail-type" = ["GuardDuty Finding"],
    detail = {
      severity = [{
        numeric = [">=", 4]
      }]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.guardduty_event.name
  arn  = aws_lambda_function.guardduty_handler.arn
}

resource "aws_cloudwatch_metric_alarm" "guardduty_alarm" {
  alarm_name                = "high_severity_guardduty"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "HighSeverityFindings"
  namespace                 = "AWS/GuardDuty"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  alarm_actions             = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  name = "guardduty-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "phone"
  endpoint  = VAR.PHONE_NUMBER
}
