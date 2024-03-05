locals {

  tags = {
    Name       = var.fifo_topic ? "${var.topic_name}.fifo" : var.topic_name
    Project    = var.project_name
    SourceRepo = var.source_repository
    Env        = var.environment_type
  }

}

provider "aws" {
  region                   = var.aws_region
}

data "aws_caller_identity" "current" {}

module "sns_topic" {
  source                          = "terraform-aws-modules/sns/aws"
  version                         = "6.0.0"
  name                            = var.fifo_topic ? "${var.topic_name}.fifo" : var.topic_name
  fifo_topic                      = var.fifo_topic
  content_based_deduplication     = var.fifo_topic ? var.content_based_deduplication : null
  delivery_policy                 = var.delivery_policy
  display_name                    = var.display_name
  signature_version               = var.signature_version
  tracing_config                  = var.tracing_config
  tags                            = local.tags
  archive_policy                  = var.archive_policy
  create_topic_policy             = var.create_topic_policy
  source_topic_policy_documents   = var.source_topic_policy_documents
  override_topic_policy_documents = var.override_topic_policy_documents
  enable_default_topic_policy     = var.enable_default_topic_policy
  topic_policy_statements         = var.topic_policy_statements
  subscriptions                   = var.subscriptions
  data_protection_policy          = var.data_protection_policy
  kms_master_key_id               = var.enable_encryption && length(aws_kms_key.this) > 0 ? aws_kms_key.this[0].id : var.kms_master_key_id
  application_feedback            = var.application_feedback
  firehose_feedback               = var.firehose_feedback
  http_feedback                   = var.http_feedback
  lambda_feedback                 = var.lambda_feedback
  sqs_feedback                    = var.sqs_feedback
}

resource "aws_kms_key" "this" {
  count       = var.enable_encryption ? 1 : 0
  description = "KMS key to encrypt topic"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "Enable IAM User Permissions",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : "kms:*",
        Resource : "*"
      },
      {
        Sid : "Allow management of the key",
        Effect : "Allow",
        Principal : {
          AWS : [
            data.aws_caller_identity.current.arn,
          ]
        },
        Action : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource : "*"
      }
    ]
  })
  tags = local.tags
}

resource "aws_kms_alias" "this" {
  count         = var.enable_encryption ? 1 : 0
  name          = format("alias/%s", "sns/${var.topic_name}")
  target_key_id = aws_kms_key.this[0].id
}

provider "newrelic" {
  account_id = var.new_relic_account_id
  api_key = var.api_key
  region = var.new_relic_region
}

resource "newrelic_one_dashboard_raw" "this" {
  name = "${var.topic_name} SNS - ${var.environment_type}"

  page {
    name = "SNS"

    # NumberOfMessagesPublished Widget
    widget {
      title            = "Number Of Messages Published"
      column           = 1
      row              = 2
      height           = 3
      width            = 12
      visualization_id = "viz.line"
      configuration    = <<EOT
                {
                    "facet": {
                        "showOtherSeries": false
                    },
                    "legend": {
                        "enabled": true
                    },
                    "nrqlQueries": [
                        {
                            "accountId": ${var.new_relic_account_id},
                            "query": "SELECT max(aws.sns.NumberOfMessagesPublished) FROM Metric WHERE aws.sns.TopicName = '${var.topic_name}' SINCE 1 day AGO TIMESERIES"
                        }
                    ],
                    "yAxisLeft": {
                        "zero": true
                    }
                }
                EOT
    }

    # NumberOfNotificationsDelivered Widget
    widget {
      title            = "Number Of Notifications Delivered"
      row              = 3
      column           = 1
      width            = 12
      height           = 3
      visualization_id = "viz.line"
      configuration    = <<EOT
                {
                    "facet": {
                        "showOtherSeries": false
                    },
                    "legend": {
                        "enabled": true
                    },
                    "nrqlQueries": [
                        {
                            "accountId": ${var.new_relic_account_id},
                            "query": "SELECT max(aws.sns.NumberOfNotificationsDelivered) FROM Metric WHERE aws.sns.TopicName = '${var.topic_name}' SINCE 1 day AGO TIMESERIES"
                        }
                    ],
                    "yAxisLeft": {
                        "zero": true
                    }
                }
                EOT
    }

    # NumberOfNotificationsFailed Widget
    widget {
      title            = "Number Of Notifications Failed"
      row              = 4
      column           = 1
      width            = 12
      height           = 3
      visualization_id = "viz.line"
      configuration    = <<EOT
                {
                    "facet": {
                        "showOtherSeries": false
                    },
                    "legend": {
                        "enabled": true
                    },
                    "nrqlQueries": [
                        {
                            "accountId": ${var.new_relic_account_id},
                            "query": "SELECT max(aws.sns.NumberOfNotificationsFailed) FROM Metric WHERE aws.sns.TopicName = '${var.topic_name}' SINCE 1 day AGO TIMESERIES"
                        }
                    ],
                    "yAxisLeft": {
                        "zero": true
                    }
                }
                EOT
    }

    # PublishSize Widget
    widget {
      title            = "Publish Size"
      row              = 5
      column           = 1
      width            = 12
      height           = 3
      visualization_id = "viz.line"
      configuration    = <<EOT
                {
                    "facet": {
                        "showOtherSeries": false
                    },
                    "legend": {
                        "enabled": true
                    },
                    "nrqlQueries": [
                        {
                            "accountId": ${var.new_relic_account_id},
                            "query": "SELECT max(aws.sns.PublishSize), min(aws.sns.PublishSize), average(aws.sns.PublishSize), count(aws.sns.PublishSize) FROM Metric WHERE aws.sns.TopicName = '${var.topic_name}' SINCE 1 day AGO TIMESERIES"
                        }
                    ],
                    "yAxisLeft": {
                        "zero": true
                    }
                }
                EOT
    }

    # SubscriptionsPending Widget
    widget {
      title            = "Subscriptions Pending"
      row              = 6
      column           = 1
      width            = 12
      height           = 3
      visualization_id = "viz.line"
      configuration    = <<EOT
                {
                    "facet": {
                        "showOtherSeries": false
                    },
                    "legend": {
                        "enabled": true
                    },
                    "nrqlQueries": [
                        {
                            "accountId": ${var.new_relic_account_id},
                            "query": "SELECT max(aws.sns.SubscriptionsPending) FROM Metric WHERE aws.sns.TopicName = '${var.topic_name}' SINCE 1 day AGO TIMESERIES"
                        }
                    ],
                    "yAxisLeft": {
                        "zero": true
                    }
                }
                EOT
    }

    # SubscriptionsConfirmed Widget
    widget {
      title            = "Subscriptions Confirmed"
      row              = 7
      column           = 1
      width            = 12
      height           = 3
      visualization_id = "viz.line"
      configuration    = <<EOT
                {
                    "facet": {
                        "showOtherSeries": false
                    },
                    "legend": {
                        "enabled": true
                    },
                    "nrqlQueries": [
                        {
                            "accountId": ${var.new_relic_account_id},
                            "query": "SELECT max(aws.sns.SubscriptionsConfirmed) FROM Metric WHERE aws.sns.TopicName = '${var.topic_name}' SINCE 1 day AGO TIMESERIES"
                        }
                    ],
                    "yAxisLeft": {
                        "zero": true
                    }
                }
                EOT
    }

    # SubscriptionsDeleted Widget
    widget {
      title            = "Subscriptions Deleted"
      row              = 8
      column           = 1
      width            = 12
      height           = 3
      visualization_id = "viz.line"
      configuration    = <<EOT
                {
                    "facet": {
                        "showOtherSeries": false
                    },
                    "legend": {
                        "enabled": true
                    },
                    "nrqlQueries": [
                        {
                            "accountId": ${var.new_relic_account_id},
                            "query": "SELECT max(aws.sns.SubscriptionsDeleted) FROM Metric WHERE aws.sns.TopicName = '${var.topic_name}' SINCE 1 day AGO TIMESERIES"
                        }
                    ],
                    "yAxisLeft": {
                        "zero": true
                    }
                }
                EOT
    }
  }
}
