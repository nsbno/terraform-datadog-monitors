locals {
  service_name_tag = var.api_name != null ? format("service:%s", var.api_name) : null

  display_name = var.api_display_name != null ? var.api_display_name : title(var.api_name)

  # The account alias includes the name of the environment we are in as a suffix
  split_alias       = split("-", data.aws_iam_account_alias.this.account_alias)
  environment_index = length(local.split_alias) - 1
  environment       = local.split_alias[local.environment_index]
  env_tag           = "env:${local.environment}"

  latency_monitor_message = <<EOT
  @slack-${var.slack_channel_to_notify}
    {{#is_alert}}
    API: ${var.api_name}
    Threshold: ${var.latency_alert_threshold} ms
    Current value: {{value}} ms
    {{/is_alert}}

    {{#is_recovery}}
    Latency is ok again.
    {{/is_recovery}}
  EOT

  error_5xx_message = <<EOT
  @slack-${var.slack_channel_to_notify}

    {{#is_alert}}
    {{value}} 5xx errors last ${var.error_5xx_period}}
    {{/is_alert}}
  EOT
}

data "aws_iam_account_alias" "this" {}

data "aws_ssm_parameter" "team_name" {
  name = "/__platform__/team_name_handle"
}

resource "datadog_monitor" "monitor_latency" {
  name = "${local.display_name}: High Integration Latency (API Gateway)"
  type = "query alert"
  tags = compact(["team:${data.aws_ssm_parameter.team_name.value}", local.service_name_tag, local.env_tag])

  priority                 = var.priority
  evaluation_delay         = var.evaluation_delay
  on_missing_data          = var.on_missing_data
  include_tags             = false
  notification_preset_name = "hide_all"

  query               = "avg(last_${var.latency_evaluation_period}):avg:aws.apigateway.integration_latency{${local.env_tag}, apiname:${var.api_name}} >= ${var.latency_alert_threshold}"
  message             = var.workflow_to_attach != null ? var.workflow_to_attach : local.latency_monitor_message
  require_full_window = var.require_full_window

  monitor_thresholds {
    critical = var.latency_alert_threshold
  }

  lifecycle {
    precondition {
      condition     = (var.workflow_to_attach != null) != (var.slack_channel_to_notify != null)
      error_message = "Exactly one of workflow_to_attach or slack_channel_to_notify must be provided, not both."
    }
  }
}

resource "datadog_monitor" "monitor_5xx" {
  name = "${local.display_name}: 5xx Errors (API Gateway)"
  type = "query alert"
  tags = compact(["team:${data.aws_ssm_parameter.team_name.value}", local.service_name_tag, local.env_tag])

  priority                 = var.priority
  evaluation_delay         = var.evaluation_delay
  on_missing_data          = var.on_missing_data
  require_full_window      = var.require_full_window
  include_tags             = var.include_tags
  notification_preset_name = var.notification_preset_name

  query   = "sum(last_${var.latency_evaluation_period}):avg:aws.apigateway.5xxerror{${local.env_tag}, apiname:${var.api_name}}.as_count() >= ${var.error_5xx_threshold}"
  message = local.error_5xx_message

  lifecycle {
    precondition {
      condition     = (var.workflow_to_attach != null) != (var.slack_channel_to_notify != null)
      error_message = "Exactly one of workflow_to_attach or slack_channel_to_notify must be provided, not both."
    }
  }
}