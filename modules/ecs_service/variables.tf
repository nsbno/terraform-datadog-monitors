variable "service_name" {
  description = "The name of the service. A group of function names can be part of the same service"
  type        = string

  default = null
}

variable "service_display_name" {
  description = "The display name of the service"
  type        = string

  default = null
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

  default     = null
}

/*
 * == Alarm Configuration
 */
variable "memory_alert_threshold" {
  description = "The memory alert threshold. The percentage of memory to trigger the alert"
  type        = number

  default = 80
}

variable "memory_period" {
  # see https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#rolling-time-windows for more information
  description = "The time window to check for the memory alert"
  type        = string

  default = "5m"
}

variable "memory_priority" {
  description = "The priority of the memory monitor. Can be one of: 1, 2, 3, 4"
  type        = number

  default = 2
}

variable "cpu_alert_threshold" {
  description = "The CPU alert threshold. The percentage of CPU to trigger the alert"
  type        = number

  default = 80
}

variable "cpu_period" {
  # see https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#rolling-time-windows for more information
  description = "The time window to check for the CPU alert"
  type        = string

  default = "5m"
}

variable "cpu_priority" {
  description = "The priority of the CPU monitor. Can be one of: 1, 2, 3, 4"
  type        = number

  default = 2
}

