# Manual sharded-cluster commands

Step-by-step commands to bring up the cluster **without Docker Compose**: each `mongod` process is run in its own terminal, then the replica sets are initialised, then the cluster is registered with the `mongos` router.

This is the workflow used in the original practice (UC3M Tema 7 — MongoDB Sharding). The Docker Compose evolution lives in [`../compose/`](../compose/) and produces an equivalent topology in a single `docker-compose up`.

---

## Topology

| Component | Replica set | Member ports |
|---|---|---|
| Shard 1 | `myRS1` | `27018`, `27019`, `27020` |
| Shard 2 | `myRS2` | `27021`, `27022`, `27023` |
| Config server | `myCS` | `27024`, `27025`, `27026` |
| Query router | — | `mongos` on `27027` |

Total: **9 `mongod` processes + 1 `mongos`**.

---

## Step 1 — Start every node

One terminal per node. Each `mongod` keeps running until you stop it (`Ctrl+C`).

```bash
# Shard 1
mongod --port 27018 --dbpath data/db1 --replSet myRS1 --bind_ip_all --shardsvr
mongod --port 27019 --dbpath data/db2 --replSet myRS1 --bind_ip_all --shardsvr
mongod --port 27020 --dbpath data/db3 --replSet myRS1 --bind_ip_all --shardsvr

# Shard 2
mongod --port 27021 --dbpath data/db4 --replSet myRS2 --bind_ip_all --shardsvr
mongod --port 27022 --dbpath data/db5 --replSet myRS2 --bind_ip_all --shardsvr
mongod --port 27023 --dbpath data/db6 --replSet myRS2 --bind_ip_all --shardsvr

# Config server replica set
mongod --port 27024 --dbpath data/db7 --replSet myCS --bind_ip_all --configsvr
mongod --port 27025 --dbpath data/db8 --replSet myCS --bind_ip_all --configsvr
mongod --port 27026 --dbpath data/db9 --replSet myCS --bind_ip_all --configsvr
```

Each `dbpath` directory must exist beforehand (`mkdir -p data/db{1..9}`).

`mongod --replSet` boots each node *prepared to join* a replica set; the actual replica set is created in the next step with `rs.initiate()`.

---

## Step 2 — Initialise the replica sets

### Shard 1 — `myRS1`

```bash
mongosh --port 27018
```

```js
rs.initiate({
  _id: "myRS1",
  members: [
    { _id: 0, host: "localhost:27018" },
    { _id: 1, host: "localhost:27019" },
    { _id: 2, host: "localhost:27020" }
  ]
})
rs.status()
```

Expected: one `PRIMARY` (whichever node initiated; in the practice run, `27018`) plus two `SECONDARY`s.

### Shard 2 — `myRS2`

```bash
mongosh --port 27021
```

```js
rs.initiate({
  _id: "myRS2",
  members: [
    { _id: 0, host: "localhost:27021" },
    { _id: 1, host: "localhost:27022" },
    { _id: 2, host: "localhost:27023" }
  ]
})
rs.status()
```

### Config server replica set — `myCS`

The config server replica set does **not** hold user data; it stores the cluster's metadata so the `mongos` router knows which shard owns each chunk.

```bash
mongosh --port 27024
```

```js
rs.initiate({
  _id: "myCS",
  configsvr: true,
  members: [
    { _id: 0, host: "localhost:27024" },
    { _id: 1, host: "localhost:27025" },
    { _id: 2, host: "localhost:27026" }
  ]
})
rs.status()
```

---

## Step 3 — Start the query router (`mongos`)

```bash
mongos --port 27027 \
       --bind_ip_all \
       --configdb myCS/localhost:27024,localhost:27025,localhost:27026
```

Open a `mongosh` against the router:

```bash
mongosh --port 27027
```

The prompt must read `[direct: mongos]` — that's the indicator that the client is hitting the router, not a single shard.

---

## Step 4 — Register the shards in the cluster

Replica sets exist (`rs.initiate`), and the router exists, but the cluster does not yet know they should be used as shards. Register each replica set with `sh.addShard()`:

```js
sh.addShard("myRS1/localhost:27018,localhost:27019,localhost:27020")
sh.addShard("myRS2/localhost:27021,localhost:27022,localhost:27023")

sh.status()
```

After this, `sh.status()` lists both shards as `state: 1` (active). The balancer is enabled but reports `currently enabled: no` until the cluster has any sharded data to balance.

---

## Step 5 — Enable sharding on a database

```js
use tiny
sh.enableSharding("tiny")
```

The chosen primary shard is shown by `sh.status()`. In this practice, MongoDB picked `myRS2` as the primary for `tiny`.

---

## Step 6 — Shard a collection by range key

The shard key for the `tiny.coffee` collection is `Address.Country` (range-based, not hashed) — chunks are split alphabetically by country.

```js
sh.shardCollection("tiny.coffee", { "Address.Country": 1 })
```

The router replies `{ ok: 1 }` and starts using the new shard key for routing.

---

## Step 7 — Bulk import

Importing through the router (`--port 27027`) means the shard key is honoured automatically — every document lands on the right shard:

```bash
mongoimport --port 27027 \
            --db tiny \
            --collection coffee \
            --type json --legacy \
            --file ~/Desktop/orders.json
```

A successful run reports `1287 document(s) imported successfully`. With ~24 MB of data and the default 64 MB chunk size, all data fits in a single chunk, so the cluster keeps **100 % of the documents on `myRS2`** (the primary shard for `tiny`). No splits, no balancing — that's expected; splits start when chunks pass the size threshold.

---

## Step 8 — Sample queries

```js
// Documents from a specific country
db.coffee.find({ "Address.Country": "Spain" })

// Aggregated count by country
db.coffee.aggregate([
  { $group: { _id: "$Address.Country", n: { $sum: 1 } } },
  { $sort: { n: -1 } }
])
```

Spain in this dataset has 19 documents.

---

## Step 9 — Failure scenarios

The practice exercises three different failure modes against the live cluster.

### Case 1 — A SECONDARY drops

`Ctrl+C` one of the SECONDARY nodes (e.g. `myRS2:27022`). Reconnect to the surviving PRIMARY and check status:

```bash
mongosh --port 27021
```

```js
rs.status()
```

The dropped member shows `(not reachable/healthy)`. **Reads and writes continue normally** through the router because the replica set still has a quorum (PRIMARY + 1 SECONDARY = 2 of 3). `db.coffee.countDocuments()` keeps returning the expected number.

### Case 2 — PRIMARY drops, no majority

Stop the PRIMARY and a SECONDARY in the same shard, leaving only one node alive. Without a majority (1 of 3 < 2 of 3), the surviving node **cannot be elected** and no new PRIMARY emerges. This is the deliberate split-brain prevention rule of replica sets.

Consequences:
- No writes accepted (no PRIMARY).
- Reads against that shard fail by default (`MongoServerSelectionError`) — there is no member willing to serve them under default read preference.

### Case 3 — PRIMARY drops, majority survives

Bring the third node back up so the shard has at least two healthy members. Now stop the current PRIMARY (e.g. `myRS2:27023`). The surviving two nodes form a majority; one of them is **automatically promoted to PRIMARY** through the standard election protocol. Writes resume on the new PRIMARY.

The takeaway is the same as in any production deployment: a replica set survives the loss of `floor(n/2)` members; the loss of `ceil(n/2)+1` members costs availability deliberately, in exchange for never serving a partitioned write.

---

## Tear-down

```bash
# In each mongod / mongos terminal:
Ctrl+C

# Wipe the data directories if you want a clean slate:
rm -rf data/db{1..9}
```

If you want a turnkey, repeatable equivalent of this whole document, see the Docker Compose evolution under [`../compose/`](../compose/).
