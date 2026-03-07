# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added

- Initial release of the Azure Service Bus Terraform module
- Service Bus Namespace with Basic, Standard, and Premium SKU support
- Queue management with dead-letter queues, session support, and message TTL configuration
- Topic management with subscriptions and filtering rules (SQL and Correlation)
- Namespace, queue, and topic-level authorization rules
- Network rule set with IP rules and VNet service endpoint integration
- Private endpoint support with private DNS zone group configuration
- Managed identity support (SystemAssigned and UserAssigned)
- Customer-managed key encryption for Premium namespaces
- Diagnostic settings for Log Analytics, Storage Account, and Event Hub
- Zone redundancy support for Premium namespaces
- Comprehensive examples: basic, advanced, and complete
- Full documentation with architecture diagrams
