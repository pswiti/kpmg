resource "azurerm_subnet" "web"
 name                 = "web"
 resource_group_name  = azurerm_resource_group.testrg.name
 virtual_network_name = azurerm_virtual_network.testvnet.name
 address_prefix       = "10.0.1.0/24"
}

resource "azurerm_network_interface" "webnic"{
 count               = 2
 name                = "webnic${count.index}"
 location            = azurerm_resource_group.testrg.location
 resource_group_name = azurerm_resource_group.testrg.name
 network_security_group_id = "${azurerm_network_security_group.webnsg.id}"
 

 ip_configuration {
   name                          = "testrgConfiguration"
   subnet_id                     = azurerm_subnet.web.id
   private_ip_address_allocation = "dynamic"
   load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.tier1.id}"]
 }
}

resource "azurerm_availability_set" "webavset" {
 name                         = "webavset"
 location                     = azurerm_resource_group.testrg.location
 resource_group_name          = azurerm_resource_group.testrg.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
}

resource "azurerm_virtual_machine" "webvm"{
 count                 = 2
 name                  = "webvm${count.index}"
 location              = azurerm_resource_group.testrg.location
 availability_set_id   = azurerm_availability_set.webavset.id
 resource_group_name   = azurerm_resource_group.testrg.name
 network_interface_ids = [element(azurerm_network_interface.webnic.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 # delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 # delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latestrg"
 }

 storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 os_profile {
   computer_name  = "hostname"
   admin_username = "testrgadmin"
   admin_password = "Password1234!"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

resource "azurerm_network_security_group" "webnsg" {
  name                = "web_nsg"
  location            = "${azurerm_resource_group.testrg.location}"
  resource_group_name = "${azurerm_resource_group.testrg.name}"

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.1.0/24"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.1.0/24"
  }
resource "azurerm_public_ip" "testrg" {
 name                         = "publicIPForLB"
 location                     = azurerm_resource_group.testrg.location
 resource_group_name          = azurerm_resource_group.testrg.name
 allocation_method            = "Static"
}
resource "azurerm_lb" "weblb" {
 name                = "loadBalancer"
 location            = azurerm_resource_group.testrg.location
 resource_group_name = azurerm_resource_group.testrg.name
 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.testrg.id
 }
}
resource "azurerm_lb_backend_address_pool" "tier1" {
 resource_group_name = azurerm_resource_group.testrg.name
 loadbalancer_id     = azurerm_weblb.testrg.id
 name                = "BackEndAddressPool"
}
resource "azurerm_lb_rule" "weblbrule"{
  resource_group_name            = azurerm_resource_group.testrg.name
  loadbalancer_id                = azurerm_lb.weblb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.tier1.id
  probe_id                       = azurerm_lb_probe.tier1-LBProbe.id
  depends_on                     = ["azurerm_lb_probe.tier1-LBProbe"]
}
resource "azurerm_lb_probe" "tier1-LBProbe" {
  location            = "${azurerm_resource_group.testrg.location}"
  resource_group_name = "${azurerm_resource_group.testrg.name}"
  loadbalancer_id     = "${azurerm_lb.weblb.id}"
  name                = "HTTP"
  port                = 80
}
