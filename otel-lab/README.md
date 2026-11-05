# OTEL-LAB

OpenTelemetry Collector (core image) in Azure Container Instances, used as an OTLP destination for Aviatrix Telemetry Export Profiles.
Public OTLP gRPC (4317) + HTTP (4318), **TLS with a self-signed cert** (Aviatrix requires TLS), no client auth.
All received data is printed to container stdout by the `debug` exporter (verbosity `detailed`).

## Deploy

HCP Terraform workspace `aviatrix-shared-otel` (org `ananableu`, needs Azure creds).

```bash
terraform init
terraform apply -auto-approve
```

## Aviatrix Telemetry Export Profile

| Field | Value |
|---|---|
| Protocol | gRPC with Server TLS (recommended) or HTTP with TLS |
| Destination (gRPC) | `terraform output -raw aviatrix_grpc_destination` (host:port, no scheme) |
| Destination (HTTP) | `terraform output -raw aviatrix_http_destination` (full https URL) |
| CA Certificate | `terraform output -raw aviatrix_ca_certificate_pem` |

The cert is regenerated if the stack is destroyed/recreated: update the CA Certificate in Aviatrix then.

## Check what is received

```bash
$(terraform output -raw logs_cmd) | grep -vE "handshake|^net/http"
```

`TLS handshake error ... EOF` every ~15s from 10.92.0.x are Azure probes: harmless.

## Notes

- DCF log records carry `avx.dcf.policy.*` attributes. `src.address` / `dest.address` are decimal-encoded IPv4 (KQL: `format_ipv4(tolong(x))`).
- Endpoint is open to the internet (server TLS only). mTLS: see commented `client_ca_file` in `otel-config.yaml`. Lab only; destroy when done: `terraform destroy -auto-approve`.
- Config change: edit `otel-config.yaml`, apply. ACI replaces the group (IP changes, DNS label stays).
- To forward to Sentinel / reshape data, switch to the `otel/opentelemetry-collector-contrib` image (Azure exporters, `transform` processor).
