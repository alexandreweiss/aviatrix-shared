// Enable DFW
# resource "aviatrix_distributed_firewalling_config" "dfw" {
#   enable_distributed_firewalling = true
# }

// Smart Groups
# resource "aviatrix_smart_group" "catch-all" {
#   name = "catch-all"
#   selector {
#     match_expressions {
#       cidr = "0.0.0.0/0"
#     }
#   }
# }

# resource "aviatrix_smart_group" "ferme" {
#   name = "ferme"
#   selector {
#     match_expressions {
#       cidr = "192.168.16.0/24"
#     }
#   }
# }

# resource "aviatrix_smart_group" "app1-front" {
#   name = "app1-front"
#   selector {
#     match_expressions {
#       type = "vm"
#       tags = {
#         environment = "app1-front"
#       }
#     }
#   }
# }

# resource "aviatrix_smart_group" "app2-front" {
#   name = "app2-front"
#   selector {
#     match_expressions {
#       type = "vm"
#       tags = {
#         environment = "app2-front"
#       }
#     }
#   }
# }

# resource "aviatrix_smart_group" "dev" {
#   name = "dev"
#   selector {
#     match_expressions {
#       type = "vm"
#       tags = {
#         environment = "dev"
#       }
#     }
#   }
# }

# resource "aviatrix_distributed_firewalling_policy_list" "policy" {
#   policies {
#     action = "DENY"
#     src_smart_groups = [ aviatrix_smart_group.dev.uuid ]
#     name = "DenyDevApp1"
#     protocol = "ANY"
#     dst_smart_groups = [ aviatrix_smart_group.app1-front.uuid ]
#     logging = true
#     priority = 100
#   }
#   policies {
#     action = "DENY"
#     src_smart_groups = [ aviatrix_smart_group.app1-front.uuid ]
#     name = "DenyApp1ToApp2"
#     protocol = "ANY"
#     dst_smart_groups = [ aviatrix_smart_group.app2-front.uuid ]
#     logging = true
#     priority = 200
#   }
#   policies {
#     action = "PERMIT"
#     src_smart_groups = [ aviatrix_smart_group.ferme.uuid ]
#     name = "AllowFerme"
#     protocol = "ANY"
#     dst_smart_groups = [ aviatrix_smart_group.catch-all.uuid ]
#     logging = true
#     priority = 3500
#   }
#   policies {
#     action = "PERMIT"
#     src_smart_groups = [ aviatrix_smart_group.catch-all.uuid ]
#     name = "DenyAll"
#     protocol = "ANY"
#     dst_smart_groups = [ aviatrix_smart_group.catch-all.uuid ]
#     logging = true
#     priority = 4000
#   }
# }
