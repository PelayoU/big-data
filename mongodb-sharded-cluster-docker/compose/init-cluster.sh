#!/usr/bin/env bash
# =============================================================================
# init-cluster.sh — initialise the sharded cluster after `docker compose up`
# =============================================================================
# Once the containers are running, the replica sets and the cluster topology
# still need to be wired up exactly as in manual/commands.md, but using the
# in-network hostnames (config1, config2, ..., shard2_3) instead of localhost
# ports.
#
# This script:
#   1. Initialises myCS, myRS1 and myRS2 with rs.initiate().
#   2. Registers myRS1 and myRS2 as shards via sh.addShard().
#
# Usage (from this directory):
#   docker compose up -d
#   ./init-cluster.sh                   # once
#
# After this finishes, mongos is ready on host port 27027:
#   mongosh mongodb://localhost:27027
# =============================================================================
set -euo pipefail

run() {                                  # run a JS snippet in a given container
  local container="$1"; shift
  echo ">>> $container: $*"
  docker exec -i "$container" mongosh --quiet --port 27017 --eval "$*"
}

echo "Step 1/3 — initialising config-server replica set myCS..."
run config1 'rs.initiate({
  _id: "myCS",
  configsvr: true,
  members: [
    { _id: 0, host: "config1:27017" },
    { _id: 1, host: "config2:27017" },
    { _id: 2, host: "config3:27017" }
  ]
})'

echo "Step 2/3 — initialising shard replica sets myRS1 and myRS2..."
run shard1_1 'rs.initiate({
  _id: "myRS1",
  members: [
    { _id: 0, host: "shard1_1:27017" },
    { _id: 1, host: "shard1_2:27017" },
    { _id: 2, host: "shard1_3:27017" }
  ]
})'

run shard2_1 'rs.initiate({
  _id: "myRS2",
  members: [
    { _id: 0, host: "shard2_1:27017" },
    { _id: 1, host: "shard2_2:27017" },
    { _id: 2, host: "shard2_3:27017" }
  ]
})'

# Replica-set elections take a few seconds — give them room before adding the
# shards on mongos. The mongos errors out on addShard if a member is still in
# STARTUP2 / ROLLBACK.
echo "Waiting for replica sets to elect a PRIMARY..."
sleep 10

echo "Step 3/3 — registering both shards in the cluster via mongos..."
run mongos 'sh.addShard("myRS1/shard1_1:27017,shard1_2:27017,shard1_3:27017")'
run mongos 'sh.addShard("myRS2/shard2_1:27017,shard2_2:27017,shard2_3:27017")'

echo
echo "Cluster ready. sh.status():"
run mongos 'sh.status()'
