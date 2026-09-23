#!/usr/bin/env bash
set -euo pipefail

# ICSOC 2026 Artifact – One-click reproduction script
# Usage: ./reproduce.sh [--nodes N] [--shards S] [--tps T] [--collect-only]

NODES=300
SHARDS=20
TPS=20000
COLLECT_ONLY=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --nodes) NODES="$2"; shift 2 ;;
    --shards) SHARDS="$2"; shift 2 ;;
    --tps) TPS="$2"; shift 2 ;;
    --collect-only) COLLECT_ONLY=true; shift ;;
    *) echo "Unknown option $1"; exit 1 ;;
  esac
done

echo "============================================================"
echo " ICSOC 2026 Artifact Reproduction"
echo " Nodes: $NODES | Shards: $SHARDS | Target TPS: $TPS"
echo "============================================================"

if [ "$COLLECT_ONLY" = false ]; then
  echo "[1/6] Checking prerequisites..."
  command -v docker >/dev/null 2>&1 || { echo "Docker required"; exit 1; }
  command -v terraform >/dev/null 2>&1 || echo "Warning: Terraform not found – skipping cloud provision"

  echo "[2/6] Building Docker images..."
  docker build -t icsoc2026-artifact:v1.0 -f docker/Dockerfile .

  echo "[3/6] Launching $NODES-node testbed with $SHARDS shards..."
  ./docker/launch_testbed.sh --nodes "$NODES" --shards "$SHARDS"

  echo "[4/6] Applying network latency emulation (10–100 ms)..."
  ./netem/apply_latency.sh --min 10 --max 100

  echo "[5/6] Injecting cross-shard workload at $TPS TPS..."
  python3 bench/generate_workload.py --tps "$TPS" --duration 120 --cross-shard-ratio 0.4 --output results/workload.json
  go run bench/inject_tps.go --target "$TPS" --shards "$SHARDS" --duration 120 || true
fi

echo "[6/6] Collecting metrics and regenerating figures..."
mkdir -p results figures
python3 bench/parse_results.py --input results/ --output results/summary.csv
python3 bench/plot_figures.py --csv results/summary.csv --outdir figures/

echo "============================================================"
echo " Reproduction complete."
echo " Results  → results/"
echo " Figures  → figures/"
echo "============================================================"
