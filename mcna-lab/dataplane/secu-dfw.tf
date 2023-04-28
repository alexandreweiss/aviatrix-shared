// Enable DFW
resource "aviatrix_distributed_firewalling_config" "dfw" {
  enable_distributed_firewalling = true
}

// Enable VPC for MicroSeg
resource "aviatrix_distributed_firewalling_intra_vpc" "app-vnet" {
  vpcs {
    account_name = local.accounts.azure_account
    vpc_id       = "${azurerm_virtual_network.r1-spoke-app.name}:${azurerm_resource_group.azr-r1-spoke-microseg-rg.name}:${azurerm_virtual_network.r1-spoke-app.guid}"
    region       = var.azure_r1_location
  }
}

// Smart Groups
resource "aviatrix_smart_group" "alex-catch-all" {
  name = "alex-catch-all"
  selector {
    match_expressions {
      cidr = "0.0.0.0/0"
    }
  }
}

resource "aviatrix_smart_group" "ferme" {
  name = "ferme"
  selector {
    match_expressions {
      cidr = "192.168.16.0/24"
    }
  }
}

resource "aviatrix_smart_group" "front-app" {
  name = "front-app"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        environment = "front-app"
      }
    }
  }
}

resource "aviatrix_smart_group" "sc-app" {
  name = "sc-app"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        environment = "sc-app"
      }
    }
  }
}

resource "aviatrix_smart_group" "sql-app" {
  name = "sql-app"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        environment = "sql-app"
      }
    }
  }
}

resource "aviatrix_distributed_firewalling_policy_list" "policy" {
  policies {
    action           = "PERMIT"
    src_smart_groups = [aviatrix_smart_group.front-app.uuid]
    name             = "AllowFrontToSc"
    protocol         = "TCP"
    port_ranges {
      lo = 443
    }
    dst_smart_groups = [aviatrix_smart_group.sc-app.uuid]
    logging          = true
    priority         = 100
  }
  policies {
    action           = "PERMIT"
    src_smart_groups = [aviatrix_smart_group.sc-app.uuid]
    name             = "AllowScToSql"
    protocol         = "TCP"
    port_ranges {
      lo = 1433
    }
    dst_smart_groups = [aviatrix_smart_group.sql-app.uuid]
    logging          = true
    priority         = 200
  }
  # policies {
  #   action           = "PERMIT"
  #   src_smart_groups = [aviatrix_smart_group.ferme.uuid]
  #   name             = "AllowFerme"
  #   protocol         = "ANY"
  #   dst_smart_groups = [aviatrix_smart_group.catch-all.uuid]
  #   logging          = true
  #   priority         = 3500
  # }
  # policies {
  #   action           = "PERMIT"
  #   src_smart_groups = [aviatrix_smart_group.catch-all.uuid]
  #   name             = "DenyAll"
  #   protocol         = "ANY"
  #   dst_smart_groups = [aviatrix_smart_group.catch-all.uuid]
  #   logging          = true
  #   priority         = 4000
  # }
}
