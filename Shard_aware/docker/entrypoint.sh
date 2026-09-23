#!/bin/bash
set -e
# Start Tendermint + Shard-Aware router sidecar
tendermint init --home /tendermint 2>/dev/null || true
shard-router --shard-id ${SHARD_ID:-0} --validators ${VALIDATORS:-15} &
exec tendermint node --home /tendermint --proxy_app=kvstore
