#cloud-config
# yum_repos:
#   epel:  
#     name: Extra Packages for Enterprise Linux $releasever - $basearch
#     baseurl: https://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch
#     metalink: https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir
#     failovermethod: priority
#     enabled: 1
#     gpgcheck: 0
#   IF NAT IS NEEDED ... - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
package_update: true
packages:
  - frr
write_files:
  - owner: root:root
    append: true
    path: /etc/sysctl.conf
    content: |
      net.ipv4.ip_forward=1
  - owner: root:root
    append: true
    path: /etc/rc.local
    content: |
      sudo iptables-restore < /etc/iptables.conf
  - owner: frr:frr
    append: true
    path: /etc/frr/frr.conf
    content: |
      !
      router bgp ${asn_fw}
       bgp router-id 169.254.169.254
       network ${spoke_vnet_cidr}
       neighbor ${bgp_peer_1_ip} remote-as ${ars_asn}
       neighbor ${bgp_peer_1_ip} soft-reconfiguration inbound
       neighbor ${bgp_peer_1_ip} route-map ilb-nh out
       neighbor ${bgp_peer_2_ip} remote-as ${ars_asn}
       neighbor ${bgp_peer_2_ip} soft-reconfiguration inbound
       neighbor ${bgp_peer_2_ip} route-map ilb-nh out
      !
      access-list 100 seq 5 permit ${spoke_vnet_cidr}
      !
      route-map ilb-nh permit 10
        match ip address 100
        set ip next-hop ${peer_ilb_ip_address}
      !
       address-family ipv4 unicast
        exit-address-family
       address-family ipv6
       exit-address-family
       exit
      !
      line vty
      !
    defer: true
runcmd:
  - sysctl -w net.ipv4.ip_forward=1
  - iptables-save > /etc/iptables.conf
  - sed -i -e "s/bgpd=no/bgpd=yes/g" /etc/frr/daemons
  - systemctl restart frr
