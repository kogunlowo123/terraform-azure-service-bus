provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-servicebus-complete"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-servicebus-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "endpoints" {
  name                 = "snet-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "services" {
  name                 = "snet-services"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.ServiceBus"]
}

resource "azurerm_private_dns_zone" "servicebus" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "servicebus" {
  name                  = "servicebus-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.servicebus.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-servicebus-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "id-servicebus-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

module "service_bus" {
  source = "../../"

  name                          = "sb-complete-example"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  sku                           = "Premium"
  capacity                      = 1
  premium_messaging_partitions  = 1
  zone_redundant                = true
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  identity_type                 = "SystemAssigned, UserAssigned"
  identity_ids                  = [azurerm_user_assigned_identity.example.id]

  queues = {
    "orders" = {
      max_delivery_count                   = 10
      max_size_in_megabytes                = 5120
      lock_duration                        = "PT5M"
      default_message_ttl                  = "P14D"
      dead_lettering_on_message_expiration = true
      requires_duplicate_detection         = true
      duplicate_detection_history_time_window = "PT10M"
      max_message_size_in_kilobytes        = 102400
    }
    "order-deadletter-handler" = {
      max_delivery_count  = 5
      default_message_ttl = "P30D"
    }
    "session-queue" = {
      requires_session   = true
      max_delivery_count = 10
      lock_duration      = "PT2M"
    }
    "priority-queue" = {
      max_delivery_count                   = 15
      lock_duration                        = "PT30S"
      dead_lettering_on_message_expiration = true
    }
  }

  topics = {
    "events" = {
      max_size_in_megabytes         = 5120
      enable_batched_operations     = true
      requires_duplicate_detection  = true
      support_ordering              = true
      max_message_size_in_kilobytes = 102400
    }
    "audit" = {
      default_message_ttl = "P365D"
    }
    "notifications" = {
      max_size_in_megabytes     = 2048
      enable_batched_operations = true
    }
  }

  subscriptions = {
    "events-processor" = {
      topic_name                           = "events"
      max_delivery_count                   = 10
      lock_duration                        = "PT5M"
      dead_lettering_on_message_expiration = true
    }
    "events-archive" = {
      topic_name          = "events"
      max_delivery_count  = 3
      default_message_ttl = "P365D"
    }
    "audit-logger" = {
      topic_name         = "audit"
      max_delivery_count = 10
    }
    "notification-email" = {
      topic_name         = "notifications"
      max_delivery_count = 5
      requires_session   = true
    }
    "notification-sms" = {
      topic_name         = "notifications"
      max_delivery_count = 3
    }
  }

  subscription_rules = {
    "high-priority-filter" = {
      subscription_name = "events-processor"
      topic_name        = "events"
      filter_type       = "SqlFilter"
      sql_filter        = "priority = 'high' OR priority = 'critical'"
    }
    "email-correlation" = {
      subscription_name = "notification-email"
      topic_name        = "notifications"
      filter_type       = "CorrelationFilter"
      correlation_filter = {
        label = "email"
        properties = {
          channel = "email"
        }
      }
    }
  }

  namespace_authorization_rules = {
    "app-full-access" = {
      listen = true
      send   = true
      manage = true
    }
    "app-sender" = {
      send = true
    }
    "app-listener" = {
      listen = true
    }
  }

  queue_authorization_rules = {
    "orders-sender" = {
      queue_name = "orders"
      send       = true
    }
    "orders-receiver" = {
      queue_name = "orders"
      listen     = true
    }
  }

  topic_authorization_rules = {
    "events-publisher" = {
      topic_name = "events"
      send       = true
    }
  }

  network_rule_set = {
    default_action                = "Deny"
    trusted_services_allowed      = true
    public_network_access_enabled = false
    ip_rules                      = ["203.0.113.0/24"]
    network_rules = [
      {
        subnet_id                            = azurerm_subnet.services.id
        ignore_missing_vnet_service_endpoint = false
      }
    ]
  }

  private_endpoints = {
    "primary" = {
      subnet_id            = azurerm_subnet.endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.servicebus.id]
      subresource_names    = ["namespace"]
    }
  }

  diagnostic_settings = {
    "log-analytics" = {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      enabled_log_categories     = ["OperationalLogs", "VNetAndIPFilteringLogs", "RuntimeAuditLogs", "ApplicationMetricsLogs"]
      metric_categories          = ["AllMetrics"]
    }
  }

  tags = {
    Environment = "production"
    Project     = "example"
    CostCenter  = "IT-001"
  }
}

output "namespace_id" {
  value = module.service_bus.namespace_id
}

output "namespace_endpoint" {
  value = module.service_bus.namespace_endpoint
}

output "private_endpoint_ips" {
  value = module.service_bus.private_endpoint_ip_addresses
}
