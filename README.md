# terraform-azure-service-bus

Production-ready Terraform module for deploying Azure Service Bus with comprehensive support for queues, topics, subscriptions, authorization rules, network security, private endpoints, and diagnostics.

## Architecture

```mermaid
flowchart TD
    A[Azure Service Bus Namespace] --> B[Queues]
    A --> C[Topics]
    A --> D[Authorization Rules]
    A --> E[Network Rule Set]
    A --> F[Private Endpoints]
    A --> G[Diagnostic Settings]
    C --> H[Subscriptions]
    H --> I[Subscription Rules]
    B --> J[Dead Letter Queues]
    B --> K[Session Support]
    F --> L[Private DNS Zone Groups]

    style A fill:#0078D4,stroke:#005A9E,color:#FFFFFF
    style B fill:#50E6FF,stroke:#0078D4,color:#000000
    style C fill:#50E6FF,stroke:#0078D4,color:#000000
    style D fill:#FFB900,stroke:#FF8C00,color:#000000
    style E fill:#FF6F61,stroke:#D44942,color:#FFFFFF
    style F fill:#7FBA00,stroke:#5E8C00,color:#FFFFFF
    style G fill:#B4A0FF,stroke:#8661C5,color:#000000
    style H fill:#00B7C3,stroke:#008B94,color:#FFFFFF
    style I fill:#00B7C3,stroke:#008B94,color:#FFFFFF
    style J fill:#FF4F4F,stroke:#CC3333,color:#FFFFFF
    style K fill:#FF9F00,stroke:#CC7F00,color:#000000
    style L fill:#7FBA00,stroke:#5E8C00,color:#FFFFFF
```

## Features

- Service Bus Namespace with Basic, Standard, and Premium SKU support
- Queues with dead-letter support, session handling, duplicate detection, and message TTL
- Topics with subscriptions and SQL/Correlation filter rules
- Namespace, queue, and topic-level authorization rules
- Network rule sets with IP rules and VNet integration
- Private endpoint connectivity with DNS zone groups
- Managed identity support (SystemAssigned, UserAssigned)
- Customer-managed key encryption
- Diagnostic settings for Log Analytics, Storage, and Event Hub
- Zone redundancy for Premium namespaces

## Usage

```hcl
module "service_bus" {
  source = "path/to/terraform-azure-service-bus"

  name                = "sb-myapp-prod"
  resource_group_name = "rg-myapp"
  location            = "East US"
  sku                 = "Premium"
  capacity            = 1

  queues = {
    "orders" = {
      max_delivery_count                   = 10
      dead_lettering_on_message_expiration = true
      default_message_ttl                  = "P14D"
    }
  }

  topics = {
    "events" = {
      max_size_in_megabytes = 5120
    }
  }

  subscriptions = {
    "events-processor" = {
      topic_name         = "events"
      max_delivery_count = 10
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Examples

- [Basic](./examples/basic/) - Simple namespace with queues
- [Advanced](./examples/advanced/) - Topics, subscriptions, rules, and authorization
- [Complete](./examples/complete/) - Full production setup with Premium SKU, private endpoints, network rules, and diagnostics

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| azurerm | >= 3.80.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | The name of the Service Bus namespace | `string` | n/a | yes |
| resource_group_name | The resource group name | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| sku | The SKU (Basic, Standard, Premium) | `string` | `"Standard"` | no |
| capacity | Messaging units for Premium | `number` | `0` | no |
| queues | Map of queues to create | `map(object)` | `{}` | no |
| topics | Map of topics to create | `map(object)` | `{}` | no |
| subscriptions | Map of subscriptions to create | `map(object)` | `{}` | no |
| subscription_rules | Map of subscription rules | `map(object)` | `{}` | no |
| namespace_authorization_rules | Namespace auth rules | `map(object)` | `{}` | no |
| queue_authorization_rules | Queue auth rules | `map(object)` | `{}` | no |
| topic_authorization_rules | Topic auth rules | `map(object)` | `{}` | no |
| network_rule_set | Network rule set config | `object` | `null` | no |
| private_endpoints | Private endpoints to create | `map(object)` | `{}` | no |
| diagnostic_settings | Diagnostic settings | `map(object)` | `{}` | no |
| tags | Tags to assign | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace_id | The ID of the Service Bus namespace |
| namespace_name | The name of the Service Bus namespace |
| namespace_endpoint | The endpoint URL |
| default_primary_connection_string | Primary connection string (sensitive) |
| queue_ids | Map of queue names to IDs |
| topic_ids | Map of topic names to IDs |
| subscription_ids | Map of subscription names to IDs |
| private_endpoint_ids | Map of private endpoint names to IDs |
| private_endpoint_ip_addresses | Map of private endpoint IPs |

## License

MIT License - see [LICENSE](./LICENSE) for details.
