# PoC decision: postgres-extensions

- Outcome: `defer`
- Owner: repository maintainer
- Reviewer: pending
- Decision date (UTC): pending
- Evidence: `evidence.md`

## Decision

Stage 2 may not yet rely on a PostgreSQL extension image. Execute the ARM64 sidecar preflight first, then repeat the accepted pinned inputs on native amd64 before changing this outcome.

## Rationale

The current environment is ARM64 while the approved target is `linux/amd64`. Separating functional preflight from target acceptance avoids presenting emulated or cross-architecture measurements as production evidence.

## Constraints

- Do not promote ARM64 image digests or performance measurements.
- Keep lexical retrieval behind the retriever port.
- Do not modify or reuse application/Kestra databases, volumes, or credentials.
- `pg_textsearch` must be configured through `shared_preload_libraries`.

## Stage 2 consequences

The application PostgreSQL image, extension pins, and resource settings remain blocked pending completed ARM64 preflight and later amd64 confirmation.

## Follow-up

Verify official source revisions, implement the disposable ARM64 sidecar, execute functional tests, and retain this `defer` outcome until amd64 evidence exists.
