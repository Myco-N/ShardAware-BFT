# Protocol Specification (ICSOC 2026)

This document mirrors Algorithm 1 and the dual-layer definition in the paper.

## VRF Leader Election

```
For each validator i:
  Pi = Si / Stotal
  (πi, yi) ← VRF_ski (H ‖ σs)
  Vi = Pi × yi
Leader = argmax Vi
Standby = second-highest Vi
```

## Dual-Layer Failover

- Hot-standby continuously shadows primary.
- After k missed heartbeats: promote standby within Δ_timeout.
- If both fail: committee of 2f+1 runs view-change; completes in ≤ 2δ.
- Bound: T_failover = Δ_timeout + 2δ.

## Cross-Shard Message Authenticity

Every inter-shard message carries a 2f+1 threshold signature from the source shard committee.  
A single corrupted representative cannot forge a valid state proof.
