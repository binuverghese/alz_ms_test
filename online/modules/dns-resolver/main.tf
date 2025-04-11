resource "azurerm_firewall" "example" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = var.firewall_policy_id
  sku_name = "AZFW_Hub" 
  sku_tier = "Standard"  
  # Public IP configuration for the firewall
  ip_configuration {
    name                 = "example-firewall-ipconfig"
    public_ip_address_id = var.public_ip_id
    subnet_id            = var.subnet_id
  }
}
