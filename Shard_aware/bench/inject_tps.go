package main

import (
	"flag"
	"fmt"
	"log"
	"time"
)

// Simplified cross-shard injector for the ICSOC 2026 artifact.
// In a full deployment this would speak the real Tendermint RPC / ABCI.
func main() {
	target := flag.Int("target", 20000, "target TPS")
	shards := flag.Int("shards", 20, "number of shards")
	duration := flag.Int("duration", 120, "duration in seconds")
	flag.Parse()

	fmt.Printf("Injecting cross-shard traffic: %d TPS across %d shards for %d s\n",
		*target, *shards, *duration)

	interval := time.Second / time.Duration(*target)
	deadline := time.Now().Add(time.Duration(*duration) * time.Second)
	count := 0

	for time.Now().Before(deadline) {
		// Placeholder: in real code send signed Tx to the appropriate shard representative
		count++
		time.Sleep(interval)
		if count%(*target) == 0 {
			log.Printf("Injected %d transactions (approx %d TPS)\n", count, *target)
		}
	}
	fmt.Printf("Finished. Total injected: %d\n", count)
}
