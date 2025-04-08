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

module "datadog_ecs_alarms" {
  source = "github.com/nsbno/terraform-datadog-monitors//modules/ecs_memory_and_cpu?ref=x.y.z"

  service_name         = module.datadog_service.service_name
  service_display_name = "Infrademo Demo App"

  slack_channel_to_notify = "team-infra-alerts"
}

module "datadog_ecs_alarms_custom_threshold" {
  source = "github.com/nsbno/terraform-datadog-monitors//modules/ecs_memory_and_cpu?ref=x.y.z"

  service_name         = module.datadog_service.service_name
  service_display_name = "Infrademo Demo App"

  cpu_alert_threshold    = 70
  memory_alert_threshold = 85

  slack_channel_to_notify = "team-infra-alerts"
}