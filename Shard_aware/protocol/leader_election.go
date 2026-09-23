package protocol

import (
	"crypto/sha256"
	"encoding/binary"
	"fmt"
	"math/big"
)

// VRF + stake-weighted leader election (Algorithm 1 in the paper)
type Validator struct {
	ID    int
	Stake uint64
	// In real code: private key for VRF
}

func ElectLeader(validators []Validator, prevHash []byte, seed []byte) (primary, standby int) {
	totalStake := uint64(0)
	for _, v := range validators {
		totalStake += v.Stake
	}

	type scored struct {
		idx   int
		score *big.Float
	}
	scores := make([]scored, len(validators))

	for i, v := range validators {
		// Probability Pi = Si / Stotal
		p := new(big.Float).Quo(
			new(big.Float).SetUint64(v.Stake),
			new(big.Float).SetUint64(totalStake),
		)

		// Simulated VRF output (replace with real VRF in production)
		h := sha256.Sum256(append(append(prevHash, seed...), byte(v.ID)))
		vrf := new(big.Float).SetInt(new(big.Int).SetBytes(h[:8]))

		score := new(big.Float).Mul(p, vrf)
		scores[i] = scored{i, score}
	}

	// Select highest and second-highest
	max1, max2 := -1, -1
	var s1, s2 *big.Float
	for _, sc := range scores {
		if s1 == nil || sc.score.Cmp(s1) > 0 {
			s2, max2 = s1, max1
			s1, max1 = sc.score, sc.idx
		} else if s2 == nil || sc.score.Cmp(s2) > 0 {
			s2, max2 = sc.score, sc.idx
		}
	}
	return max1, max2
}

func main() {
	// Demo
	vals := []Validator{{0, 100}, {1, 200}, {2, 150}}
	p, s := ElectLeader(vals, []byte("prev"), []byte("seed"))
	fmt.Printf("Primary=%d Standby=%d\n", p, s)
	_ = binary.Size
}
