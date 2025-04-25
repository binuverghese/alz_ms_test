# Resource Group outputs
output "hub_resource_group_id" {
  description = "ID of the hub resource group"
  value       = module.rg_hub.resource.id
}

output "firewall_resource_group_id" {
  description = "ID of the firewall resource group"
  value       = module.rg_firewall.resource.id
}

output "dns_resource_group_id" {
  description = "ID of the DNS resolver resource group"
  value       = module.rg_dns.resource.id
}

output "bastion_resource_group_id" {
  description = "ID of the Bastion resource group"
  value       = module.rg_bastion.resource.id
}

# Network outputs
output "hub_vnet_id" {
  description = "ID of the hub virtual network"
  value       = module.hub_vnet.resource.id
}

output "hub_vnet_name" {
  description = "Name of the hub virtual network"
  value       = module.hub_vnet.resource.name
}

output "dns_bastion_vnet_id" {
  description = "ID of the DNS/Bastion virtual network"
  value       = module.dns_bastion_vnet.resource.id
}

output "dns_bastion_vnet_name" {
  description = "Name of the DNS/Bastion virtual network"
  value       = module.dns_bastion_vnet.resource.name
}

# VNET Peering outputs
output "hub_to_dns_peering_id" {
  description = "ID of the peering from hub to DNS/Bastion VNET"
  value       = module.hub_to_dns_bastion_peering.resource_id
}

output "dns_to_hub_peering_id" {
  description = "ID of the peering from DNS/Bastion to hub VNET"
  value       = module.dns_bastion_to_hub_peering.resource_id
}

# Subnet outputs
output "hub_subnets" {
  description = "Map of subnets in the hub virtual network"
  value = {
    for subnet_name, subnet in module.hub_vnet.subnets : subnet_name => {
      id = subnet.resource_id
    }
  }
}

output "dns_bastion_subnets" {
  description = "Map of subnets in the DNS/Bastion virtual network"
  value = {
    for subnet_name, subnet in module.dns_bastion_vnet.subnets : subnet_name => {
      id = subnet.resource_id
    }
  }
}

# Firewall outputs
output "firewall_id" {
  description = "ID of the Azure Firewall"
  value       = module.firewall.resource.id
}

output "firewall_private_ip" {
  description = "Private IP of the Azure Firewall"
  value       = module.firewall.resource.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Public IP of the Azure Firewall"
  value       = module.firewall_pip.public_ip_address
}

# DNS Resolver outputs
output "dns_resolver_id" {
  description = "ID of the DNS Resolver"
  value       = module.private_resolver.resource.id
}

output "dns_inbound_endpoint_ip" {
  description = "IP address of the DNS Resolver inbound endpoint"
  value       = length(module.private_resolver.inbound_endpoints) > 0 ? module.private_resolver.inbound_endpoints["inbound1"].ip_configurations[0].private_ip_address : null
}

# Bastion outputs
output "bastion_id" {
  description = "ID of the Azure Bastion"
  value       = module.bastion.resource.id
}

output "bastion_public_ip" {
  description = "Public IP of the Azure Bastion"
  value       = module.bastion_pip.public_ip_address
}
