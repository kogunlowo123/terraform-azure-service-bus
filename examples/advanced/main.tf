provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-servicebus-advanced"
  location = "East US"
}

module "service_bus" {
  source = "../../"

  name                = "sb-advanced-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  minimum_tls_version = "1.2"

  queues = {
    "orders" = {
      max_delivery_count                   = 10
      lock_duration                        = "PT5M"
      default_message_ttl                  = "P14D"
      dead_lettering_on_message_expiration = true
      requires_duplicate_detection         = true
      duplicate_detection_history_time_window = "PT10M"
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
  }

  topics = {
    "events" = {
      max_size_in_megabytes        = 5120
      enable_batched_operations    = true
      requires_duplicate_detection = true
      support_ordering             = true
    }
    "audit" = {
      default_message_ttl = "P90D"
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
  }

  subscription_rules = {
    "high-priority-filter" = {
      subscription_name = "events-processor"
      topic_name        = "events"
      filter_type       = "SqlFilter"
      sql_filter        = "priority = 'high'"
    }
  }

  namespace_authorization_rules = {
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
  }

  tags = {
    Environment = "staging"
    Project     = "example"
  }
}

output "namespace_endpoint" {
  value = module.service_bus.namespace_endpoint
}

output "topic_ids" {
  value = module.service_bus.topic_ids
}
