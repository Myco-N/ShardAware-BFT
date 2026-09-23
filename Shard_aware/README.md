# Shard-Aware Message Routing for BFT Sharded Networks

**ICSOC 2026 Artifact** (Submission #124)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-24+-blue.svg)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-EC2%20c5.4xlarge-orange.svg)](https://aws.amazon.com/ec2/)

This repository contains the complete experimental artifact for the paper:

> **Reduced Transfer Messaging Using Byzantine Fault Tolerance (BFT) for Sharded Networks**  
> ICSOC 2026

It reproduces all results reported in the paper (throughput > 20 000 TPS, end-to-end latency 1–9 ms, 60–72 % inter-shard latency reduction) on a 300-node Tendermint-based testbed.

## Quick Start (Single Command)

```bash
# Requires: Docker 24+, Terraform 1.5+, Ansible 2.14+, AWS credentials
./reproduce.sh --nodes 300 --shards 20 --tps 20000
```

Results and figures appear in `results/` and `figures/`.

## Hardware Requirements

| Component          | Specification                      |
| ------------------ | ---------------------------------- |
| AliCloud Instances | 20 × `c5.4xlarge` (16 vCPU, 32 GB) |
| Total Validators   | 300 (15 per instance)              |
| Network            | 10–100 ms emulated latency         |
| Bandwidth          | 1 Gbps per node                    |

Estimated cost for a full run: ~US$12–15 (4 hours).

## Directory Layout

```
ICSOC2026-Artifact/
├── README.md                 # This file
├── LICENSE                   # MIT
├── reproduce.sh              # One-click reproduction script
├── deploy/
│   └── aws/                  # Terraform + Ansible for EC2
├── docker/                   # Dockerfiles & compose for 300-node testbed
├── bench/                    # Workload generators (Python + Go)
├── netem/                    # Linux tc network emulation scripts
├── protocol/                 # Core Shard-Aware Message Routing implementation
├── docs/                     # Protocol specification & security proofs
├── results/                  # Raw logs & CSV (generated)
└── figures/                  # Regenerated plots (generated)
```

## Detailed Usage

### 1. Provision Infrastructure

```bash
cd deploy/aws
terraform init
terraform apply -var="instance_count=20"
```

### 2. Launch Dockerized Testbed

```bash
./docker/launch_testbed.sh --nodes 300 --shards 20
```

### 3. Apply Network Emulation

```bash
./netem/apply_latency.sh --min 10 --max 100
```

### 4. Run Benchmarks

```bash
# Cross-shard workload at configurable TPS
python3 bench/generate_workload.py --tps 20000 --duration 120 --cross-shard-ratio 0.4
go run bench/inject_tps.go --target 20000 --shards 20
```

### 5. Collect Results & Regenerate Figures

```bash
./reproduce.sh --collect-only
```

## Protocol Implementation

The core hierarchical routing logic lives in `protocol/`:

- `leader_election.go` – VRF + stake-weighted election
- `dual_layer_failover.go` – hot-standby + committee view-change
- `message_router.go` – O(S²) inter-shard aggregation with 2f+1 threshold signatures
- `reshuffle.go` – adaptive shard resizing

See `docs/protocol_spec.md` for the formal algorithms corresponding to Algorithm 1 and the dual-layer definition in the paper.

## Reproducibility Notes

- All random seeds are fixed for the published figures.
- Each experiment is repeated 10 times; means and 95 % confidence intervals are reported.
- The exact Docker images used in the paper are tagged `icsoc2026-artifact:v1.0`.

## Citation

```bibtex
@inproceedings{icsoc2026-shardaware,
  title     = {Reduced Transfer Messaging Using Byzantine Fault Tolerance (BFT) for Sharded Networks},
  booktitle = {International Conference on Service-Oriented Computing (ICSOC)},
  year      = {2026}
}
```

## Contact & Support

Open an issue on this repository for any reproduction problems.  
We aim to answer within 48 hours.

---

**License**: MIT  
**Artifact DOI**: (to be assigned after camera-ready)
