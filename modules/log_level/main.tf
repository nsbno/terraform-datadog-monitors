locals {
  service_name_tag = var.service_name != null ? format("service:%s", var.service_name) : null

  display_name = var.service_display_name != null ? var.service_display_name : title(var.service_name)

  # The account alias includes the name of the environment we are in as a suffix
  split_alias       = split("-", data.aws_iam_account_alias.this.account_alias)
  environment_index = length(local.split_alias) - 1
  environment       = local.split_alias[local.environment_index]
  env_tag           = "env:${local.environment}"

  log_query = "${local.env_tag} ${local.service_name_tag} status:${lower(var.log_level_to_monitor)}"
}

data "aws_iam_account_alias" "this" {}

data "aws_ssm_parameter" "team_name" {
  name = "/__platform__/team_name_handle"
}

resource "datadog_monitor" "too_many_logs_of_log_level" {
  name = "${local.display_name}: Too many logs of log level: ${var.log_level_to_monitor}"
  type = "log alert"
  tags = compact(["team:${data.aws_ssm_parameter.team_name.value}", local.service_name_tag, local.env_tag])

  priority = var.priority

  query   = "logs(\"${local.log_query}\").index(\"${var.index_to_monitor}\").rollup(\"count\").last(\"${var.period}\") > ${var.alert_threshold}"
  message = var.workflow_to_attach != null ? var.workflow_to_attach : "@slack-${var.slack_channel_to_notify}"

  enable_logs_sample       = true
  require_full_window      = false
  notification_preset_name = var.notification_preset_name

  lifecycle {
    precondition {
      condition     = (var.workflow_to_attach != null) != (var.slack_channel_to_notify != null)
      error_message = "Exactly one of workflow_to_attach or slack_channel_to_notify must be provided, not both."
    }
  }
}
