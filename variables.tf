variable "aws_region" {
  description = "The aws region for the topic."
  type        = string
  default     = "eu-central-1"

}

variable "topic_name" {
  description = "The name of the SNS topic."
  type        = string
  default     = "default-name"

  validation {
    condition     = var.topic_name != null && var.topic_name != ""
    error_message = "The SNS topic name must not be null or empty."
  }
}

variable "environment_type" {
  description = "Provides the type of the environment like DEV/UAT/nonPRD/PRD"
  type        = string
  default     = "nonPRD"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "Default Project"
}

variable "source_repository" {
  description = "Provides the repository URL on Sportradar's GitLab"
  type        = string
  default     = "https://gitlab.sportradar.ag/terraform/terraform-aws-sns"
}

variable "fifo_topic" {
  description = "Determines if the SNS topic is a FIFO topic."
  type        = bool
  default     = false

  validation {
    condition     = var.fifo_topic == true || var.fifo_topic == false
    error_message = "The fifo_topic must be either true or false."
  }
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO topics."
  type        = bool
  default     = false

  validation {
    condition     = var.content_based_deduplication == true || var.content_based_deduplication == false
    error_message = "The content_based_deduplication must be either true or false."
  }
}

variable "delivery_policy" {
  description = "The SNS delivery policy."
  type        = string
  default     = null
}

variable "new_relic_account_id" {
  description = "New relic account id."
  type        = number
}

variable "api_key" {
  description = "The new relic api key"
  type        = string
}

variable "new_relic_region" {
  description = "The new relic api key"
  type        = string
  default     = "US"
}

variable "display_name" {
  description = "The display name for the SNS topic."
  type        = string
  default     = null
}

variable "signature_version" {
  description = "The signature version used for SNS messages, applicable only for non-FIFO topics."
  type        = string
  default     = null
}

variable "tracing_config" {
  description = "The tracing configuration for the SNS topic."
  type        = string
  default     = null

  validation {
    condition     = var.tracing_config == "PassThrough" || var.tracing_config == "Active" || var.tracing_config == null
    error_message = "The tracing_config must be either 'PassThrough', 'Active', or null."
  }
}

variable "archive_policy" {
  description = "The message archive policy for FIFO topics."
  type        = string
  default     = null
}

variable "enable_encryption" {

  description = "Determines if enable_encryption should be enabled for the SNS topic."
  type        = bool
  default     = false

  validation {
    condition     = var.enable_encryption == true || var.enable_encryption == false
    error_message = "The enable_encryption must be either true or false."
  }
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  type        = string
  default     = null
}

variable "source_topic_policy_documents" {
  description = "A list of source policy documents for the SNS topic."
  type        = list(string)
  default     = []
}

variable "override_topic_policy_documents" {
  description = "A list of override policy documents for the SNS topic."
  type        = list(string)
  default     = []
}

variable "enable_default_topic_policy" {
  description = "Determines if the default topic policy should be enabled for the SNS topic."
  type        = bool
  default     = true

  validation {
    condition     = var.enable_default_topic_policy == true || var.enable_default_topic_policy == false
    error_message = "The enable_default_topic_policy must be either true or false."
  }
}

variable "create_topic_policy" {
  description = "Determines if topic policy should be created."
  type        = bool
  default     = true

  validation {
    condition     = var.create_topic_policy == true || var.create_topic_policy == false
    error_message = "The create_topic_policy must be either true or false."
  }
}

variable "topic_policy_statements" {
  description = "A list of additional topic policy statements for the SNS topic."
  type        = any
  default     = []
}

variable "subscriptions" {
  description = "A map of subscription definitions for the SNS topic."
  type        = map(any)
  default     = {}
}

variable "data_protection_policy" {
  description = "The data protection policy for the SNS topic."
  type        = string
  default     = null
}

variable "application_feedback" {
  description = "Configuration for application feedback roles."
  type = object({
    failure_role_arn    = string
    success_role_arn    = string
    success_sample_rate = number
  })
  default = null
}

variable "firehose_feedback" {
  description = "Configuration for Firehose feedback roles."
  type = object({
    failure_role_arn    = string
    success_role_arn    = string
    success_sample_rate = number
  })
  default = null
}

variable "http_feedback" {
  description = "Configuration for HTTP feedback roles."
  type = object({
    failure_role_arn    = string
    success_role_arn    = string
    success_sample_rate = number
  })
  default = null
}

variable "lambda_feedback" {
  description = "Configuration for Lambda feedback roles."
  type = object({
    failure_role_arn    = string
    success_role_arn    = string
    success_sample_rate = number
  })
  default = null
}

variable "sqs_feedback" {
  description = "Configuration for SQS feedback roles."
  type = object({
    failure_role_arn    = string
    success_role_arn    = string
    success_sample_rate = number
  })
  default = null
}
