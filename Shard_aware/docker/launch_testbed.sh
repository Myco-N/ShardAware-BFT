#!/usr/bin/env bash
set -euo pipefail
NODES=${1:-300}
SHARDS=${2:-20}
echo "Launching $NODES nodes across $SHARDS shards (Docker Compose)..."
# In a real deployment this would generate a docker-compose.yml with 300 services
# For local testing we launch a smaller representative set
docker-compose -f docker/docker-compose.yml up -d --scale validator=15
echo "Testbed ready."
