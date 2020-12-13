resource "azurerm_log_analytics_workspace" "workspace" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.workspace_sku
  retention_in_days   = var.retention_in_days

  tags = var.tags
}


### DIAGNOSTIC SETTINGS

data "azurerm_monitor_diagnostic_categories" "diagset" {
  resource_id = azurerm_log_analytics_workspace.workspace.id
}

locals {
  log_categories = (
    data.azurerm_monitor_diagnostic_categories.diagset.logs
  )
  metric_categories = (
    data.azurerm_monitor_diagnostic_categories.diagset.metrics
  )

  logs = {
    for category in local.log_categories : category => {
      enabled        = var.enabled
      retention_days = var.retention_days
    }
  }

  metrics = {
    for metric in local.metric_categories : metric => {
      enabled        = var.enabled
      retention_days = var.retention_days
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  name                           = "${var.name}diagset-01"
  target_resource_id             = azurerm_log_analytics_workspace.workspace.id
  storage_account_id             = var.ds_map["storage_account_id"]
  log_analytics_workspace_id     = var.ds_map["log_analytics_workspace_id"]
  log_analytics_destination_type = var.log_analytics_destination_type

  dynamic "log" {
    for_each = local.logs

    content {
      category = log.key
      enabled  = log.value.enabled

      retention_policy {
        enabled = log.value.retention_days != null ? true : false
        days    = log.value.retention_days
      }
    }
  }

  dynamic "metric" {
    for_each = local.metrics

    content {
      category = metric.key
      enabled  = metric.value.enabled

      retention_policy {
        enabled = metric.value.retention_days != null ? true : false
        days    = metric.value.retention_days
      }
    }
  }
  lifecycle {
    ignore_changes = [
      log_analytics_destination_type
    ]
  }
}


resource "azurerm_monitor_metric_alert" "dynamic_alert" {
  depends_on = [azurerm_log_analytics_workspace.workspace]

  for_each            = var.dynamic_criteria
  name                = "metric_alert-${var.name}-001-${each.value.name}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_log_analytics_workspace.workspace.id]
  enabled             = each.value.enabled
  auto_mitigate       = var.auto_mitigate
  description         = each.value.description
  frequency           = var.frequency
  severity            = each.value.severity
  window_size         = var.window_size

  dynamic_criteria {
    metric_namespace         = each.value.metric_namespace
    metric_name              = each.value.metric_name
    aggregation              = each.value.aggregation
    operator                 = each.value.operator
    alert_sensitivity        = each.value.alert_sensitivity
    evaluation_total_count   = each.value.evaluation_total_count
    evaluation_failure_count = each.value.evaluation_failure_count
  }

  action {
    action_group_id = var.action_group
  }

  tags = var.tags
}
