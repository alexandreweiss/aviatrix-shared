# Manual steps

1. Upload data file to storage account in oai-data container
2. Create index and indexer in openai search (not available in TF yet)
az search index create --service-name aviatrix-ignite-search-146 --name oai-data-index --fields '[{"name": "id", "type": "Edm.String", "key": true, "searchable": false},{"name": "content", "type": "Edm.String", "searchable": true, "filterable": false, "sortable": false, "facetable": false}]'
3. Enable RBAC authN on search service
az search service update --name aviatrix-ignite-search --resource-group rg-oai-lab --auth-options aadOnly --aad-auth-failure-mode http403
4. "Allow Azure Services on trusted ..." needs to be enabled everytime apply is ran : this is on the Open AI search service

5. Configure DNS on AWS instance using https://repost.aws/fr/knowledge-center/ec2-static-dns-ubuntu-debian (netplan style)

cat << 'EOF' | sudo tee /etc/netplan/99-custom-dns.yaml
network:
  version: 2
  ethernets:
    ens5:
      nameservers:
        addresses: [172.19.10.116]
      dhcp4-overrides:
        use-dns: false
        use-domains: false
EOF