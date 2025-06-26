# Define the resource group
data "azurerm_resource_group" "my_rg" {
  name = ""   # azure resource group name
}

# Define the virtual network
resource "azurerm_virtual_network" "my_vnet" {
  name                = "myVnet"
  location            = data.azurerm_resource_group.my_rg.location
  resource_group_name = data.azurerm_resource_group.my_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Define the subnet
resource "azurerm_subnet" "my_subnet" {
  name                 = "mySubnet"
  resource_group_name  = data.azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define the Network Security Group
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = data.azurerm_resource_group.my_rg.location
  resource_group_name = data.azurerm_resource_group.my_rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-http-8080"
    priority                   = 110 # Must be unique and higher than 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }



}

# Create multiple network interfaces for 3 VMs
resource "azurerm_network_interface" "my_terraform_nic" {
  count               = var.vm_count
  name                = "myNIC-${count.index}"
  location            = data.azurerm_resource_group.my_rg.location
  resource_group_name = data.azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "myIPConfig-${count.index}"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.${10 + count.index}" # Assign specific static IPs
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip[count.index].id


  }
}

# Define the storage account
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "storagek8001" # Ensure this name is unique
  resource_group_name      = data.azurerm_resource_group.my_rg.name
  location                 = data.azurerm_resource_group.my_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create 3 Linux virtual machines and attach network interfaces
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  count                 = var.vm_count
  name                  = "k8s-node-${count.index}"
  location              = data.azurerm_resource_group.my_rg.location
  resource_group_name   = data.azurerm_resource_group.my_rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic[count.index].id]
  size                  = "Standard_B2ms"

  os_disk {
    name                 = "k8s-node-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    # publisher = "Canonical"
    # offer     = "0001-com-ubuntu-server-jammy"
    # sku       = "22_04-lts-gen2"
    # version   = "latest"

    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_5-gen2"
    version   = "latest"
  }

  computer_name                   = "k8s-node-${count.index}"
  admin_username                  = "azureuser"
  admin_password                  = "Welc0me@123"
  disable_password_authentication = false

  admin_ssh_key {
    username   = "azureuser"
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }


  # custom_data = base64encode(lookup(var.init_scripts, count.index))
  # custom_data = base64encode(trimspace(replace(lookup(var.init_scripts, count.index), "\r\n", "\n")))

  custom_data = base64encode(trimspace(replace(local.init_scripts[count.index], "\r\n", "\n")))



}


# Associate the network security group with each NIC
resource "azurerm_network_interface_security_group_association" "example" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.my_terraform_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  #name                = "myPublicIP"
  count               = var.vm_count
  name                = "myPublicIP-${count.index}"
  location            = data.azurerm_resource_group.my_rg.location
  resource_group_name = data.azurerm_resource_group.my_rg.name
  #allocation_method   = "Dynamic"
  sku               = "Standard" # You have this set already
  allocation_method = "Static"   # This is REQUIRED for Standard SKU
}

locals {
  init_scripts = {
    0 = file("${path.module}/node0.sh")
    1 = file("${path.module}/node1.sh")
    2 = file("${path.module}/node2.sh")
    3 = file("${path.module}/node3.sh")
    4 = file("${path.module}/node4.sh")
  }
}


