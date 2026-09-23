#!/usr/bin/env bash
# Apply uniform random latency between $MIN and $MAX ms on the Docker bridge
# using Linux traffic control (tc). Requires root or CAP_NET_ADMIN.

set -euo pipefail

MIN=10
MAX=100

while [[ $# -gt 0 ]]; do
  case $1 in
    --min) MIN="$2"; shift 2 ;;
    --max) MAX="$2"; shift 2 ;;
    *) echo "Usage: $0 [--min MS] [--max MS]"; exit 1 ;;
  esac
done

echo "Applying network emulation: uniform ${MIN}–${MAX} ms latency"

# Example for the default Docker bridge; adapt interface name as needed
IFACE=${IFACE:-docker0}

# Clear previous rules
tc qdisc del dev "$IFACE" root 2>/dev/null || true

# Hierarchical Token Bucket + netem
tc qdisc add dev "$IFACE" root handle 1: htb default 1
tc class add dev "$IFACE" parent 1: classid 1:1 htb rate 1gbit
tc qdisc add dev "$IFACE" parent 1:1 handle 10: netem delay ${MIN}ms ${MAX}ms distribution uniform

echo "Latency emulation active on $IFACE (${MIN}–${MAX} ms uniform)."
echo "To remove: tc qdisc del dev $IFACE root"
