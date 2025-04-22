variable "service_name" {
  description = "The name of the service. A group of function names can be part of the same service"
  type        = string

  default = null
}

variable "api_name" {
  description = "The name of the API in API Gateway"
  type        = string
}

variable "service_display_name" {
  description = "The display name of the service for the monitor"
  type        = string

  default = null
}

variable "latency_alert_threshold" {
  description = "Milliseconds of latency threshold to trigger the alarm"
  type        = number

  default = 1000
}

variable "latency_evaluation_period" {
  # see https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#rolling-time-windows for more information
  description = "The time window to check for the alert, in minutes"
  type        = string

  default = "5m"
}

variable "error_5xx_threshold" {
  description = "The amount of 5XX errors before an alarm is triggered"
  type        = number

  default = 5
}

variable "error_5xx_period" {
  description = "Period to evaluate 5xx errors for."
  type        = string

  default = "5m"
}

variable "priority" {
  description = "The priority of the monitor. Can be one of: 1, 2, 3, 4"
  type        = number

  default = 3
}

variable "workflow_to_attach" {
  # https://app.datadoghq.eu/workflow
  description = "The workflow to attach to the monitor. Find your workflow handle in the Datadog page for workflows"
  type        = string

  default = null
}

variable "slack_channel_to_notify" {
  description = "Slack channel name"
  type        = string

  default = null
}