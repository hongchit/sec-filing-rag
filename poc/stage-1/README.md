# Stage 1 pre-foundation PoCs

This directory contains disposable proofs used to decide the Stage 2 foundation. It is not a source of production manifests, credentials, or application data.

## Fixed scope

- Target platform: `linux/amd64`
- Allowed data: synthetic or public, non-production filing excerpts
- Decision outcomes: `accept`, `constrain`, `replace`, or `defer`
- Evidence: reproducible commands plus reviewed summaries; raw generated output stays local
- Performance: native amd64 measurements are authoritative; emulated measurements are labelled and directional only

The current development host may use another architecture. Image builds must always declare `--platform linux/amd64`. A PoC executed through emulation can prove build and functional compatibility, but it cannot establish the Stage 2 resource envelope or production latency.

## Layout

```text
poc/stage-1/
├── evidence/       reviewed evidence and decisions
├── fixtures/       public or synthetic fixture definitions
├── raw/            ignored generated measurements
├── scripts/        harness validation and later PoC entry points
├── templates/      evidence and decision templates
└── scope.conf      non-secret, machine-readable scope
```

Each PoC receives a stable identifier such as `postgres-extensions`. Its reviewed evidence is stored at `evidence/<id>/evidence.md` with a decision at `evidence/<id>/decision.md`.

## Measurement protocol

1. Record the Git commit, UTC start time, host and target architecture, container engine/buildx versions, pinned image and source revisions, and whether execution is native or emulated.
2. Start from newly created PoC resources with a unique project prefix beginning `sec-filing-rag-poc-`.
3. Record build duration, image size, startup-to-ready duration, peak and steady-state CPU/memory, persistent/index size, and operation-specific latency.
4. Run functional checks before performance checks. For repeatable queries, use one untimed warm-up followed by at least five measured executions and report median, minimum, and maximum.
5. Capture query plans and correctness evidence separately from latency. Performance measurements are engineering evidence, not an MVP service-level objective.
6. Stop and remove PoC containers, networks, and volumes after evidence capture; record the cleanup verification.

Use monotonic elapsed-time tools where available. Record exact commands rather than manually reconstructed instructions.

## Isolation and safety

- Never use the root `.env`, production-like credentials, operational SEC contact identities, provider keys, or user data.
- Bind services to loopback only when a host port is necessary; prefer no published ports.
- Use dedicated containers, networks, volumes, database names, and generated local-only credentials.
- Do not mount the Docker socket into PoC workloads.
- Do not promote a PoC Compose file or container directly into Stage 2; reproduce accepted decisions in reviewed foundation assets.
- Cleanup commands must target the explicit `sec-filing-rag-poc-` prefix and must not use broad globs or unresolved variables.

Run `poc/stage-1/scripts/validate-harness.sh` before and after adding a PoC.

## Evidence lifecycle

Copy the templates for each PoC. A decision is valid only when its evidence identifies pinned inputs, commands, observed results, limitations, owner, reviewer, and an outcome. Failed experiments remain useful evidence and are not rewritten as passes.
