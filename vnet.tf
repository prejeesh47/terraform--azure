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

#associate nsg with subnet
resource "azurerm_subnet_network_security_group_association" "wen-nsg-assoc" {
  subnet_id                 = azurerm_subnet.web-subnet.id
  network_security_group_id = azurerm_network_security_group.web-nsg.id
}

#public ip
resource "azurerm_public_ip" "web-pip" {
  name                = "web-pip"
  resource_group_name = azurerm_resource_group.web-rg.name
  location            = azurerm_resource_group.web-rg.location
  allocation_method   = "Static"

  tags = {
    env = "dev"
  }
}

#nic
resource "azurerm_network_interface" "web-nic" {
  name                = "web-nic"
  location            = azurerm_resource_group.web-rg.location
  resource_group_name = azurerm_resource_group.web-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web-pip.id

  }
}