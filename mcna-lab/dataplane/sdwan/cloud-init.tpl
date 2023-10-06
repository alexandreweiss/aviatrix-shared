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
      router bgp ${asn_sdwan}
       bgp router-id 169.254.169.254
       network 10.60.2.0/24
       neighbor ${transit_gw_bgp_ip} remote-as 65515
       neighbor ${transit_gw_bgp_ip} soft-reconfiguration inbound
       neighbor ${transit_hagw_bgp_ip} remote-as 65515
       neighbor ${transit_hagw_bgp_ip} soft-reconfiguration inbound
      !
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
