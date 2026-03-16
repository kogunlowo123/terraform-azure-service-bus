variable "name" {
  description = "The name of the Service Bus namespace."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{4,48}[a-zA-Z0-9]$", var.name))
    error_message = "Namespace name must be 6-50 characters, start with a letter, end with a letter or number, and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region for the Service Bus namespace."
  type        = string
}

variable "sku" {
  description = "The SKU of the namespace (Basic, Standard, or Premium)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Premium."
  }
}

variable "capacity" {
  description = "The number of messaging units for a Premium namespace (1, 2, 4, 8, or 16)."
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 2, 4, 8, 16], var.capacity)
    error_message = "Capacity must be one of: 0, 1, 2, 4, 8, 16. Use 0 for Basic/Standard SKUs."
  }
}

variable "premium_messaging_partitions" {
  description = "The number of partitions for a Premium namespace (1, 2, or 4)."
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 2, 4], var.premium_messaging_partitions)
    error_message = "Premium messaging partitions must be one of: 0, 1, 2, 4."
  }
}

variable "local_auth_enabled" {
  description = "Whether SAS authentication is enabled for the namespace."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the namespace."
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "The minimum supported TLS version for the namespace."
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be one of: 1.0, 1.1, 1.2."
  }
}

variable "zone_redundant" {
  description = "Whether the namespace is zone redundant (Premium SKU only)."
  type        = bool
  default     = false
}

variable "identity_type" {
  description = "The type of managed identity (SystemAssigned, UserAssigned, or both)."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "A list of user-assigned managed identity IDs."
  type        = list(string)
  default     = []
}

variable "customer_managed_key" {
  description = "Customer managed key configuration for encryption."
  type = object({
    key_vault_key_id                  = string
    identity_id                       = string
    infrastructure_encryption_enabled = optional(bool, false)
  })
  default = null
}

variable "queues" {
  description = "Map of Service Bus queues to create."
  type = map(object({
    max_delivery_count                      = optional(number, 10)
    max_size_in_megabytes                   = optional(number, 1024)
    lock_duration                           = optional(string, "PT1M")
    default_message_ttl                     = optional(string, null)
    auto_delete_on_idle                     = optional(string, null)
    duplicate_detection_history_time_window = optional(string, null)
    enable_batched_operations               = optional(bool, true)
    enable_express                          = optional(bool, false)
    enable_partitioning                     = optional(bool, false)
    dead_lettering_on_message_expiration    = optional(bool, false)
    requires_duplicate_detection            = optional(bool, false)
    requires_session                        = optional(bool, false)
    forward_to                              = optional(string, null)
    forward_dead_lettered_messages_to       = optional(string, null)
    max_message_size_in_kilobytes           = optional(number, null)
    status                                  = optional(string, "Active")
  }))
  default = {}
}

variable "topics" {
  description = "Map of Service Bus topics to create."
  type = map(object({
    max_size_in_megabytes                   = optional(number, 1024)
    default_message_ttl                     = optional(string, null)
    auto_delete_on_idle                     = optional(string, null)
    duplicate_detection_history_time_window = optional(string, null)
    enable_batched_operations               = optional(bool, true)
    enable_express                          = optional(bool, false)
    enable_partitioning                     = optional(bool, false)
    requires_duplicate_detection            = optional(bool, false)
    max_message_size_in_kilobytes           = optional(number, null)
    support_ordering                        = optional(bool, false)
    status                                  = optional(string, "Active")
  }))
  default = {}
}

variable "subscriptions" {
  description = "Map of Service Bus topic subscriptions to create."
  type = map(object({
    topic_name                                = string
    max_delivery_count                        = optional(number, 10)
    lock_duration                             = optional(string, "PT1M")
    default_message_ttl                       = optional(string, null)
    auto_delete_on_idle                       = optional(string, null)
    enable_batched_operations                 = optional(bool, true)
    dead_lettering_on_message_expiration      = optional(bool, false)
    dead_lettering_on_filter_evaluation_error = optional(bool, true)
    requires_session                          = optional(bool, false)
    forward_to                                = optional(string, null)
    forward_dead_lettered_messages_to         = optional(string, null)
    status                                    = optional(string, "Active")
  }))
  default = {}
}

variable "subscription_rules" {
  description = "Map of subscription rules to create."
  type = map(object({
    subscription_name = string
    topic_name        = string
    filter_type       = optional(string, "SqlFilter")
    sql_filter        = optional(string, null)
    action            = optional(string, null)
    correlation_filter = optional(object({
      content_type        = optional(string, null)
      correlation_id      = optional(string, null)
      label               = optional(string, null)
      message_id          = optional(string, null)
      reply_to            = optional(string, null)
      reply_to_session_id = optional(string, null)
      session_id          = optional(string, null)
      to                  = optional(string, null)
      properties          = optional(map(string), {})
    }), null)
  }))
  default = {}
}

variable "namespace_authorization_rules" {
  description = "Map of namespace-level authorization rules."
  type = map(object({
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
  default = {}
}

variable "queue_authorization_rules" {
  description = "Map of queue-level authorization rules."
  type = map(object({
    queue_name = string
    listen     = optional(bool, false)
    send       = optional(bool, false)
    manage     = optional(bool, false)
  }))
  default = {}
}

variable "topic_authorization_rules" {
  description = "Map of topic-level authorization rules."
  type = map(object({
    topic_name = string
    listen     = optional(bool, false)
    send       = optional(bool, false)
    manage     = optional(bool, false)
  }))
  default = {}
}

variable "network_rule_set" {
  description = "Network rule set configuration for the namespace."
  type = object({
    default_action                = optional(string, "Allow")
    trusted_services_allowed      = optional(bool, true)
    public_network_access_enabled = optional(bool, true)
    ip_rules                      = optional(list(string), [])
    network_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })), [])
  })
  default = null
}

variable "private_endpoints" {
  description = "Map of private endpoints to create for the namespace."
  type = map(object({
    subnet_id                       = string
    private_dns_zone_ids            = optional(list(string), [])
    subresource_names               = optional(list(string), ["namespace"])
    is_manual_connection            = optional(bool, false)
    request_message                 = optional(string, null)
    private_service_connection_name = optional(string, null)
  }))
  default = {}
}

variable "diagnostic_settings" {
  description = "Map of diagnostic settings to create."
  type = map(object({
    log_analytics_workspace_id     = optional(string, null)
    storage_account_id             = optional(string, null)
    eventhub_name                  = optional(string, null)
    eventhub_authorization_rule_id = optional(string, null)
    partner_solution_id            = optional(string, null)
    enabled_log_categories         = optional(list(string), ["OperationalLogs", "VNetAndIPFilteringLogs", "RuntimeAuditLogs", "ApplicationMetricsLogs"])
    metric_categories              = optional(list(string), ["AllMetrics"])
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
