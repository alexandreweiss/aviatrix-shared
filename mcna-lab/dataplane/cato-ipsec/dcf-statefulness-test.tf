# DCF statefulness test (temporary). Set var.enable_dcf_stateful_test = false and apply to remove.
#
# Only the forward direction (Gatus VM in MyApp1 -> MyApp2 test VM) is permitted. The reverse
# direction is explicitly denied, so a reply is only accepted if the enforcing gateway has the
# connection state of the request. If a request enters through the spoke HA gateway and the
# reply leaves through the spoke primary gateway, the primary has no state and drops the reply.

data "aviatrix_dcf_attachment_point" "tf_before_ui" {
  count = (var.enable_dcf_stateful_test || var.enable_dcf_allweb_rule) ? 1 : 0
  name  = "TERRAFORM_BEFORE_UI_MANAGED"
}

resource "aviatrix_smart_group" "gatus" {
  count = var.enable_dcf_stateful_test ? 1 : 0
  name  = "stateful-test-gatus-vm"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        role = "gatus"
      }
    }
  }
}

resource "aviatrix_smart_group" "myapp2_vm" {
  count = var.enable_dcf_stateful_test ? 1 : 0
  name  = "stateful-test-myapp2-vm"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        application = "MyApp2"
      }
    }
  }
}

resource "aviatrix_dcf_ruleset" "stateful_test" {
  count = var.enable_dcf_stateful_test ? 1 : 0
  name  = "stateful-test-rs"

  rules {
    name             = "gatus-to-myapp2-icmp"
    action           = "PERMIT"
    protocol         = "ICMP"
    src_smart_groups = [aviatrix_smart_group.gatus[0].uuid]
    dst_smart_groups = [aviatrix_smart_group.myapp2_vm[0].uuid]
    logging          = true
    priority         = 100
  }

  rules {
    name     = "gatus-to-myapp2-ssh"
    action   = "PERMIT"
    protocol = "TCP"
    port_ranges {
      lo = 22
    }
    src_smart_groups = [aviatrix_smart_group.gatus[0].uuid]
    dst_smart_groups = [aviatrix_smart_group.myapp2_vm[0].uuid]
    logging          = true
    priority         = 110
  }

  # Web group rule: Gatus VM -> built-in "AllWeb" web group (def000ad-...-0002) on web ports.
  rules {
    name     = "gatus-to-allweb"
    action   = "PERMIT"
    protocol = "TCP"
    port_ranges {
      lo = 80
    }
    port_ranges {
      lo = 443
    }
    src_smart_groups = [aviatrix_smart_group.gatus[0].uuid]
    dst_smart_groups = ["def000ad-0000-0000-0000-000000000000"] # Anywhere
    web_groups       = ["def000ad-0000-0000-0000-000000000002"] # AllWeb
    logging          = true
    priority         = 10
  }

  # Replies are only allowed through connection state: no state, no pass.
  rules {
    name             = "deny-myapp2-to-gatus-new"
    action           = "DENY"
    protocol         = "ANY"
    src_smart_groups = [aviatrix_smart_group.myapp2_vm[0].uuid]
    dst_smart_groups = [aviatrix_smart_group.gatus[0].uuid]
    logging          = true
    priority         = 200
  }
}

resource "aviatrix_dcf_policy_group" "stateful_test" {
  count     = var.enable_dcf_stateful_test ? 1 : 0
  attach_to = data.aviatrix_dcf_attachment_point.tf_before_ui[0].id
  name      = "stateful-test-pg"

  ruleset_reference {
    priority    = 50
    target_uuid = aviatrix_dcf_ruleset.stateful_test[0].id
  }
}

# ---------------------------------------------------------------------------------------
# AllWeb rule (kept separate from the statefulness test): web egress for every Gatus VM,
# placed at the top of the TF-before-UI policy list. Toggle with var.enable_dcf_allweb_rule.
# ---------------------------------------------------------------------------------------
resource "aviatrix_smart_group" "gatus_all" {
  count = var.enable_dcf_allweb_rule ? 1 : 0
  name  = "gatus-all-vms"

  selector {
    match_expressions {
      type = "vm"
      tags = {
        role = "gatus"
      }
    }
    match_expressions {
      type = "vm"
      tags = {
        role = "gatus-source"
      }
    }
    match_expressions {
      type = "vm"
      tags = {
        role = "gatus-dashboard"
      }
    }
  }
}

resource "aviatrix_dcf_ruleset" "allweb" {
  count = var.enable_dcf_allweb_rule ? 1 : 0
  name  = "allweb-rs"

  rules {
    name     = "gatus-to-allweb"
    action   = "PERMIT"
    protocol = "TCP"
    port_ranges {
      lo = 80
    }
    port_ranges {
      lo = 443
    }
    src_smart_groups = [aviatrix_smart_group.gatus_all[0].uuid]
    dst_smart_groups = ["def000ad-0000-0000-0000-000000000000"] # Anywhere
    web_groups       = ["def000ad-0000-0000-0000-000000000002"] # AllWeb
    logging          = true
    priority         = 10
  }
}

resource "aviatrix_dcf_policy_group" "allweb" {
  count     = var.enable_dcf_allweb_rule ? 1 : 0
  attach_to = data.aviatrix_dcf_attachment_point.tf_before_ui[0].id
  name      = "allweb-pg"

  ruleset_reference {
    priority    = 10
    target_uuid = aviatrix_dcf_ruleset.allweb[0].id
  }
}
