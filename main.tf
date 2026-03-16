resource "azurerm_servicebus_namespace" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  capacity                      = var.sku == "Premium" ? var.capacity : 0
  premium_messaging_partitions  = var.sku == "Premium" ? var.premium_messaging_partitions : 0
  local_auth_enabled            = var.local_auth_enabled
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version
  zone_redundant                = var.sku == "Premium" ? var.zone_redundant : false

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []
    content {
      key_vault_key_id                  = customer_managed_key.value.key_vault_key_id
      identity_id                       = customer_managed_key.value.identity_id
      infrastructure_encryption_enabled = customer_managed_key.value.infrastructure_encryption_enabled
    }
  }

  tags = var.tags
}

resource "azurerm_servicebus_namespace_network_rule_set" "this" {
  count = var.network_rule_set != null ? 1 : 0

  namespace_id                  = azurerm_servicebus_namespace.this.id
  default_action                = var.network_rule_set.default_action
  trusted_services_allowed      = var.network_rule_set.trusted_services_allowed
  public_network_access_enabled = var.network_rule_set.public_network_access_enabled
  ip_rules                      = var.network_rule_set.ip_rules

  dynamic "network_rules" {
    for_each = var.network_rule_set.network_rules
    content {
      subnet_id                            = network_rules.value.subnet_id
      ignore_missing_vnet_service_endpoint = network_rules.value.ignore_missing_vnet_service_endpoint
    }
  }
}

resource "azurerm_servicebus_queue" "this" {
  for_each = var.queues

  name                                    = each.key
  namespace_id                            = azurerm_servicebus_namespace.this.id
  max_delivery_count                      = each.value.max_delivery_count
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  lock_duration                           = each.value.lock_duration
  default_message_ttl                     = each.value.default_message_ttl
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  enable_batched_operations               = each.value.enable_batched_operations
  enable_express                          = each.value.enable_express
  enable_partitioning                     = each.value.enable_partitioning
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  requires_session                        = each.value.requires_session
  forward_to                              = each.value.forward_to
  forward_dead_lettered_messages_to       = each.value.forward_dead_lettered_messages_to
  max_message_size_in_kilobytes           = each.value.max_message_size_in_kilobytes
  status                                  = each.value.status
}

resource "azurerm_servicebus_topic" "this" {
  for_each = var.topics

  name                                    = each.key
  namespace_id                            = azurerm_servicebus_namespace.this.id
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  default_message_ttl                     = each.value.default_message_ttl
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  enable_batched_operations               = each.value.enable_batched_operations
  enable_express                          = each.value.enable_express
  enable_partitioning                     = each.value.enable_partitioning
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  max_message_size_in_kilobytes           = each.value.max_message_size_in_kilobytes
  support_ordering                        = each.value.support_ordering
  status                                  = each.value.status
}

resource "azurerm_servicebus_subscription" "this" {
  for_each = var.subscriptions

  name                                      = each.key
  topic_id                                  = azurerm_servicebus_topic.this[each.value.topic_name].id
  max_delivery_count                        = each.value.max_delivery_count
  lock_duration                             = each.value.lock_duration
  default_message_ttl                       = each.value.default_message_ttl
  auto_delete_on_idle                       = each.value.auto_delete_on_idle
  enable_batched_operations                 = each.value.enable_batched_operations
  dead_lettering_on_message_expiration      = each.value.dead_lettering_on_message_expiration
  dead_lettering_on_filter_evaluation_error = each.value.dead_lettering_on_filter_evaluation_error
  requires_session                          = each.value.requires_session
  forward_to                                = each.value.forward_to
  forward_dead_lettered_messages_to         = each.value.forward_dead_lettered_messages_to
  status                                    = each.value.status
}

resource "azurerm_servicebus_subscription_rule" "this" {
  for_each = var.subscription_rules

  name            = each.key
  subscription_id = azurerm_servicebus_subscription.this[each.value.subscription_name].id
  filter_type     = each.value.filter_type
  sql_filter      = each.value.sql_filter
  action          = each.value.action

  dynamic "correlation_filter" {
    for_each = each.value.correlation_filter != null ? [each.value.correlation_filter] : []
    content {
      content_type        = correlation_filter.value.content_type
      correlation_id      = correlation_filter.value.correlation_id
      label               = correlation_filter.value.label
      message_id          = correlation_filter.value.message_id
      reply_to            = correlation_filter.value.reply_to
      reply_to_session_id = correlation_filter.value.reply_to_session_id
      session_id          = correlation_filter.value.session_id
      to                  = correlation_filter.value.to
      properties          = correlation_filter.value.properties
    }
  }
}

resource "azurerm_servicebus_namespace_authorization_rule" "this" {
  for_each = var.namespace_authorization_rules

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id
  listen       = each.value.listen
  send         = each.value.send
  manage       = each.value.manage
}

resource "azurerm_servicebus_queue_authorization_rule" "this" {
  for_each = var.queue_authorization_rules

  name     = each.key
  queue_id = azurerm_servicebus_queue.this[each.value.queue_name].id
  listen   = each.value.listen
  send     = each.value.send
  manage   = each.value.manage
}

resource "azurerm_servicebus_topic_authorization_rule" "this" {
  for_each = var.topic_authorization_rules

  name     = each.key
  topic_id = azurerm_servicebus_topic.this[each.value.topic_name].id
  listen   = each.value.listen
  send     = each.value.send
  manage   = each.value.manage
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "${var.name}-pe-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = "${var.name}-psc-${each.key}"
    private_connection_resource_id = azurerm_servicebus_namespace.this.id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = each.value.is_manual_connection
    request_message                = each.value.is_manual_connection ? each.value.request_message : null
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "${var.name}-dnsgroup-${each.key}"
      private_dns_zone_ids = each.value.private_dns_zone_ids
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.key
  target_resource_id             = azurerm_servicebus_namespace.this.id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  storage_account_id             = each.value.storage_account_id
  eventhub_name                  = each.value.eventhub_name
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  partner_solution_id            = each.value.partner_solution_id

  dynamic "enabled_log" {
    for_each = each.value.enabled_log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
      enabled  = true
    }
  }
}
