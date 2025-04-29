locals {
  service_tag      = var.service_name != null ? format("service:%s", var.service_name) : null

  display_name = var.service_display_name != null ? var.service_display_name : title(var.service_name)

  # The account alias includes the name of the environment we are in as a suffix
  split_alias       = split("-", data.aws_iam_account_alias.this.account_alias)
  environment_index = length(local.split_alias) - 1
  environment       = local.split_alias[local.environment_index]
  env_tag           = "env:${local.environment}"
  account_name_tag  = "account-name:${data.aws_iam_account_alias.this.account_alias}"
  team_tag          = "team:${data.aws_ssm_parameter.team_name.value}"
}

data "aws_iam_account_alias" "this" {}

data "aws_ssm_parameter" "team_name" {
  name = "/__platform__/team_name_handle"
}

resource "datadog_monitor" "messages_in_dql" {
  name = "${local.display_name}: ${var.queue_name}: Messages in DLQ"
  type = "query alert"
  tags = compact([local.account_name_tag, local.service_tag, local.env_tag, local.team_tag])

  priority         = var.priority
  evaluation_delay = var.evaluation_delay
  on_missing_data  = var.on_missing_data

  include_tags             = var.include_tags
  notification_preset_name = var.notification_preset_name
  require_full_window      = var.require_full_window

  query   = "avg(last_${var.period}):sum:aws.sqs.approximate_number_of_messages_visible{queuename:${lower(var.queue_name)}} >= ${var.threshold}"
  message = var.workflow_to_attach != null ? var.workflow_to_attach : <<-EOT
  @slack-${var.slack_channel_to_notify}

  {{#is_alert}}
  One or more events could not be processed and was put in the DLQ.
  In the last ${var.period} there have been {{value}} messages visible on average.
  {{/is_alert}}
  EOT

  lifecycle {
    precondition {
      condition     = (var.workflow_to_attach != null) != (var.slack_channel_to_notify != null)
      error_message = "Exactly one of workflow_to_attach or slack_channel_to_notify must be provided, not both."
    }
  }
}