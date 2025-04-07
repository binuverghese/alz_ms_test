application_gateway_name = "appgw-dev-001"
location                 = "Canada Central"
resource_group_name      = "rg-dev-002"
appgw_subnet_id          = "/subscriptions/1e437fdf-bd78-431d-ba95-1498f0e84c10/resourceGroups/rg-dev-002/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/appgw-subnet"
appgw_public_ip_id       = "/subscriptions/1e437fdf-bd78-431d-ba95-1498f0e84c10/resourceGroups/rg-dev-002/providers/Microsoft.Network/publicIPAddresses/appgw-pip"
sku_name                 = "Standard_v2"
sku_tier                 = "Standard_v2"
capacity                 = 2
