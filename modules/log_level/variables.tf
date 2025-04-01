variable "service_name" {
  description = "The name of the service. A group of function names can be part of the same service"
  type        = string

  default = null
}

variable "log_level_to_monitor" {
  description = "The log level to monitor. Can be one of: DEBUG, INFO, WARN, ERROR"
  type        = string

  default = "ERROR"
}

variable "alert_threshold" {
  description = "The alert threshold. The number of logs to trigger the alert"
  type        = number

  default = 2
}

variable "period" {
  # see https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#rolling-time-windows for more information
  description = "The time window to check for the alert, in minutes"
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
  description = "Slack Channel to notify when alarm is triggered. Channel ID or channel name prefixed with '#'"
  type        = string

  default     = null
}

variable "index_to_monitor" {
  description = "Datadog index to monitor. Can be main or non-prod"

  default = "main"
}
