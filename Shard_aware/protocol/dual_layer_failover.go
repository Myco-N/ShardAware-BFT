package protocol

import (
	"time"
)

// Dual-layer fault tolerance (hot-standby + committee view-change)
// Matches Definition and Algorithm 1 of the paper.

const (
	DefaultTimeout = 3 * time.Second // Δ_timeout = 3δ after GST
	NetworkDelay   = 50 * time.Millisecond
)

type RepresentativeState int

const (
	Primary RepresentativeState = iota
	HotStandby
	Failed
)

type ShardRepresentative struct {
	ID        int
	State     RepresentativeState
	LastBeat  time.Time
	Committee []int // 2f+1 validators
}

func (r *ShardRepresentative) Heartbeat() {
	r.LastBeat = time.Now()
}

func (r *ShardRepresentative) MissedHeartbeats(k int, interval time.Duration) bool {
	return time.Since(r.LastBeat) > time.Duration(k)*interval
}

// PromoteStandby implements the hot-standby takeover.
// Returns the bound T_failover = Δ_timeout + 2δ
func PromoteStandby(primary, standby *ShardRepresentative) time.Duration {
	primary.State = Failed
	standby.State = Primary
	standby.LastBeat = time.Now()
	return DefaultTimeout + 2*NetworkDelay
}

// CommitteeViewChange elects a new primary when both primary and standby fail.
func CommitteeViewChange(committee []int) int {
	// Simplified: majority vote among 2f+1
	// Real implementation uses threshold signatures
	if len(committee) == 0 {
		return -1
	}
	return committee[0] // placeholder
}
