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
  target_group_tag  = "targetgroup:${var.target_group_arn_suffix}"
  load_balancer_tag = "loadbalancer:${var.load_balancer_arn_suffix}"
}

data "aws_iam_account_alias" "this" {}

data "aws_ssm_parameter" "team_name" {
  name = "/__platform__/team_name_handle"
}

resource "datadog_monitor" "unhealthy_host_count" {
  name = "${local.display_name}: Unhealthy host count"
  type = "query alert"
  tags = compact([local.account_name_tag, local.service_tag, local.env_tag, local.team_tag])

  priority         = var.priority
  evaluation_delay = var.evaluation_delay
  on_missing_data  = var.on_missing_data

  include_tags             = var.include_tags
  notification_preset_name = var.notification_preset_name
  require_full_window      = var.require_full_window

  query   = "min(last_${var.period}):min:aws.applicationelb.healthy_host_count{${local.target_group_tag}, ${local.load_balancer_tag}} < ${var.threshold}"
  message = var.workflow_to_attach != null ? var.workflow_to_attach : <<EOT
  @slack-${var.slack_channel_to_notify}

  {{#is_alert}}
    ${local.display_name}: Unhealthy host count of {{value}}. 
  {{/is_alert}}

  {{#is_recovery}}
    ${local.display_name} is back to a healthy host count of {{value}}.
  {{/is_recovery}}
  EOT

  lifecycle {
    precondition {
      condition     = (var.workflow_to_attach != null) != (var.slack_channel_to_notify != null)
      error_message = "Exactly one of workflow_to_attach or slack_channel_to_notify must be provided, not both."
    }
  }
}