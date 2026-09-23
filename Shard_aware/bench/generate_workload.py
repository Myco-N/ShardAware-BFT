#!/usr/bin/env python3
"""
ICSOC 2026 Artifact – Cross-shard workload generator
Generates synthetic transactions with configurable TPS and cross-shard ratio.
"""

import argparse
import json
import random
import time
from datetime import datetime

def generate_workload(tps: int, duration: int, cross_shard_ratio: float, num_shards: int = 20):
    total_txs = tps * duration
    txs = []
    for i in range(total_txs):
        src = random.randint(0, num_shards - 1)
        if random.random() < cross_shard_ratio:
            dst = random.choice([s for s in range(num_shards) if s != src])
        else:
            dst = src
        txs.append({
            "id": i,
            "src_shard": src,
            "dst_shard": dst,
            "size_bytes": 256,
            "timestamp": datetime.utcnow().isoformat() + "Z"
        })
    return {
        "config": {
            "target_tps": tps,
            "duration_sec": duration,
            "cross_shard_ratio": cross_shard_ratio,
            "num_shards": num_shards,
            "total_transactions": total_txs
        },
        "transactions": txs
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate cross-shard workload")
    parser.add_argument("--tps", type=int, default=20000)
    parser.add_argument("--duration", type=int, default=120)
    parser.add_argument("--cross-shard-ratio", type=float, default=0.4)
    parser.add_argument("--shards", type=int, default=20)
    parser.add_argument("--output", type=str, default="results/workload.json")
    args = parser.parse_args()

    print(f"Generating {args.tps} TPS × {args.duration}s workload "
          f"(cross-shard ratio={args.cross_shard_ratio})...")
    data = generate_workload(args.tps, args.duration, args.cross_shard_ratio, args.shards)
    with open(args.output, "w") as f:
        json.dump(data, f, indent=2)
    print(f"Wrote {len(data['transactions'])} transactions → {args.output}")
