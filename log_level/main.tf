locals {
  service_name_tag = var.service_name != null ? format("service:%s", var.service_name) : null

  # The account alias includes the name of the environment we are in as a suffix
  split_alias       = split("-", data.aws_iam_account_alias.this.account_alias)
  environment_index = length(local.split_alias) - 1
  environment       = local.split_alias[local.environment_index]

  log_query = "env:${local.environment} ${local.service_name_tag} @level:${var.log_level_to_monitor}"
}

data "aws_iam_account_alias" "this" {}

data "aws_ssm_parameter" "team_name" {
  name = "/__platform__/team_name_handle"
}

resource "datadog_monitor" "too_many_logs_of_log_level" {
  name = "${var.service_name}: Too many logs of log level: ${var.log_level_to_monitor}"
  type = "log alert"
  tags = compact(["team:${data.aws_ssm_parameter.team_name.value}", local.service_name_tag])

  priority = var.priority

  query = "(${logs(local.log_query).index("main").rollup("count").last(var.period) > var.alert_threshold})"
  message = var.workflow_to_attach

  enable_logs_sample = true
  require_full_window = false
}