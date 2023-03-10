#vnet 
resource "azurerm_virtual_network" "web-vnet" {
  name                = "web-network"
  location            = azurerm_resource_group.web-rg.location
  resource_group_name = azurerm_resource_group.web-rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    env  = "dev"
    tier = "frontendapp"

  }
}

#subnet
resource "azurerm_subnet" "web-subnet" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.web-rg.name
  virtual_network_name = azurerm_virtual_network.web-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#nsg
resource "azurerm_network_security_group" "web-nsg" {
  name                = "web-rules"
  location            = azurerm_resource_group.web-rg.location
  resource_group_name = azurerm_resource_group.web-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "web-ssh" {
  name                        = "web-ssh"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.web-rg.name
  network_security_group_name = azurerm_network_security_group.web-nsg.name
}

resource "azurerm_network_security_rule" "web-http" {
  name                        = "web-http"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.web-rg.name
  network_security_group_name = azurerm_network_security_group.web-nsg.name
}