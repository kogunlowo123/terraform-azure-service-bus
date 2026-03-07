output "namespace_id" {
  description = "The ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "The name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.name
}

output "namespace_endpoint" {
  description = "The endpoint URL of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.endpoint
}

output "default_primary_connection_string" {
  description = "The primary connection string for the namespace default authorization rule."
  value       = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive   = true
}

output "default_secondary_connection_string" {
  description = "The secondary connection string for the namespace default authorization rule."
  value       = azurerm_servicebus_namespace.this.default_secondary_connection_string
  sensitive   = true
}

output "default_primary_key" {
  description = "The primary access key for the namespace default authorization rule."
  value       = azurerm_servicebus_namespace.this.default_primary_key
  sensitive   = true
}

output "default_secondary_key" {
  description = "The secondary access key for the namespace default authorization rule."
  value       = azurerm_servicebus_namespace.this.default_secondary_key
  sensitive   = true
}

output "identity" {
  description = "The identity block of the Service Bus namespace."
  value       = try(azurerm_servicebus_namespace.this.identity[0], null)
}

output "queue_ids" {
  description = "Map of queue names to their IDs."
  value       = { for k, v in azurerm_servicebus_queue.this : k => v.id }
}

output "topic_ids" {
  description = "Map of topic names to their IDs."
  value       = { for k, v in azurerm_servicebus_topic.this : k => v.id }
}

output "subscription_ids" {
  description = "Map of subscription names to their IDs."
  value       = { for k, v in azurerm_servicebus_subscription.this : k => v.id }
}

output "namespace_authorization_rule_ids" {
  description = "Map of namespace authorization rule names to their IDs."
  value       = { for k, v in azurerm_servicebus_namespace_authorization_rule.this : k => v.id }
}

output "namespace_authorization_rule_primary_connection_strings" {
  description = "Map of namespace authorization rule names to their primary connection strings."
  value       = { for k, v in azurerm_servicebus_namespace_authorization_rule.this : k => v.primary_connection_string }
  sensitive   = true
}

output "queue_authorization_rule_ids" {
  description = "Map of queue authorization rule names to their IDs."
  value       = { for k, v in azurerm_servicebus_queue_authorization_rule.this : k => v.id }
}

output "topic_authorization_rule_ids" {
  description = "Map of topic authorization rule names to their IDs."
  value       = { for k, v in azurerm_servicebus_topic_authorization_rule.this : k => v.id }
}

output "private_endpoint_ids" {
  description = "Map of private endpoint names to their IDs."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_ip_addresses" {
  description = "Map of private endpoint names to their private IP addresses."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.private_service_connection[0].private_ip_address }
}
