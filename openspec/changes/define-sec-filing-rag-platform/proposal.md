## Why

Analysts need a secure, reproducible way to ask questions about SEC filings and receive source-grounded answers without operating retrieval, ingestion, model, or workflow infrastructure directly. Establishing the product and architecture specifications before implementation keeps the greenfield system modular, constrains cost and public exposure, and makes each delivery stage independently verifiable.

## What Changes

- Introduce a public, Google-authenticated web application for querying supported SEC filings with grounded answers, citations, source passages, history, usage, and feedback.
- Introduce role-based access for `user` and `admin`, enforced at the FastAPI boundary.
- Introduce versioned corpora for selected Form 10-K sections with traceable filing-to-chunk lineage.
- Introduce direct RAG with interchangeable PostgreSQL BM25, pgvector, and deterministic hybrid retrievers.
- Introduce durable, deduplicated ingestion jobs orchestrated by Kestra, including scheduled and on-demand ingestion, persistent progress, retries, and automatic pending-query continuation.
- Introduce immutable experiment, configuration-version, evaluation, usage, cost, quota, and budget records.
- Introduce a centralized AI gateway through which all billable model operations pass.
- Start with OpenAI generation and embeddings, then support controlled comparison with pinned CPU-local sentence-transformers embedding pipelines.
- Introduce a Tailwind CSS interface centered on asking questions, monitoring ingestion, and comparing results, with advanced controls hidden by default.
- Introduce a separate administrative experience for ingestion, jobs, models, budgets, users, and operational status.
- Introduce strict input validation and normalization, output encoding, safe outbound-request policies, least-privilege service access, sensitive-data redaction, abuse controls, idempotency, and transactional concurrency enforcement.
- Deliver the platform incrementally through bounded implementation changes, beginning with a disposable pre-foundation proof-of-concept gate, then a K3s deployment foundation, authenticated RAG skeleton, ingestion, retrieval comparison, evaluation and governance, corpus expansion, and optional agentic execution.

## Capabilities

### New Capabilities

- `platform-deployment`: K3s topology, service isolation, persistence, health checks, TLS ingress, immutable images, CI/CD, smoke tests, and rollback.
- `identity-and-access`: Google login, verified application identity, two-role authorization, session security, administrative separation, and user data isolation.
- `filing-corpus`: Company and filing resolution, selected 10-K sections, versioned corpus readiness, extraction provenance, and stable citation lineage.
- `query-and-generation`: Query orchestration, context building, grounded generation, citations, insufficient-evidence behavior, and synchronous query metrics.
- `retrieval-and-comparison`: Common retriever contract, PostgreSQL BM25, pgvector retrieval, deterministic hybrid fusion, intentional comparisons, and comparison evidence.
- `ingestion-and-jobs`: EDGAR identity selection, Kestra orchestration, application-owned jobs, deduplication, SSE progress, retries, scheduled ingestion, and pending-query continuation.
- `experiments-and-configuration`: Immutable experiment runs, versioned configuration records, reproducible execution snapshots, history, bookmarking, and feedback.
- `evaluation`: Selective `none`, `quick`, `standard`, and administrative `benchmark` profiles with independently versioned results.
- `usage-cost-and-budgets`: Categorized usage and cost ledger, quotas, atomic budget reservation and reconciliation, explicit fallback decisions, and user/admin views.
- `user-interface`: Tailwind CSS user and admin experiences centered on query, ingestion progress, comparison, history, jobs, and usage with progressive disclosure.
- `security-and-validation`: Boundary sanitization, allowlists, safe rendering, outbound-request controls, rate and size limits, secret handling, log redaction, auditability, and secure error responses.
- `modular-architecture`: Enforced service and module boundaries for frontend, API, domain services, adapters, persistence, workflows, retrieval, evaluation, and AI providers.

### Modified Capabilities

None. This repository has no existing product specifications.

## Impact

The change defines a greenfield Next.js/React/TypeScript/Tailwind frontend; Python/FastAPI/Pydantic/SQLAlchemy/Alembic backend; PostgreSQL 18 with pgvector and a trial of `pg_textsearch`; separate Kestra and Kestra PostgreSQL workloads; Google authentication with FastAPI-owned opaque sessions; initial OpenAI and later CPU-local embedding adapters; external SEC EDGAR and model-provider adapters; an initial single-node K3s/Traefik deployment with persistent volumes; and GitHub Actions CI/CD. It establishes the contracts that later bounded implementation changes must follow. Disposable PoCs resolve infrastructure-changing uncertainties before the Stage 2 foundation is built; this baseline change itself implements no application functionality.
