# terraform-module-linode-dbserver

## Module

Invoke this module from the root `main.tf` file.

```hcl
module "dbserver" {
  source            = "../modules/terraform-linode-module-dbserver"
  admin_user        = var.admin_user
  authorized_keys   = var.authorized_keys
  region            = var.LN_REGION
  group             = var.linode_db_instance_group
  image             = var.linode_db_instance_image
  instance_type     = var.linode_db_instance_type
  node_count        = var.linode_db_instance_node_count
  tags              = var.linode_db_instance_tags
  SITE              = var.SITE
  ID                = var.ID
  DOMAIN            = var.DOMAIN
}
```
