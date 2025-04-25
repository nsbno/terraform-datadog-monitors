locals {
  service_tag      = var.aurora_db_cluster_name != null ? format("service:%s", var.aurora_db_cluster_name) : null

  display_name = var.service_display_name != null ? var.service_display_name : title(var.aurora_db_cluster_name)

  # The account alias includes the name of the environment we are in as a suffix
  split_alias       = split("-", data.aws_iam_account_alias.this.account_alias)
  environment_index = length(local.split_alias) - 1
  environment       = local.split_alias[local.environment_index]
  env_tag           = "env:${local.environment}"
  account_name_tag  = "account-name:${data.aws_iam_account_alias.this.account_alias}"
  team_tag          = "team:${data.aws_ssm_parameter.team_name.value}"
  cluster_tag       = "cluseridentifier:${var.aurora_db_cluster_name}"
}

data "aws_iam_account_alias" "this" {}

data "aws_ssm_parameter" "team_name" {
  name = "/__platform__/team_name_handle"
}

resource "datadog_monitor" "rds_overspent_cpu_credits" {
  name = "${local.display_name}: RDS is charging for surplus CPU credits"
  type = "query alert"
  tags = compact([local.account_name_tag, local.service_tag, local.env_tag, local.team_tag])

  priority         = var.priority
  evaluation_delay = var.evaluation_delay
  on_missing_data  = var.on_missing_data

  include_tags             = var.include_tags
  notification_preset_name = var.notification_preset_name
  require_full_window      = var.require_full_window

  query   = "sum(last_${var.period}):avg:aws.rds.cpusurplus_credits_charged{${local.cluster_tag}, ${local.account_name_tag}} > ${var.threshold}"
  message = var.workflow_to_attach != null ? var.workflow_to_attach : <<EOT
  @slack-${var.slack_channel_to_notify}

  {{#is_alert}}
    ${local.display_name}: RDS Cluster is experiencing high CPU load and you are being charged extra.
  {{/is_alert}}

  {{#is_recovery}}
    ${local.display_name}: RDS Cluster CPU load has decreased sufficiently.
  {{/is_recovery}}
  EOT

  lifecycle {
    precondition {
      condition     = (var.workflow_to_attach != null) != (var.slack_channel_to_notify != null)
      error_message = "Exactly one of workflow_to_attach or slack_channel_to_notify must be provided, not both."
    }
  }
}
