provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}
resource "azurerm_resource_group" "BD_alizone" {
  name     = "BD_alizone-resource-group"
  location = "westcentralus"
}
resource "azurerm_virtual_network" "BD_alizone" {
  name                = "BD_alizone-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.BD_alizone.location
  resource_group_name = azurerm_resource_group.BD_alizone.name
  tags = {
    Name = "virtual-network-alizone"
  }
}
resource "azurerm_subnet" "BD_alizone" {
  name                 = "BD_alizone-subnet"
  resource_group_name  = azurerm_resource_group.BD_alizone.name
  virtual_network_name = azurerm_virtual_network.BD_alizone.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "BD_alizone" {
  count               = 1
  name                = "BD_alizone_Public_IP-${count.index}"
  location            = azurerm_resource_group.BD_alizone.location
  resource_group_name = azurerm_resource_group.BD_alizone.name
  allocation_method   = "Dynamic"
}
resource "azurerm_network_interface" "BD_alizone" {
  count               = 1
  name                = "BD_alizone-Net_Interface-${count.index}"
  location            = azurerm_resource_group.BD_alizone.location
  resource_group_name = azurerm_resource_group.BD_alizone.name
  ip_configuration {
    name                          = "BD_alizone-IpConfiguration-${count.index}"
    subnet_id                     = azurerm_subnet.BD_alizone.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.BD_alizone[count.index].id
  }
}
resource "azurerm_network_security_group" "BD_alizone" {
  name                = "BD_alizone_setwork_security_group"
  location            = azurerm_resource_group.BD_alizone.location
  resource_group_name = azurerm_resource_group.BD_alizone.name
  security_rule { 
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Port_80"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    Name  = "Bakalaura darba drošības grupa"
    Owner = "Alla Lizone"
  }
}
resource "azurerm_linux_virtual_machine" "BD_alizone_Server" {
  count                 = 1
  name                  = "BD_alizone_Ubuntu_VM-${count.index}"
  location              = azurerm_resource_group.BD_alizone.location
  resource_group_name   = azurerm_resource_group.BD_alizone.name
  network_interface_ids = [azurerm_network_interface.BD_alizone[count.index].id]
  size                  = "Standard_F2"
  os_disk {
    name                 = "myOsDisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  computer_name                   = "MyUbuntu-${count.index}"
  admin_username                  = "adminuser"
  disable_password_authentication = true
  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.ssh_public_key)
  }
  tags = {
    Name  = "Mans Bakalaura darba serveris Azure vidē"
    Owner = "Alla Lizone"
  }
}