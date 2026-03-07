provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-servicebus-basic"
  location = "East US"
}

module "service_bus" {
  source = "../../"

  name                = "sb-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"

  queues = {
    "orders" = {
      max_delivery_count                   = 10
      dead_lettering_on_message_expiration = true
    }
    "notifications" = {
      default_message_ttl = "P7D"
    }
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}

output "namespace_id" {
  value = module.service_bus.namespace_id
}

output "queue_ids" {
  value = module.service_bus.queue_ids
}
