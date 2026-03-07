locals {
  # Determine capacity based on SKU
  capacity = var.sku == "Premium" ? var.capacity : 0

  # Premium messaging partitions only apply to Premium SKU
  premium_messaging_partitions = var.sku == "Premium" ? var.premium_messaging_partitions : 0

  # Zone redundancy only available for Premium SKU
  zone_redundant = var.sku == "Premium" ? var.zone_redundant : false

  # Build subscription lookup for rule references
  subscription_lookup = {
    for k, v in var.subscriptions : k => {
      topic_name = v.topic_name
    }
  }

  # Flatten private endpoint DNS zone groups
  private_endpoint_dns_zones = {
    for k, v in var.private_endpoints : k => v.private_dns_zone_ids
    if length(v.private_dns_zone_ids) > 0
  }

  # Default tags
  default_tags = {
    ManagedBy = "Terraform"
    Module    = "terraform-azure-service-bus"
  }

  merged_tags = merge(local.default_tags, var.tags)
}
