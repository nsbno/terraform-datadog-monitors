variable "service_name" {
  description = "The name of the service. A group of function names can be part of the same service"
  type        = string
}

variable "queue_name" {
  description = "The name of the queue to monitor"
  type        = string
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

  default = null
}

/*
 * == Alarm Configuration
 */
variable "threshold" {
  description = "Anything higher than or equal to this will trigger an alert"
  type        = number

  default = 1
}

variable "period" {
  # see https://docs.datadoghq.com/monitors/configuration/?tab=thresholdalert#rolling-time-windows for more information
  description = "The time window to check for visible messages in the queue"
  type        = string

  default = "1h"
}

variable "priority" {
  description = "The priority of the monitor. Can be one of: 1, 2, 3, 4"
  type        = number

  default = 2
}

variable "evaluation_delay" {
  default     = 900
  type        = number
  description = "Delay before evaluating the monitor. Datadog suggests 900 seconds for AWS metrics"
}

variable "require_full_window" {
  default     = false
  type        = bool
  description = "A boolean indicating whether this monitor needs a full window of data before it’s evaluated. Datadog recommends you set this to False for sparse metrics, otherwise some evaluations are skipped. Default: False"
}

variable "on_missing_data" {
  default     = "default"
  type        = string
  description = "How to treat missing data"
}

variable "include_tags" {
  default     = false
  description = "Whether notifications from this monitor automatically insert its triggering tags into the title"
}

variable "notification_preset_name" {
  default     = "hide_all"
  type        = string
  description = "The notification preset to use for this monitor. See https://docs.datadoghq.com/monitors/notifications/?tab=notificationpresets#notification-presets"
}