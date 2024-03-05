variables {
  region                        = "eu-central-1"
  topic_name                    = "sns-example-standard"
  fifo_topic                    = false
  tracing_config                = null
  content_based_deduplication   = false
  topic_policy_statements       = {}
  kms_master_key_id             = ""
  enable_data_protection_policy = false

  tags = {
    "Project" = "terraform-aws-sns-standard"
  }
}

provider "aws" {
  region = var.region
}

run "verify_sns_topic_name_null" {
  variables {
    topic_name = null
  }

  command = plan

  expect_failures = [
    var.topic_name,
  ]
}

run "verify_sns_topic_name_empty" {
  variables {
    topic_name = ""
  }

  command = plan

  expect_failures = [
    var.topic_name,
  ]
}

run "verify_tags_exist" {

  command = plan

  assert {
    condition     = contains(keys(var.tags), "Project") && var.tags["Project"] == "terraform-aws-sns-standard"
    error_message = "The 'Project' tag with the value 'terraform-aws-sns-standard' must be present."
  }

}

run "standard_configuration" {

  variables {
    fifo_topic                    = false
    content_based_deduplication   = false
    enable_data_protection_policy = false
  }

  command = plan

  assert {
    condition     = var.fifo_topic == false
    error_message = "FIFO topic configuration does not match expected value."
  }

  assert {
    condition     = !var.enable_data_protection_policy
    error_message = "Data protection policy should not be applied for a standard topic."
  }

  assert {
    condition     = var.content_based_deduplication == false
    error_message = "Content-based deduplication must be enabled for FIFO topics."
  }

}

run "fifo_configuration" {

  variables {
    fifo_topic                    = true
    content_based_deduplication   = true
    enable_data_protection_policy = false
    tracing_config                = "PassThrough"
  }

  command = plan

  assert {
    condition     = var.fifo_topic == true
    error_message = "FIFO topic configuration must be enabled."
  }

  assert {
    condition     = var.content_based_deduplication == true
    error_message = "Content-based deduplication must be enabled for FIFO topics."
  }

  assert {
    condition     = !var.enable_data_protection_policy
    error_message = "Data protection policy should be disabled for FIFO topics if enabled."
  }

  assert {
    condition     = var.tracing_config == "PassThrough"
    error_message = "TracingConfig must be set to 'PassThrough' for fifo topics"
  }

}

run "encryption_configuration" {

  variables {
    fifo_topic                  = true
    content_based_deduplication = true
    tracing_config              = "PassThrough"
  }

  command = plan
}
