# Report: Cato with two PoPs (HA full mesh) versus a single PoP

Lab: Aviatrix transit and spokes in Azure Central India, connected to Cato Networks with IPsec IKEv2
and BGP. Tests ran on 2026-11-24 and are logged in the "Test log" of [README.md](README.md).

## Summary

- **Non-working design:** both Aviatrix devices (the transit and the MyApp2 spoke) connect to **both**
  Cato PoPs in an HA full mesh (4 tunnels each). Pings from some MyApp2 VMs to the transit gateways'
  own addresses fail **permanently and per source**; pings to a VM behind the transit work for all.
- **Working design:** the same two devices, same Cato sites, same PSK and addressing, connected to
  **PoP 1 only** (2 tunnels each). Every probe passes.
- Only the connection design changed between the runs (switches `single_pop_transit` and
  `single_pop_spoke`), on the same 13 test VMs. Later tests (C and D) show the **transit** being on
  both PoPs is the trigger; the spoke's setting does not matter.
- Not caused by (each tested and rejected): the choice of transit tunnel, the MyApp2 HA spoke gateway,
  a gateway being up or down, or the VM itself. The loss happens after the VM and depends on the
  source IP and target, which points at how Cato handles flows when two PoPs are connected. This
  report shows which design works; it does not prove Cato's internal reason.
- **Fix, keeping both PoPs:** raise the Cato BGP peer metric of the **transit site's PoP 2 peers** to 200
  (`transit_bgp_peers.tf`, default `transit_pop2_peer_metric = 200`). The full HA mesh on both devices
  then passes every probe (test G).

## Topology (both designs)

```
 MyApp1 spoke (10.10.4.0/23) --- Aviatrix transit (10.10.0.0/23, AS 65007)
   Gatus VMs (7)                  GW 10.10.0.36 + HA GW 10.10.0.52
                                          |  IPsec + BGP
                                   Cato (AS 65111): PoP 1 113.30.136.81 / PoP 2 113.30.136.22
                                          |  IPsec + BGP
 MyApp2 spoke (10.10.6.0/23, AS 65012)  GW 10.10.6.4 + HA GW 10.10.6.68
   Gatus VMs (6): m2src1 to m2src6 (10.10.6.133 to .138)
```

MyApp2 is not attached to the transit: its only path to the transit and MyApp1 is through Cato.

## Design A: HA full mesh (does NOT work for the transit gateway probes)

Terraform (`main.tf`, `single_pop_transit = false`, `single_pop_spoke = false`), for both `aviatrix_transit_external_device_conn` (`Cato`)
and `aviatrix_spoke_external_device_conn` (`Cato-MyApp2`):

```hcl
ha_enabled                = true
remote_gateway_ip         = "113.30.136.81"     # PoP 1, primary peer
backup_remote_gateway_ip  = "113.30.136.22"     # PoP 2, backup peer
local_tunnel_cidr         = "<primary /30>,<HA /30>"   # PoP 1 tunnels
backup_local_tunnel_cidr  = "<primary /30>,<HA /30>"   # PoP 2 tunnels
# + BGP over IKEv2, one shared PSK, Cato sites with 4 tunnels (2 per PoP) and 4 BGP peers
```

Result: **4 tunnels per connection** (each Aviatrix gateway to each PoP), all Up, BGP established to
both PoPs on both devices.

## Design B: single PoP (works)

Same code with `single_pop_transit = true` and `single_pop_spoke = true`:

```hcl
ha_enabled                = false
remote_gateway_ip         = "113.30.136.81"     # PoP 1 only
# no backup_* attributes
```

Result: **2 tunnels per connection** (primary and HA gateway to PoP 1), BGP established to PoP 1.
The Cato sites keep their PoP 2 tunnels configured (they stay down).

## Method

- 13 Gatus VMs probe every 10 s: 6 in MyApp2 (`m2src1` to `m2src6`) probing the transit gateways
  (ICMP to 10.10.0.36 and 10.10.0.52) and the MyApp1 VM (ICMP, TCP 22, TCP 80); 7 in MyApp1
  probing the MyApp2 gateways and VM (ICMP, TCP 22). One dashboard aggregates them (groups `transit`
  and `spoke`).
- Each sample is the last 50 checks per probe (about 8 minutes): single PoP 18:23:04 to 18:31:21 UTC
  (started 8 minutes after the rebuild), HA mesh 18:41:05 to 18:49:26 UTC (5 minutes after its
  rebuild). Raw data: `~/cato-ping/sample_*.json` on the test host (not in the repo).

## Results

Pings from each MyApp2 source to the transit gateways (checks OK / checks):

| Source | A: HA mesh to .36 | A: HA mesh to .52 | B: single PoP to .36 | B: single PoP to .52 |
|---|---|---|---|---|
| m2src1 (10.10.6.137) | 0/50 | 0/50 | 50/50 | 50/50 |
| m2src2 (10.10.6.133) | 50/50 | 0/50 | 50/50 | 50/50 |
| m2src3 (10.10.6.135) | 50/50 | 0/50 | 50/50 | 50/50 |
| m2src4 (10.10.6.136) | 50/50 | 0/50 | 50/50 | 50/50 |
| m2src5 (10.10.6.138) | 50/50 | 0/50 | 50/50 | 50/50 |
| m2src6 (10.10.6.134) | 0/50 | 0/50 | 50/50 | 50/50 |
| **Total** | **200/600** | | **600/600** | |

Everything else (the `spoke` group: MyApp1 and MyApp2 VMs and gateways, ICMP and TCP) passed in both
designs: A 2300/2300 (46 probes), B 2300/2300 (46 probes).

Over the hours before this A/B, with the HA mesh active, the same two sources (m2src1 and m2src6)
failed continuously to 10.10.0.36 (m2src1 also to 10.10.0.52, m2src4 to 10.10.0.52), while
m2src2, m2src3 and m2src5 worked. The pattern was reproduced after rebuilding all test VMs
(same IPs). In the HA mesh at the time of the A/B, 10.10.0.52 failed for every source; in the
single-PoP design every source reaches both gateways.

## Which side triggers it (tests C and D)

The two Aviatrix devices were switched independently (`single_pop_transit`, `single_pop_spoke`):

| Design | Transit | MyApp2 spoke | Transit-gateway pings (last ~50 checks per probe) |
|---|---|---|---|
| A | both PoPs (HA mesh) | both PoPs | **fail**: 200/600 |
| B | PoP 1 only | PoP 1 only | OK: 600/600 |
| C | PoP 1 only | both PoPs | OK: 600/600 (spoke group 2299/2300) |
| D | both PoPs (HA mesh) | PoP 1 only | **fail**: 186/559, same failing pairs as A |

**The transit being connected to both Cato PoPs is what triggers the failure.** The MyApp2 spoke can
use one PoP or both without effect. In D the failing pairs are the same as in A: m2src1 and m2src6
to 10.10.0.36 and every source to 10.10.0.52.

## The fix: keep both PoPs, make Cato prefer PoP 1 for the transit (tests F and G)

Hypothesis: with the transit on both PoPs, Cato spreads inbound flows to the transit's own addresses over
all four of the site's BGP peers (all with metric 100), while the transit answers via PoP 1 (shorter AS
path). A flow can then enter on PoP 2 and be answered on PoP 1, and Cato drops that asymmetric return.
Change: the two Cato BGP peers of the transit site that belong to PoP 2 (peer IPs 192.168.20.9 and
192.168.20.13) get a higher metric (200 instead of 100; Cato prefers the lower metric), so Cato sends
traffic to the transit through PoP 1 and keeps PoP 2 as a backup. Managed in `transit_bgp_peers.tf`
(variable `transit_pop2_peer_metric`); the four existing peers were imported with no differences.

| Design | Transit | MyApp2 spoke | Cato metric of the transit's PoP 2 peers | Transit-gateway pings |
|---|---|---|---|---|
| A | both PoPs | both PoPs | 100 | **fail** (200/600) |
| D | both PoPs | PoP 1 only | 100 | **fail** (186/559) |
| F | both PoPs | PoP 1 only | **200** | **OK** (600/600), spoke group 2300/2300 |
| G | both PoPs | both PoPs | **200** | **OK**: 569/569, spoke group 2187/2189 (two isolated single missed pings) |

F shows the failures disappear without giving up the second PoP: the transit stays connected to both
PoPs (HA, PoP 2 as backup) and only Cato's preference changed. G is the full target design (HA mesh on
the transit and on the spoke, plus the fix) and it works: last ~47 checks per probe, 19:46:30 to
19:54:26 UTC.

## What was ruled out

| Test | Outcome |
|---|---|
| tcpdump on a failing source and a working one (same subnet and route) | Failing: requests leave, 0 replies. Working: replies in about 12 ms. The loss is after the VM. |
| Stop the transit HA gateway (no choice of transit tunnel) | The same sources still failed. |
| Stop the MyApp2 HA spoke gateway | The same sources still failed. |
| Asymmetric paths between PoPs or between gateways (earlier tests) | Did not break ICMP or TCP connects. |
| Prepend or Cato peer metric to steer the PoP | Does not change Cato's choice. |

## Conclusion and caveats

- With both PoPs connected on the transit and the spoke (HA full mesh), some flows between
  MyApp2 and the transit gateways are dropped, deterministically per source and target. With a single PoP
  on both sides no flow is dropped. The design is the variable.
- Not proven: the exact mechanism inside Cato (per-flow PoP or path choice, or state per
  PoP). Only the two ends' behavior and the gateways' view were observed.
- Traffic through the transit to a VM (MyApp1) was fine in both designs; only traffic addressed to
  the gateways' own IPs showed the problem. It may not matter for real traffic, but it is a clear symptom.

## Suggested next steps

0. Adopt the fix (tests F and G) in the real design and keep the metric difference whenever the transit
   connects to both PoPs.
1. Give this report and the failing pairs (for example 10.10.6.137 to 10.10.0.36 and 10.10.0.52) to
   Cato support, with timestamps, asking how flows between two sites with two PoPs each are routed.
2. Test with PoP 2 only on both sides (to check PoP 1 is not the special one).
3. Test with one device on two PoPs and the other on one PoP, to see which side triggers it.

## Reproduce

In `variables.tf` set `single_pop_transit` and `single_pop_spoke` (both `false` = design A, both `true` = design B, mixed = tests C and D) and apply in the
`aviatrix-shared-cato` workspace (the two connections are replaced, about 2 minutes). Watch the
Gatus dashboard `transit` group.

The Gatus test fleet (13 source VMs, the dashboard and the original Gatus VM, in `../spoke`) was
destroyed after the tests. To recreate it set `enable_gatus_fleet = true` in the
`aviatrix-shared-spoke` workspace and apply. The temporary DCF rules in this folder are off
(`enable_dcf_allweb_rule` and `enable_dcf_stateful_test` are `false`).
