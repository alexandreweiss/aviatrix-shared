output "guacamole_fqdn" {
  value = aws_eip.guacamole.public_dns
}

output "guacamole_login_url" {
  value = "https://${aws_eip.guacamole.public_dns}/#/index.html?username=guacadmin&password=${regex("'(\\w{12})'\\.", ssh_resource.guac_password.result)[0]}"
}

output "guacamole_username" {
  value = "guacadmin"
}

output "guacamole_password" {
  value = regex("'(\\w{12})'\\.", ssh_resource.guac_password.result)[0]
}

output "vpc1_windows_instances" {
  value = {
    ip       = module.ec2_instance_windows.private_ip,
    password = nonsensitive(rsadecrypt(module.ec2_instance_windows.password_data, module.key_pair.private_key_pem)),
    name     = module.ec2_instance_windows.tags_all["Name"]
  }
}
