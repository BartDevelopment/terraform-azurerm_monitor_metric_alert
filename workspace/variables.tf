#https://www.terraform.io/docs/providers/azurerm/r/log_analytics_workspace.html

#workspace

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "workspace_sku" {
  type    = string
  default = "PerGB2018"
}

variable "retention_in_days" {
  type = number
}

#tags

variable "tags" {
  type    = map
  default = null
}


###DIAGNOSTIC SETTINGS

#REQUIRED

variable "log_categories" {
  type        = list(string)
  default     = []
  description = "List of log categories."
}

variable "metric_categories" {
  type        = list(string)
  default     = []
  description = "List of metric categories."
}

variable "ds_map" {
  type = map
  default = {
    storage_account_id         = null
    log_analytics_workspace_id = null
  }
}

#OPTIONAL

variable "enabled" {
  type        = bool
  default     = true
  description = "Either `true` to enable diagnostic settings or `false` to disable it."
}

variable "log_analytics_destination_type" {
  type    = string
  default = null
}

variable "retention_days" {
  type        = number
  default     = 0
  description = "The number of days to keep diagnostic logs."
}


#ALERTS

#REQUIRED

variable "dynamic_criteria" {
  type = map(object({
      name                     = string
      metric_namespace         = string
      metric_name              = string
      aggregation              = string
      operator                 = string
      alert_sensitivity        = string
      evaluation_total_count   = number
      evaluation_failure_count = number
      description              = string
      severity                 = number
      enabled                  = bool
  }))
  default = {
    "CPUHIGH" = {
      name                     = "CPUHIGH"
      metric_namespace         = "Microsoft.OperationalInsights/workspaces"
      metric_name              = "Average_% Processor Time"
      aggregation              = "Average"
      operator                 = "GreaterThan"
      alert_sensitivity        = "Medium"
      evaluation_total_count   = 6
      evaluation_failure_count = 6
      description              = "Virtual Machine: CPU Utilization is higher than usually"
      severity                 = 3
      enabled                  = true
    },
    "MEMHIGH" = {
      name                     = "MEMHIGH"
      metric_namespace         = "Microsoft.OperationalInsights/workspaces"
      metric_name              = "Average_% Used Memory"
      aggregation              = "Average"
      operator                 = "GreaterThan"
      alert_sensitivity        = "Medium"
      evaluation_total_count   = 6
      evaluation_failure_count = 6
      description              = "Virtual Machine: Memory Consumption is higher than usually"
      severity                 = 3
      enabled                  = true
    },
    "DISKSPACELOW" = {
      name                     = "DISKSPACELOW"
      metric_namespace         = "Microsoft.OperationalInsights/workspaces"
      metric_name              = "Average_% Free Space"
      aggregation              = "Average"
      operator                 = "LessThan"
      alert_sensitivity        = "Medium"
      evaluation_total_count   = 6
      evaluation_failure_count = 6
      description              = "Virtual Machine: Free disk space is lower than usually"
      severity                 = 2
      enabled                  = true
    },
  }
}


variable "action_group" {
  type    = string
  default = null
}


#OPTIONAL

variable "auto_mitigate" {
  type    = bool
  default = true
}

variable "query_frequency" {
  type    = number
  default = 5
}

variable "frequency" {
  type    = string
  default = "PT1M"
}

variable "window_size" {
  type    = string
  default = "PT5M"
}

variable "time_window" {
  type    = number
  default = 5
}

variable "description" {
  type    = string
  default = null
}

variable "severity" {
  type    = number
  default = 1
}

variable "throttling" {
  type    = number
  default = null
}

variable "email_subject" {
  type    = string
  default = null
}

variable "custom_webhook_payload" {
  type    = string
  default = null
}
