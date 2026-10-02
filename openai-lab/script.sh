# Generate self-signed certificate for HTTPS
# Adjust the -subj parameter as needed
openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout key.pem -out cert.pem -days 365 \
  -subj "/CN=chat.aviatrix.local"

# Install dependencies
sudo apt-get update
sudo apt-get install npm
sudo apt-get install python3-venv
sudo apt-get install python3-pip

# Install Rust for building the embedding tool
# Choose one of the following methods: 
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
or
sudo apt update
sudo apt install rustc cargo

# Point DNS to the Private DNS Resolver Inbound Endpoint from AWS VM
cat << 'EOF' | sudo tee /etc/netplan/99-custom-dns.yaml
network:
  version: 2
  ethernets:
    ens5:
      nameservers:
        addresses: [10.147.70.116]
      dhcp4-overrides:
        use-dns: false
        use-domains: false
EOF

# AI Search Index JSON
{
  "@odata.etag": "\"0x8DDFBA34DA85B85\"",
  "name": "oai-data-index",
  "fields": [
    {
      "name": "id",
      "type": "Edm.String",
      "searchable": false,
      "filterable": false,
      "retrievable": true,
      "stored": true,
      "sortable": false,
      "facetable": false,
      "key": true,
      "synonymMaps": []
    },
    {
      "name": "content",
      "type": "Edm.String",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "stored": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "analyzer": "standard.lucene",
      "synonymMaps": []
    },
    {
      "name": "embedding",
      "type": "Collection(Edm.Single)",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "stored": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "dimensions": 1536,
      "vectorSearchProfile": "vector-profile",
      "synonymMaps": []
    }
  ],
  "scoringProfiles": [],
  "suggesters": [],
  "analyzers": [],
  "normalizers": [],
  "tokenizers": [],
  "tokenFilters": [],
  "charFilters": [],
  "similarity": {
    "@odata.type": "#Microsoft.Azure.Search.BM25Similarity"
  },
  "semantic": {
    "configurations": [
      {
        "name": "semantic-conf",
        "flightingOptIn": false,
        "rankingOrder": "BoostedRerankerScore",
        "prioritizedFields": {
          "prioritizedContentFields": [
            {
              "fieldName": "content"
            }
          ],
          "prioritizedKeywordsFields": []
        }
      }
    ]
  },
  "vectorSearch": {
    "algorithms": [
      {
        "name": "defaultVectorAlgo",
        "kind": "hnsw",
        "hnswParameters": {
          "metric": "cosine",
          "m": 4,
          "efConstruction": 400,
          "efSearch": 500
        }
      }
    ],
    "profiles": [
      {
        "name": "vector-profile",
        "algorithm": "defaultVectorAlgo"
      }
    ],
    "vectorizers": [],
    "compressions": []
  }
}


# AI Search Indexer JSON
{
  "@odata.context": "URL FQDN,
  "@odata.etag": "\"0x8DDFB79EA7DA8C0\"",
  "name": "aoi-indexer",
  "description": null,
  "dataSourceName": "oai-data-datasource",
  "skillsetName": null,
  "targetIndexName": "oai-data-index",
  "disabled": null,
  "schedule": null,
  "parameters": {
    "batchSize": null,
    "maxFailedItems": null,
    "maxFailedItemsPerBatch": null,
    "configuration": {
      "dataToExtract": "contentAndMetadata"
    }
  },
  "fieldMappings": [
    {
      "sourceFieldName": "content",
      "targetFieldName": "content",
      "mappingFunction": null
    }
  ],
  "outputFieldMappings": [],
  "cache": null,
  "encryptionKey": null
}