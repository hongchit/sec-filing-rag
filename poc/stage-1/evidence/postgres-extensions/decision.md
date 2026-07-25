# PoC decision: postgres-extensions

- Outcome: `constrain`
- Owner: repository maintainer
- Reviewer: pending
- Decision date (UTC): 2026-07-25
- Evidence: `evidence.md`

## Decision

Stage 2 may rely provisionally on PostgreSQL 18.4, pgvector 0.8.2, and
`pg_textsearch` 1.2.0 for functional architecture planning. Native ARM64 is a
validated and acceptable deployment option. In the absence of an amd64
environment, source-level amd64 compatibility is assumed from the successful
ARM64 run, but remains explicitly unmeasured.

## Rationale

The current environment is ARM64 and ARM64 is now permitted as a deployment
architecture. The run proved source/package compatibility, preload, extension
coexistence, representative retrieval, expected plans, restart persistence, and
cleanup. The owner accepts this as sufficient functional evidence for the
current milestone while retaining architecture-specific evidence labels.

## Constraints

- Do not represent ARM64 image digests or performance measurements as amd64 measurements.
- Build architecture-specific images and verify the resolved package checksum for each architecture before deployment.
- Keep lexical retrieval behind the retriever port.
- Do not modify or reuse application/Kestra databases, volumes, or credentials.
- `pg_textsearch` must be configured through `shared_preload_libraries`.

## Stage 2 consequences

The extension versions and PostgreSQL lineage may inform Stage 2. Image digests
remain architecture-specific, and resource settings remain provisional until
the Stage 1 resource-envelope PoC runs on the selected deployment host.

## Follow-up

Stage 1.2 is closed by owner decision. Capture the missing memory and index-size
measurements in the combined Stage 1.7 resource envelope before approving a
Stage 2 node size. If amd64 becomes the selected deployment host, verify the official PG18
amd64 `pg_textsearch` artifact and resolved image digest during image delivery;
this is a portability confirmation rather than a blocker to the current ARM64
functional milestone.
