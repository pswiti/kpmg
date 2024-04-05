output "resource_group_name" {
  value = azurerm_resource_group.example.name
  description = "Name of the resource group"
}

output "azurerm_virtual_network" {
  value = azurerm_virtual_network.example.name
  description = "Name of the Vnet"
}

output "azurerm_virtual_machine" {
  value = azurerm_virtual_machine.webvm.name
  description = "Name of the VM"
}

output "azurerm_public_ip" {
  value = azurerm_public_ip.testrg.*.ip_address
  description = "Name of the Vnet"
}
