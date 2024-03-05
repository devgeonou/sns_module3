output "default_sns_topic_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = module.sns_topic.topic_arn
}

output "default_sns_topic_id" {
  description = "The ARN of the SNS topic"
  value       = module.sns_topic.topic_id
}

output "default_sns_topic_name" {
  description = "The name of the topic"
  value       = module.sns_topic.topic_name
}

output "default_sns_topic_owner" {
  description = "The AWS Account ID of the SNS topic owner"
  value       = module.sns_topic.topic_owner
}

output "default_sns_topic_beginning_archive_time" {
  description = "The oldest timestamp at which a FIFO topic subscriber can start a replay"
  value       = module.sns_topic.topic_beginning_archive_time
}

output "default_sns_subscriptions" {
  description = "Map of subscriptions created and their attributes"
  value       = module.sns_topic.subscriptions
}

output "dashboard_id" {
  value = newrelic_one_dashboard_raw.this.id
  description = "The ID of the New Relic One dashboard"
}

output "dashboard_name" {
  value = newrelic_one_dashboard_raw.this.name
  description = "The name of the New Relic One dashboard"
}