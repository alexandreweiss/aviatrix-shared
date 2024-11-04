# Manual steps

1. Upload data file to storage account in oai-data container
2. Create index and indexer in openai search (not available in TF yet)
az search index create --service-name aviatrix-ignite-search --name oai-data-index --fields '[{"name": "id", "type": "Edm.String", "key": true, "searchable": false},{"name": "content", "type": "Edm.String", "searchable": true, "filterable": false, "sortable": false, "facetable": false}]'
3. Enable RBAC authN on search service
az search service update --name aviatrix-ignite-search --resource-group rg-oai-lab --auth-options aadOnly --aad-auth-failure-mode http403