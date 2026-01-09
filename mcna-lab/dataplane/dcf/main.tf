data "aviatrix_dcf_attachment_point" "tf_before_ui" {
  name = "TERRAFORM_BEFORE_UI_MANAGED"
}

data "aviatrix_dcf_attachment_point" "tf_after_ui" {
  name = "TERRAFORM_AFTER_UI_MANAGED"
}

resource "aviatrix_smart_group" "to-router-ipv6" {
  name = "on-prem-india"
  selector {
    match_expressions {
      s2c = "to-router-ipv6"
    }
  }
}

resource "aviatrix_smart_group" "ops-workload" {
  name = "ops-wl-sg"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        application = "myapp1"
      }
    }
  }
}

resource "aviatrix_smart_group" "eng-workload" {
  name = "eng-wl-sg"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        application = "MyApp2"
      }
    }
  }
}

resource "aviatrix_smart_group" "ops-cidr-workload" {
  name = "ops-wl-cidr-sg"
  selector {
    match_expressions {
      cidr = "53.203.226.0/30"
    }
  }
}


# We can then retrieve the ID of the attachment point and attach the ruleset to it using the attach_to field.

resource "aviatrix_dcf_policy_group" "operation_teams" {
  # attach_to field can be used to attach to any other attachment_point in another policy_group
  attach_to = data.aviatrix_dcf_attachment_point.tf_before_ui.id
  name      = "operation-teams-pg"
  ruleset_reference {
    priority    = 100
    target_uuid = aviatrix_dcf_ruleset.ruleset_opsteam_1.id
  }

  # ruleset_reference {
  #   priority    = 200
  #   target_uuid = aviatrix_dcf_ruleset.ruleset_opsteam_2.id
  # }

  attachment_point {
    name     = "ops_attachment_point"
    priority = 100
  }
}

resource "aviatrix_dcf_ruleset" "ruleset_opsteam_1" {
  name = "opsteam-1-rs"
  rules {
    action           = "PERMIT"
    src_smart_groups = [aviatrix_smart_group.ops-workload.uuid, aviatrix_smart_group.to-router-ipv6.uuid]
    name             = "AllowHttps"
    protocol         = "TCP"
    port_ranges {
      lo = 443
    }
    dst_smart_groups = [aviatrix_smart_group.to-router-ipv6.uuid, aviatrix_smart_group.ops-workload.uuid]
    logging          = true
    priority         = 100
  }
  rules {
    action           = "PERMIT"
    src_smart_groups = [aviatrix_smart_group.ops-workload.uuid, aviatrix_smart_group.to-router-ipv6.uuid]
    name             = "AllowHttp"
    protocol         = "TCP"
    port_ranges {
      lo = 80
    }
    dst_smart_groups = [aviatrix_smart_group.to-router-ipv6.uuid, aviatrix_smart_group.ops-workload.uuid]
    logging          = true
    priority         = 150
  }
  rules {
    action           = "PERMIT"
    src_smart_groups = [aviatrix_smart_group.ops-workload.uuid, aviatrix_smart_group.to-router-ipv6.uuid]
    name             = "AllowIcmp"
    protocol         = "ICMP"
    dst_smart_groups = [aviatrix_smart_group.to-router-ipv6.uuid, aviatrix_smart_group.ops-workload.uuid]
    logging          = true
    # log_profile      = "def000ad-7000-0000-0000-000000000003"
    priority = 200
  }
  rules {
    action           = "DENY"
    src_smart_groups = ["def000ad-0000-0000-0000-000000000000"]
    name             = "DenyAllOps"
    protocol         = "ICMP"
    dst_smart_groups = ["def000ad-0000-0000-0000-000000000000"]
    logging          = true
    # log_profile      = "def000ad-7000-0000-0000-000000000003"
    priority = 1000
  }
}

# resource "aviatrix_dcf_ruleset" "ruleset_opsteam_2" {
#   name = "opsteam-2-rs"
#   rules {
#     action           = "PERMIT"
#     src_smart_groups = [aviatrix_smart_group.ops-cidr-workload.uuid]
#     name             = "AllowHttps"
#     protocol         = "TCP"
#     port_ranges {
#       lo = 443
#     }
#     dst_smart_groups = [aviatrix_smart_group.ops-cidr-workload.uuid]
#     logging          = true
#     priority         = 100
#   }
#   rules {
#     action           = "PERMIT"
#     src_smart_groups = [aviatrix_smart_group.ops-cidr-workload.uuid]
#     name             = "AllowHttp"
#     protocol         = "TCP"
#     port_ranges {
#       lo = 80
#     }
#     dst_smart_groups = [aviatrix_smart_group.ops-cidr-workload.uuid]
#     logging          = true
#     priority         = 150
#   }
#   rules {
#     action           = "PERMIT"
#     src_smart_groups = [aviatrix_smart_group.ops-cidr-workload.uuid]
#     name             = "AllowIcmp"
#     protocol         = "ICMP"
#     dst_smart_groups = [aviatrix_smart_group.ops-cidr-workload.uuid]
#     logging          = true
#     priority         = 200
#   }
# }

## Engineering

data "aviatrix_dcf_attachment_point" "ops_attachment_point" {
  name = "ops_attachment_point"
}

resource "aviatrix_dcf_policy_group" "engineering_teams" {
  # attach_to field can be used to attach to any other attachment_point in another policy_group
  attach_to = data.aviatrix_dcf_attachment_point.ops_attachment_point.id
  name      = "engineering-teams-pg"
  ruleset_reference {
    priority    = 100
    target_uuid = aviatrix_dcf_ruleset.ruleset_engteam_1.id
  }

  # ruleset_reference {
  #   priority    = 200
  #   target_uuid = aviatrix_dcf_ruleset.ruleset_engteam_2.id
  # }
}

resource "aviatrix_dcf_ruleset" "ruleset_engteam_1" {
  name = "engteam-1-rs"
  rules {
    action           = "PERMIT"
    src_smart_groups = [aviatrix_smart_group.eng-workload.uuid]
    name             = "AllowIcmp"
    protocol         = "ICMP"
    dst_smart_groups = [aviatrix_smart_group.eng-workload.uuid]
    logging          = true
    priority         = 200
  }
}

# resource "aviatrix_dcf_ruleset" "ruleset_engteam_2" {
#   name = "engteam-2-rs"
# }
