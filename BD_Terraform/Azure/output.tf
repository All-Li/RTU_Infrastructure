output "resource_group_name" {
  value = azurerm_resource_group.BD_alizone.name
}

output "public_ip_address_Ubuntu" {
  value = azurerm_linux_virtual_machine.BD_alizone_Server[*].public_ip_address
}
