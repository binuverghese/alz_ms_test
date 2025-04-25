locals {
  # Standard naming format: BU-Region-Archetype-WL-Env-WLDesc-RType
  
  # Resource Group Names
  hub_rg_name     = var.hub_rg_name != null ? var.hub_rg_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.wl_desc}-vnet-rg"
  firewall_rg_name = var.firewall_rg_name != null ? var.firewall_rg_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.wl_desc}-fw-rg"
  dns_rg_name      = var.dns_rg_name != null ? var.dns_rg_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.dns_wl_desc}-rg"
  bastion_rg_name  = var.bastion_rg_name != null ? var.bastion_rg_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.bastion_wl_desc}-rg"
  
  # Network Security Group Names
  hub_nsg_name        = var.hub_nsg_name != null ? var.hub_nsg_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.wl_desc}-nsg"
  dns_bastion_nsg_name = var.dns_bastion_nsg_name != null ? var.dns_bastion_nsg_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.dns_bastion_wl_desc}-nsg"
  
  # Route Table Names
  hub_route_table_name        = var.hub_route_table_name != null ? var.hub_route_table_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.wl_desc}-rt"
  dns_bastion_route_table_name = var.dns_bastion_route_table_name != null ? var.dns_bastion_route_table_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.dns_bastion_wl_desc}-rt"
  
  # Virtual Network Names
  hub_vnet_name        = var.hub_vnet_name != null ? var.hub_vnet_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.wl_desc}-vnet"
  dns_bastion_vnet_name = var.dns_bastion_vnet_name != null ? var.dns_bastion_vnet_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.dns_bastion_wl_desc}-vnet"
  firewall_vnet_name = var.firewall_vnet_name != null ? var.firewall_vnet_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-fw-vnet"
  
  # Firewall Resources
  firewall_name = var.firewall_name != null ? var.firewall_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.wl_desc}-fw"
  firewall_policy_name = var.firewall_policy_name != null ? var.firewall_policy_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.wl_desc}-fwpp"
  
  # DNS Resources
  dns_resolver_name = var.dns_resolver_name != null ? var.dns_resolver_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.dns_wl_desc}-resolver"
  
  # Bastion Resources
  bastion_name = var.bastion_name != null ? var.bastion_name : "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.bastion_wl_desc}"
  
  # Peering Names
  hub_to_dns_peering_name = var.hub_to_dns_peering_name != null ? var.hub_to_dns_peering_name : "${var.wl_desc}-to-${var.dns_bastion_wl_desc}"
  dns_to_hub_peering_name = var.dns_to_hub_peering_name != null ? var.dns_to_hub_peering_name : "${var.dns_bastion_wl_desc}-to-${var.wl_desc}"
  hub_to_firewall_peering_name = var.hub_to_firewall_peering_name
  firewall_to_hub_peering_name = var.firewall_to_hub_peering_name
}
