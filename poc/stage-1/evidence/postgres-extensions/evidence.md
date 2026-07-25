# PoC evidence: postgres-extensions

## Metadata

- Status: `draft`
- Owner: repository maintainer
- Reviewer: pending
- Started at (UTC): 2026-07-25
- Completed at (UTC): pending
- Repository commit: pending execution commit
- Host architecture: `aarch64`
- Target platform: `linux/amd64`
- Execution mode: `native arm64 preflight`; amd64 execution pending

## Question and acceptance criteria

Can pinned pgvector and trial `pg_textsearch` candidates coexist on PostgreSQL 18 without constraining the retriever contract or Stage 2 foundation incorrectly?

ARM64 preflight acceptance requires a reproducible image build, successful preload and extension creation, representative vector/BM25/metadata-filtered queries, expected index plans, safe invalid-input behavior, restart persistence, version discovery, and explicit cleanup. It does not satisfy the amd64 build or performance criteria.

## Pinned inputs

| Input | Version, digest, or revision | Source | Integrity verification |
| --- | --- | --- | --- |
| PostgreSQL | 18 candidate pending | official PostgreSQL image lineage | digest pending |
| pgvector | candidate pending verification | official pgvector repository | signed/tag commit pending |
| `pg_textsearch` | candidate pending verification | official Timescale repository | release artifact or tag checksum pending |

Do not include credentials or secret values.

## Fixture

- Classification: synthetic
- Generator revision and seed: pending
- Record count: target 100–1,000
- SHA-256: pending
- Coverage notes: contract is defined in `fixtures/README.md`

## Reproduction

Pending standalone ARM64 sidecar implementation. Follow `ARM64-SIDECAR-HANDOFF.md`; do not edit the DevContainer for the first run.

## Observations

### Functional results

| Check | Expected | Observed | Pass |
| --- | --- | --- | --- |
| Host/target distinction | ARM64 evidence is labelled and cannot close amd64 criteria | documented | yes |
| Image build | pinned PostgreSQL 18 plus both extensions | pending | pending |
| Extension preload/create | both extensions available in one database | pending | pending |
| Retrieval coexistence | vector, BM25, and metadata filters work | pending | pending |
| Restart | data and indexes remain usable | pending | pending |
| Cleanup | no exact PoC project resources remain | pending | pending |

### Measurements

| Metric | Method | Result | Native or emulated |
| --- | --- | --- | --- |
| ARM64 build duration | monotonic wall time | pending | native arm64 |
| ARM64 image size | container image inspect | pending | native arm64 |
| Startup-to-ready | health transition | pending | native arm64 |
| Query latency | warm-up plus at least five runs | pending | native arm64, directional only |

### Cleanup verification

Pending.

## Limitations and anomalies

- No amd64 environment is currently available.
- ARM64 functional compatibility may reveal source-level issues but cannot prove the approved target image or native performance.
- Candidate versions remain unpinned until official release provenance and compatible artifacts are verified.

## Evidence references

- `../../ARM64-SIDECAR-HANDOFF.md`
- `../../fixtures/README.md`
