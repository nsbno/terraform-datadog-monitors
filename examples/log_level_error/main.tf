# DATADOG SETUP
module "datadog_service" {
  source = "github.com/nsbno/terraform-datadog-service?ref=0.0.5"

  service_name = "infrademo"
  display_name = "Infrademo Demo App"

  github_url    = "https://github.com/nsbno/infrademo-demo-app"
  support_email = "teaminfra@vy.no"
  slack_url     = "https://nsb-utvikling.slack.com/archives/CSXU1BBA6"
}

module "task" {
  source = "github.com/nsbno/terraform-aws-ecs-service?ref=x.y.z"

  enable_datadog                  = true
  datadog_instrumentation_runtime = "node"

  [...]
}

module "datadog_monitor_too_many_error_logs" {
  source = "../../log_level"

  service_name = module.datadog_service.service_name
}


module "datadog_monitor_too_many_error_logs_with_custom_variables" {
  source = "../../log_level"

  service_name = module.datadog_service.service_name

  period           = "10m"
  alert_threshold  = 5
  priority         = 2

  workflow_to_attach = "@workflow-infrademo-notify-slack-of-monitor-event"
}
