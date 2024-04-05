
resource "azurerm_subnet" "db"
 name                 = "dbsub"
 resource_group_name  = azurerm_resource_group.testrg.name
 virtual_network_name = azurerm_virtual_network.testvnet.name
 address_prefix       = "10.0.2.0/24"
 
 enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_security_group" "dbnsg" {
  name                = "db_nsg"
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
    destination_address_prefix = "10.0.2.0/24"
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
    destination_address_prefix = "10.0.2.0/24"
}

resource "azurerm_network_interface" "appnic"{
 count               = 2
 name                = "appnic${count.index}"
 location            = azurerm_resource_group.testrg.location
 resource_group_name = azurerm_resource_group.testrg.name
 network_security_group_id = azurerm_network_security_group.appnsg.id
 

 ip_configuration {
   name                          = "testrgConfiguration"
   subnet_id                     = azurerm_subnet.app.id
   private_ip_address_allocation = "dynamic"
   load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.tier2.id}"]
 }
}
resource "azurerm_sql_server" "example" {
  name                         = "myexamplesqlserver"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "examplesa"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "example" {
  name                = "myexamplesqldatabase"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  server_name         = azurerm_sql_server.example.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.example.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.example.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }



  tags = {
    environment = "production"
  }
}

resource "azurerm_private_endpoint" "plink" {
  name                = "sqlprivate-endpoint"
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name
  subnet_id           = azurerm_subnet.db.id

  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_sql_server.sqlsrv.id
    subresource_names              = [ "sqlServer" ]
    is_manual_connection           = false
  }
  
resource "azurerm_private_dns_zone" "plink_dns_private_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.testrg.name
}


resource "azurerm_private_dns_a_record" "private_endpoint_a_record" {
  name                = azurerm_sql_server.sqlsrv.name
  zone_name           = azurerm_private_dns_zone.plink_dns_private_zone.name
  resource_group_name = azurerm_resource_group.testrg.name
  ttl                 = 300
  records             = ["${data.azurerm_private_endpoint_connection.plinkconnection.private_service_connection.0.private_ip_address}"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "zone_to_vnet_link" {
  name                  = "test"
  resource_group_name   = azurerm_resource_group.testrg.name
  private_dns_zone_name = azurerm_private_dns_zone.plink_dns_private_zone.name
  virtual_network_id    = azurerm_virtual_network.testvnet.id
}
