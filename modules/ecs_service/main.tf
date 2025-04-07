locals {
  service_tag = var.service_name != null ? format("service:%s", var.service_name) : null
  service_name_tag = var.service_name != null ? format("servicename:%s", var.service_name) : null

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

resource "datadog_monitor" "high_memory_usage" {
  name = "${var.service_display_name}: High Memory Usage"
  type = "query alert"
  tags = compact([local.account_name_tag, local.service_tag, local.env_tag, local.team_tag])

  evaluation_delay         = 900 # Datadog recommends at least 900 second delay for AWS metrics
  include_tags             = false
  notification_preset_name = "hide_all"
  require_full_window      = true

  priority = var.memory_priority

  query   = "avg(last_${var.memory_period}):avg:aws.ecs.service.memory_utilization{${local.account_name_tag},${local.service_name_tag}} >= ${var.memory_alert_threshold}"
  message = var.workflow_to_attach != null ? var.workflow_to_attach : <<EOT
@slack-${var.slack_channel_to_notify}

{{#is_alert}}
  ${var.service_display_name} has crossed the memory usage threshold of {{threshold}}%. Average last 5 minutes was {{value}}%
{{/is_alert}}

{{#is_recovery}}
  Memory usage is ok again.
{{/is_recovery}}
EOT

  lifecycle {
    precondition {
      condition     = (var.workflow_to_attach != null) != (var.slack_channel_to_notify != null)
      error_message = "Exactly one of workflow_to_attach or slack_channel_to_notify must be provided, not both."
    }
  }
}

resource "datadog_monitor" "high_cpu_usage" {
  name = "${var.service_display_name}: High CPU Usage"
  type = "query alert"
  tags = compact([local.account_name_tag, local.service_tag, local.env_tag, local.team_tag])

  evaluation_delay         = 900 # Datadog recommends at least 900 second delay for AWS metrics
  include_tags             = false
  notification_preset_name = "hide_all"
  require_full_window      = true

  priority = var.cpu_priority

  query   = "avg(last_${var.cpu_period}):avg:aws.ecs.service.cpuutilization{${local.account_name_tag},${local.service_name_tag}} >= ${var.cpu_alert_threshold}"
  message = var.workflow_to_attach != null ? var.workflow_to_attach : <<EOT
@slack-${var.slack_channel_to_notify}

{{#is_alert}}
  ${var.service_display_name} has crossed the CPU usage threshold of {{threshold}}%. Average last 5 minutes was {{value}}%
{{/is_alert}}

{{#is_recovery}}
  CPU usage is ok again.
{{/is_recovery}}
EOT

  lifecycle {
    precondition {
      condition     = (var.workflow_to_attach != null) != (var.slack_channel_to_notify != null)
      error_message = "Exactly one of workflow_to_attach or slack_channel_to_notify must be provided, not both."
    }
  }
}