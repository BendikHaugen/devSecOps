provider "aws" {
  region = "eu-north-1"
}

resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "guardduty"
  description = "Trigger for GuardDuty findings with medium to high severity"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    "detail-type" = ["GuardDuty Finding"]
    detail = {
      severity = [4, 4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5, 5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6, 6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 7, 7.0, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 8, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9]
    }
  })
}

resource "aws_sns_topic" "guardduty_alerts" {
  name = "guardduty"
}

resource "aws_cloudwatch_event_target" "guardduty_alert" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "sendToSNS"
  arn       = aws_sns_topic.guardduty_alerts.arn

  input_transformer {
    input_paths = {
      severity            = "$.detail.severity",
      Account_ID          = "$.detail.accountId",
      Finding_ID          = "$.detail.id",
      Finding_Type        = "$.detail.type",
      region              = "$.region",
      Finding_description = "$.detail.description"
    }

    input_template = "\"AWS <Account_ID> has a severity <severity> GuardDuty finding type <Finding_Type> in the <region> region.\"\n\"Finding Description:\"\n\"<Finding_description>. \"\n\"For more details open the GuardDuty console at https://console.aws.amazon.com/guardduty/home?region=<region>#/findings?search=id%3D<Finding_ID>\""
  }
}

resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.guardduty_alerts.arn
  protocol  = "sms"
  endpoint  = var.PHONE_NUMBER
}
