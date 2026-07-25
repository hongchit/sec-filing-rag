# PoC evidence: postgres-extensions

## Metadata

- Status: `functional compatibility milestone accepted with architecture constraint`
- Owner: repository maintainer
- Reviewer: pending
- Started at (UTC): 2026-07-25
- Completed at (UTC): 2026-07-25T20:36:37Z (ARM64 preflight only)
- Repository base commit: `1ee7772ff344ee2d530eb83af93b423d6efd48e7`
- Evidence state: implementation and evidence changes are uncommitted
- Host architecture: `aarch64`
- Deployment platforms: `linux/arm64` validated; `linux/amd64` provisionally assumed compatible
- Execution mode: `native arm64`; amd64 not measured

## Question and acceptance criteria

Can pinned pgvector and trial `pg_textsearch` candidates coexist on PostgreSQL 18 without constraining the retriever contract or Stage 2 foundation incorrectly?

Functional acceptance requires a reproducible image build, successful preload and extension creation, representative vector/BM25/metadata-filtered queries, expected index plans, safe invalid-input behavior, restart persistence, version discovery, and explicit cleanup. Native ARM64 passed these criteria. By owner decision, this is sufficient to provisionally assume source-level amd64 compatibility because ARM64 is itself an acceptable deployment architecture; no ARM64 measurement is represented as amd64 evidence.

## Pinned inputs

| Input | Version, digest, or revision | Source | Integrity verification |
| --- | --- | --- | --- |
| PostgreSQL | 18.4, `postgres:18.4-trixie@sha256:3a82e1f56c8f0f5616a11103ac3d47e632c3938698946a7ad26da0df1334744a` | official PostgreSQL image | manifest digest pinned; runtime reported PostgreSQL 18.4 and `linux/arm64` |
| pgvector | 0.8.2, tag commit `cab9da72c04353f143bb06b42ab70a403daac64a` | official pgvector repository | source archive SHA-256 `69f4019389af05dc1c9548deb8628e62878e6e207c03907f2b8af2016472cdaa` verified during build |
| `pg_textsearch` | 1.2.0, tag commit `4e0228844a8a65838ad3b3bfa85f86df2f21e59c` | official Timescale repository release | PG18 ARM64 package ZIP SHA-256 `5e889c5cb0f3ef9125e1cb09fd51a0944ca2bbcea2a08182ff5c048b20a7a8aa` verified during build |

Do not include credentials or secret values.

## Fixture

- Classification: synthetic
- Generator revision and seed: `postgres-extensions/tests/generate-fixture.sh`; seed `20260725`
- Record count: 120 JSON Lines records
- SHA-256: `5f541b2cb4cf2c01dbbcc5880a486e756b6814591ef7e269b4fcaf9993d8b32b`
- Coverage notes: four companies, three fiscal years, 10-K and 10-Q forms, two items, exact financial terms, semantic paraphrases, repeated-looking passages, punctuation, Unicode, unmatched-filter capability, and deterministic 3-dimensional vectors

## Reproduction

All commands ran from the repository root against the host Docker engine. The
existing DevContainer Compose file, services, databases, credentials, networks,
and volumes were not used or modified.

The ignored `.env.local` was created from `.env.example` with mode `0600`, its
example password was replaced by a random 64-hex-character PoC-only value, and
the file was deleted after cleanup verification. No credential value was
captured in this evidence. `.dockerignore` limits the image build context to the
Dockerfile in the final harness, so `.env.local` cannot enter future build
contexts.

```sh
docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  config --quiet

/usr/bin/time -p docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  build --pull

/usr/bin/time -p docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  up -d --wait

docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  exec -T postgres sh /poc/tests/run-tests.sh

docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  restart --timeout 30

docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  up -d --wait

docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  exec -T postgres psql -X -v ON_ERROR_STOP=1 \
  -U sec_filing_poc -d sec_filing_poc \
  -f /poc/tests/02-persistence.sql

docker compose \
  --project-name sec-filing-rag-poc-postgres-arm64 \
  --env-file poc/stage-1/postgres-extensions/.env.local \
  -f poc/stage-1/postgres-extensions/compose.arm64.yml \
  down --volumes --remove-orphans
```

## Observations

### Functional results

| Check | Expected | Observed | Pass |
| --- | --- | --- | --- |
| Architecture distinction | ARM64 is validated; amd64 compatibility is an explicit unmeasured assumption | documented | yes |
| Image build | pinned PostgreSQL 18 plus both extensions | image `sha256:f49bc1d9f1aef220d2644b963dbd47b90037f844a2264d31c2303e2d32d1b693`; both downloaded inputs passed SHA-256 checks | yes |
| Runtime architecture | native `linux/arm64` | image inspect reported `linux/arm64`; container reported `aarch64` | yes |
| Extension preload/create | both extensions available in one database | `shared_preload_libraries=pg_textsearch`; `pg_textsearch 1.2.0`; `vector 0.8.2` | yes |
| Retrieval coexistence | vector, BM25, and metadata filters work | standalone vector and BM25 queries, metadata-filtered BM25, and combined reciprocal-rank vector/BM25 query returned expected rows | yes |
| Expected index plans | HNSW, BM25, and B-tree indexes are selectable | forced-plan checks used `filing_chunks_embedding_hnsw`, `filing_chunks_source_text_bm25`, and `filing_chunks_metadata` | yes |
| Invalid input | unsafe inputs fail without corrupting the service | vector dimension mismatch failed with `different vector dimensions 2 and 3`; missing BM25 index failed with `index "missing_index" does not exist` | yes |
| Restart | data and indexes remain usable | after Compose restart: 120 rows, preload setting, all three indexes, vector result `fixture-095`, and BM25 result `fixture-011` persisted | yes |
| Network isolation | no host port and only the dedicated network | inspect showed `5432/tcp: null` and only `sec-filing-rag-poc-postgres-arm64_postgres-net` | yes |
| Cleanup | no exact PoC project resources remain | dedicated container, volume, and network removed; label-filtered container/volume/network listings returned no rows | yes |

### Measurements

| Metric | Method | Result | Native or emulated |
| --- | --- | --- | --- |
| ARM64 build duration | `/usr/bin/time -p ... build --pull` | 52.46 s wall time | native arm64 |
| ARM64 image size | `docker image inspect .Size` | 489,003,119 bytes (466.35 MiB) | native arm64 |
| Startup-to-ready | `/usr/bin/time -p ... up -d --wait` | 6.44 s wall time | native arm64 |
| BM25 query execution | five warm runs using `EXPLAIN (ANALYZE, FORMAT JSON)` | 0.420, 0.414, 0.413, 0.481, 0.329 ms; mean 0.411 ms; max 0.481 ms | native arm64, 120-row synthetic fixture, directional only |

### Cleanup verification

`docker compose down --volumes --remove-orphans` explicitly removed:

- container `sec-filing-rag-poc-postgres-arm64-postgres-1`
- volume `sec-filing-rag-poc-postgres-arm64_postgres-data`
- network `sec-filing-rag-poc-postgres-arm64_postgres-net`

The following label-filtered commands returned no rows:

```sh
docker ps -a \
  --filter label=com.docker.compose.project=sec-filing-rag-poc-postgres-arm64
docker volume ls \
  --filter label=com.docker.compose.project=sec-filing-rag-poc-postgres-arm64
docker network ls \
  --filter label=com.docker.compose.project=sec-filing-rag-poc-postgres-arm64
```

The local image was retained to support review/reproduction; it is not a
Compose volume, network, container, credential, or application resource.

## Limitations and anomalies

- No amd64 environment is currently available; amd64 compatibility is provisionally assumed rather than measured.
- ARM64 is an acceptable deployment architecture and is the only architecture validated by this run.
- PostgreSQL's multi-platform manifest digest was verified on ARM64 only. The
  native amd64 run must verify the resolved amd64 image manifest and use the
  official pg_textsearch PG18 amd64 artifact/checksum.
- The first persistence assertion used `GROUP BY true`, which PostgreSQL 18
  rejected with `non-integer constant in GROUP BY`. The test was corrected to
  compare a direct `count(*)` with 3; no database or extension fault occurred,
  and the corrected persistence test passed against the already-restarted data.
- The 120-row latency sample is too small for performance acceptance. No ARM64
  timing or image digest may be represented as measured amd64 evidence.

## Evidence references

- `../../ARM64-SIDECAR-HANDOFF.md`
- `../../fixtures/README.md`
- `../../postgres-extensions/README.md`
- `../../postgres-extensions/Dockerfile`
- `../../postgres-extensions/compose.arm64.yml`
