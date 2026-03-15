module "test" {
  source = "../"

  name                = "sb-servicebus-test"
  resource_group_name = "rg-servicebus-test"
  location            = "eastus2"
  sku                 = "Standard"
  capacity            = 0

  queues = {
    order-processing = {
      max_delivery_count    = 10
      max_size_in_megabytes = 1024
      lock_duration         = "PT1M"
      default_message_ttl   = "P14D"
    }
    notifications = {
      max_delivery_count                   = 5
      max_size_in_megabytes                = 1024
      dead_lettering_on_message_expiration = true
    }
  }

  topics = {
    events = {
      max_size_in_megabytes = 1024
      default_message_ttl   = "P7D"
      support_ordering      = true
    }
  }

  subscriptions = {
    event-processor = {
      topic_name                           = "events"
      max_delivery_count                   = 10
      lock_duration                        = "PT1M"
      dead_lettering_on_message_expiration = true
    }
  }

  namespace_authorization_rules = {
    app-sender = {
      listen = false
      send   = true
      manage = false
    }
  }

  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}
