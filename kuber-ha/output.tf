output "public_ip_address" {
  # value = azurerm_linux_virtual_machine.my_terraform_vm[count.index].public_ip_address
  value = {
    for key, instance in azurerm_linux_virtual_machine.my_terraform_vm : key => instance.public_ip_address
  }
}


