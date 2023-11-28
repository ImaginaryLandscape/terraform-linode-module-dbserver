locals {
  ssh_keys = [
    for value in toset(var.authorized_keys) : chomp(file(value))
  ]
}

locals {
  ssh_keys_str = join("\n\n", local.ssh_keys)
}

resource "linode_sshkey" "authKeys" {
  for_each        = toset(local.ssh_keys)
  label           = "Initial deploy SSH key"
  ssh_key         = each.value
}

resource "linode_instance" "db" {
  count           = var.node_count
  label           = "${var.SITE}-db${var.ID + count.index}.${var.DOMAIN}"
  image           = var.image
  region          = var.region
  type            = var.instance_type
  backups_enabled = var.backups_enabled
  authorized_keys = local.ssh_keys
  root_pass       = random_string.password.result
  group           = var.group
  tags            = var.tags
  private_ip      = true

  connection {
    type     = "ssh"
    user     = "root"
    password = random_string.password.result
    host     = self.ip_address
  }

  provisioner "file" {
    source      = "sshd_public_key_only.conf"
    destination = "/etc/ssh/sshd_config.d/sshd_public_key_only.conf"
  }

  provisioner "file" {
    source      = "access_setup.sh"
    destination = "/tmp/access_setup.sh"
  }

    provisioner "file" {
    source      = "user.txt"
    destination = "/tmp/user.txt"
  }

   provisioner "file" {
    source      = "useradd.sh"
    destination = "/tmp/useradd.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/access_setup.sh",
      "sudo sh /tmp/access_setup.sh -u ${var.admin_user} -k '${local.ssh_keys_str}'",
      "sudo bash -c \"echo '${var.admin_user}:${random_string.password.result}' | sudo chpasswd\"",
      "service sshd restart",
      "sudo hostnamectl set-hostname '${var.SITE}-db${var.ID + count.index}.${var.DOMAIN}'",
      "if [ ${var.create_users} = true ]; then sudo chmod +x /tmp/useradd.sh; fi",
      "if [ ${var.create_users} = true ]; then sudo bash /tmp/useradd.sh; fi",
      "if [ ${var.create_users} = true ]; then service sshd restart; fi"
    ]
  }
}

