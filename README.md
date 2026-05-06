# Big Data

A portfolio of **big-data engineering projects** covering the analytical stack a financial-services data team relies on: Oracle relational design and analytical SQL, Oracle data-warehousing patterns over a music-industry dataset, MongoDB sharded clusters with both manual and Compose-based deployment, Hadoop dual-stack analytics with Pig and Hive, and a Linked Open Data pipeline combining SPARQL, REST APIs, OpenRefine and Wikidata.

The work was developed during my **MSc in Financial Sector Technologies (UC3M)**.

---

## Project index

### Relational design and analytical SQL

| Project | Stack | Focus |
| :--- | :--- | :--- |
| **[Oracle SQL — Melomaniacs Concert-Management DB](./oracle-sql-melomaniacs-concert-db)** | Oracle 12c · PL/SQL | DDL design (floristry catalogue with self-referencing FKs and multi-column CHECKs) + 10 advanced analytical queries on a 12-table concert-management schema: `NOT EXISTS`, double `NOT EXISTS`, self-joins on temporal intervals, multi-CTE aggregations, `FETCH FIRST … ROWS WITH TIES` and more. |

### Data warehousing

| Project | Stack | Focus |
| :--- | :--- | :--- |
| **[Oracle Music Data Warehouse](./oracle-music-data-warehouse)** | Oracle 12c · SQL window functions | Staging layer + four analytical views over a 21,561-row album catalogue: release cadence with `LAG()` + `MONTHS_BETWEEN`, manager share of yearly publications, manager↔publisher cross-share via three CTEs, and album/track context with correlated subqueries. |

### Distributed databases

| Project | Stack | Focus |
| :--- | :--- | :--- |
| **[MongoDB Sharded Cluster — Docker](./mongodb-sharded-cluster-docker)** | MongoDB 7 · Docker Compose | Two-stage build: (1) **manual** `mongod` cluster — 9 nodes + 1 `mongos`, replica set bootstrap, range-key sharding, three failure scenarios (split-brain prevention, majority elections); (2) **Docker Compose** evolution with base + dev + prod overlays (keyfile auth, port isolation), turnkey via `docker compose up` + an `init-cluster.sh` helper. |

### Hadoop analytics

| Project | Stack | Focus |
| :--- | :--- | :--- |
| **[Hadoop Publishing Analytics — Pig vs Hive](./hadoop-publishing-analytics-pig-hive)** | HDFS · Pig Latin · HiveQL · MapReduce | Same four analytical queries (filter, count, group-by, join) implemented twice — once in Pig, once in Hive — over the same CSV dataset. Side-by-side comparison of imperative dataflow vs declarative SQL on the same execution engine. |

### Linked Open Data and semantic integration

| Project | Stack | Focus |
| :--- | :--- | :--- |
| **[Linked Open Data Pipeline — Nobel Laureates in Physics](./linked-open-data-nobel-physics-pipeline)** | SPARQL · DBpedia · Nobel Prize REST API · OpenRefine · GREL · Wikidata | End-to-end LOD pipeline: SPARQL acquisition from DBpedia, REST acquisition from the Nobel Prize API, OpenRefine integration via fingerprint join keys + `cross()`, reconciliation against Wikidata `Q5`, and enrichment with six Wikidata properties (educated at, employer, field of work…). The same shape used in production for KYC / counterparty / instrument-reference enrichment. |

---

## Areas of focus

- **Analytical SQL on Oracle** — window functions, CTEs, correlated subqueries, `FETCH FIRST WITH TIES`, virtual columns, `NOT EXISTS` patterns.
- **Relational design** — DDL with multi-column constraints, self-referencing FKs, ON DELETE rules (CASCADE / SET NULL), `CHECK` constraints encoding business rules.
- **Distributed databases** — replica sets, quorum, split-brain prevention, range-based sharding, `mongos` routing, multi-environment Docker deployments.
- **Hadoop ecosystem** — HDFS staging, Pig Latin dataflow, HiveQL on a managed metastore, MapReduce as the common compute substrate, Pig vs Hive trade-offs.
- **Linked Open Data** — SPARQL on DBpedia / Wikidata, OPTIONAL-driven graph traversal, OpenRefine `cross()` integration, fingerprint clustering, Wikidata reconciliation and enrichment.

---

## Author

**Pelayo Urzaiz**

- BSc in Applied Statistics — Universidad Complutense de Madrid (UCM)
- MSc in Financial Technologies (FinTech) — Universidad Carlos III de Madrid (UC3M)
- MSc in Quantitative Finance — Universidad Nacional de Educación a Distancia (UNED)

[LinkedIn Profile](https://www.linkedin.com/in/pelayourzaiz/)
