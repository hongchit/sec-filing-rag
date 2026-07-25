## Context

The repository is a greenfield platform with local K3s-oriented infrastructure but no application implementation. The product must serve authenticated analysts publicly while keeping PostgreSQL, Kestra, provider credentials, operational identities, and administrative operations private. It must support synchronous RAG, durable ingestion, reproducible experiments, selective evaluation, and cost governance without coupling the browser to workflow-engine or provider details.

Primary stakeholders are analysts, administrators, operators, developers, and data subjects whose verified Google email may be used for user-triggered SEC requests. The initial corpus is selected Form 10-K sections. The initial deployment target is K3s with Traefik, GitHub Actions, two independent PostgreSQL workloads, and persistent storage.

## Goals / Non-Goals

**Goals:**

- Deliver a secure, modular architecture whose components can be independently tested and replaced through stable contracts.
- Make simple, cited filing questions the default user experience while retaining reproducible advanced experiments.
- Keep synchronous query execution in FastAPI-owned application services and durable asynchronous work in Kestra.
- Preserve immutable corpus, configuration, experiment, evaluation, usage, and cost lineage.
- Validate and normalize all untrusted input at trust boundaries and prevent injection, SSRF, unsafe rendering, sensitive-data leakage, and resource abuse.
- Prove deployment, persistence, service isolation, health checks, rollout safety, and rollback before building product features.

**Non-Goals:**

- Anonymous access, unrestricted model choice, unrestricted backfills, public Kestra access, or direct frontend access to internal services.
- Multi-turn chat, customizable experiment matrices, advanced dashboards, agent execution, or expanded filing types in the initial MVP.
- Treating Kestra as the application system of record or as the synchronous query runtime.
- Automatically running every retriever or evaluator for ordinary queries.

## Decisions

### Modular service boundaries

Next.js presents the Tailwind CSS UI and communicates only with FastAPI. FastAPI owns authentication enforcement, authorization, validation, orchestration, application state, and public contracts. Domain modules depend on ports for persistence, SEC access, workflow execution, retrieval, generation, evaluation, and telemetry; infrastructure adapters implement those ports. Provider SDKs, SQLAlchemy models, Kestra payloads, and HTTP framework types do not become domain contracts.

Alternatives considered: a microservice per domain was rejected for the MVP because it adds network and deployment complexity without demonstrated scaling need; a single unstructured backend module was rejected because it would entangle policy, providers, and persistence. The backend starts as a modular monolith with explicit package boundaries and may extract services later.

### Authentication and authorization

Google OAuth/OIDC supplies identity for the MVP. The application accepts only verified Google email identities, maps the stable provider subject to an application user, and maintains its own `user` or `admin` role. FastAPI independently validates the application session/token and enforces authorization. The frontend may hide unavailable navigation but is not an authorization boundary.

The initial admin is bootstrapped through a documented, auditable configuration process. Role changes and administrative actions are audited. OAuth provider tokens are minimized and are not exposed to application JavaScript or retained unless required.

### Input validation and sanitization

Every external boundary uses explicit Pydantic request and response models with unknown-field policy, type constraints, maximum lengths, controlled enumerations, and canonicalization rules. Normalization is separate from validation: for example, ticker input is trimmed and uppercased, then checked against a conservative syntax and resolved against authoritative company data. Filing identifiers, section choices, retrieval strategies, evaluation profiles, pagination, sort keys, model identifiers, URLs, and job actions use allowlists or typed identifiers.

SQL uses SQLAlchemy expressions or parameterized statements. User-controlled values never select raw SQL fragments, index names, table names, sort expressions, prompts, provider endpoints, filesystem paths, or Kestra workflow definitions. The server rejects oversized questions, excessive section lists, invalid Unicode/control characters where inappropriate, and request bodies beyond configured limits.

React renders text as text. Filing excerpts and generated answers are not inserted as unsanitized HTML. Markdown, if later enabled, uses a restrictive sanitizer and link policy. Security headers include an appropriate Content Security Policy. Errors use stable public codes and sanitized messages; detailed exceptions remain in access-controlled telemetry with secrets and personal data redacted.

Outbound SEC and provider calls use fixed adapter-controlled base URLs, HTTPS, timeouts, response-size limits, redirect policy, and rate limiting. Users cannot supply arbitrary fetch URLs, preventing SSRF. Uploaded files and arbitrary remote document URLs are outside the MVP.

### Application-owned durable state

Application PostgreSQL is the business system of record. Kestra PostgreSQL stores only Kestra-managed state. Application jobs expose stable stages and store a Kestra execution reference but never expose raw workflow structure to users.

An ingestion request represents a user's or system actor's intent; a shared ingestion job represents one compatible corpus build. Multiple requests can join one active job. The initial trigger provenance and EDGAR identity remain immutable. A user may detach their pending query; only an authorized administrator may cancel shared work.

### Filing and corpus versioning

Queries resolve an explicit filing scope. The UI defaults to the latest supported 10-K, but the stored query references the resolved accession and corpus version. Corpus readiness is versioned rather than a mutable filing Boolean. Filing, extraction, chunk-set, embedding/index, and ingestion versions preserve lineage. A prior ready version remains queryable while a replacement is built.

Selected Item 1, 1A, 1C, 3, 5, 7, 7A, 8, and 9A sections retain source and extraction metadata. The ingestion completeness policy distinguishes legitimate absence from extraction failure, especially for filing periods where an item was not required.

### Retrieval

All retrievers implement a normalized result contract. Lexical retrieval uses a selected PostgreSQL BM25 extension; semantic retrieval uses pgvector; hybrid retrieval initially uses deterministic reciprocal-rank fusion with documented candidate counts, tie-breaking, and versioned parameters. Extension and index versions are deployment metadata.

The initial ordinary query runs one selected strategy, defaulting to Hybrid when available. Comparison mode runs only strategies intentionally selected by the user and creates a parent comparison with independently persisted child experiments.

### Grounded generation and AI gateway

The context builder accepts normalized retrieval results, enforces context limits, and emits stable citation handles. The generation prompt requires supplied-context grounding, citations, insufficient-evidence disclosure, fact/interpretation separation, and no financial advice.

Every billable embedding, generation, evaluation, and future agent call passes through a centralized gateway. The gateway handles allowlisted providers/models, rate limits, timeouts, normalized errors, retries, telemetry, usage, pricing, and budget decisions. Application modules cannot import provider clients directly.

### Immutable configurations and experiments

Logical configurations have immutable database versions and an independently selected active version. New values create new records; history is never rewritten. Secrets are referenced outside configuration snapshots. Experiments reference resolved corpus, retriever, embedding, prompt, generation, evaluation, pricing, and execution-strategy versions and retain retrieved results, answer, citations, metrics, costs, and traces.

### Usage, costs, and budgets

The ledger records provider-reported usage and calculated cost by immutable pricing version and purpose. Costs remain separately identifiable for ingestion, embedding, generation, evaluation, agent, retrieval infrastructure when applicable, and system activity.

Budget enforcement uses an atomic estimate-reserve-execute-reconcile lifecycle. Applicable global, provider, model, category, user, experiment, and job policies are evaluated consistently. A rejected reservation prevents the provider call. Expired reservations are recoverable. Fallback is permitted only when explicitly configured and is recorded in the experiment.

### UI information architecture

The normal Tailwind UI centers three tasks: Ask, monitor missing-data ingestion in place, and Compare. Primary navigation is Ask, Compare, History, Jobs, Usage, and a role-gated Admin area. Advanced retrieval, sections, evaluation, result count, model, scores, metrics, and costs use an expandable Advanced Settings or Run Details disclosure.

The query page is an analyst search tool rather than a workflow console. Missing data transitions the result region to persistent progress without navigating to Kestra. Answers contain readable cited prose, source cards, collapsed run details, feedback, evaluation, comparison, and bookmark actions. Desktop comparisons use columns and mobile comparisons use stacked cards. The UI never declares a winner without supporting evaluation evidence.

### Deployment and delivery

Stage 0 proves K3s, Traefik TLS ingress, immutable frontend/API images, application PostgreSQL with pgvector and the selected BM25 extension, isolated Kestra PostgreSQL, Kestra, persistent volumes, secrets/configuration, CI/CD, readiness, smoke tests, persistence, and rollback. Only Next.js and FastAPI ingress are public.

Delivery proceeds through independently testable iterations:

1. Stage 0: deployment foundation, applications, ingress/TLS, databases/extensions, readiness, Kestra, internal connectivity, CI, deployment, rollback.
2. Stage 1: Google login, roles, versioned configuration, seeded corpus, one retriever, grounded answer, experiments, usage/cost, basic budget, end-to-end UI.
3. Stage 2: filing discovery, EDGAR identity, ingestion pipeline, jobs, manual/on-demand/scheduled triggers, deduplication, SSE, continuation, history.
4. Stage 3: common retriever contract, BM25, formalized vector, hybrid, selection, intentional comparison, comparison UI.
5. Stage 4: deterministic and model evaluation, profile policies, benchmark data/workflows, scoped budgets, and governance views.
6. Stage 5: new corpus adapters, additional forms, and cross-period queries.
7. Stage 6: bounded, policy-compliant agent execution and comparison.

## Risks / Trade-offs

- [Greenfield scope is too broad for one implementation change] → Treat this change as the baseline specification and implement each stage or bounded iteration through subsequent changes.
- [PostgreSQL BM25 extension constrains PostgreSQL image, upgrades, and backups] → Select and pin the extension before Stage 0 completion; test installation, restore, index recreation, and version compatibility.
- [Shared ingestion conflicts with user ownership and cancellation] → Separate request intent from shared job execution and restrict shared cancellation to admins.
- [Automatic continuation spends money after the user leaves] → Persist consent, reserve or recheck budgets, and skip cancelled/expired pending requests.
- [Concurrent calls overspend budgets] → Use transactional reservations and reconciliation rather than check-then-spend.
- [Prompt injection in filings or user questions influences model behavior] → Treat retrieved content as untrusted data, delimit it, restrict tool access, require citations, and evaluate outputs; do not claim prompt injection can be eliminated.
- [Generated output or filing HTML enables XSS] → Store/render plain text by default and sanitize any explicitly supported markup.
- [SEC contact email leaks through logs or UI] → Store encrypted or access-controlled provenance, use structured redaction, and expose only a non-sensitive identity category.
- [Readiness checks overload dependencies or disclose topology] → Use bounded, cached/minimal checks and return only safe summaries publicly.
- [K3s single-node storage or database topology is not highly available] → Document the initial availability envelope, backup/restore objectives, and upgrade path before production claims.
- [Configuration immutability grows storage and complicates lookup] → Use logical configuration keys, indexed version tables, explicit active pointers, and retention rules that never break experiment lineage.
- [Evaluation claims a universal winner] → Present measurements and evidence-bound observations only.

## Migration Plan

There is no production application data to migrate. Establish Stage 0 infrastructure first and require its acceptance suite before application schema work. Apply application migrations through versioned deployment jobs, seed only the controlled Stage 1 corpus, and roll out later capabilities behind allowlists or feature flags. Preserve backward-compatible API and event contracts within a stage. Roll back stateless application images independently; database migrations must include a tested forward-fix or reversible path appropriate to data risk. Persistent data, secret bootstrap, database backup/restore, and configuration recovery procedures are prerequisites for production use.

## Open Questions

- Which Google identity/session integration will own the browser session while ensuring FastAPI performs independent validation?
- Which PostgreSQL BM25 extension and compatible PostgreSQL image/version will be pinned?
- Which container registry, certificate issuer, deployment branch, and production backup provider will be used?
- What are the initial question-size, request-rate, query, ingestion, evaluation, and monetary quotas?
- What exact policy defines the latest filing and legitimate absence of each selected 10-K item?
- How long are raw questions, generated answers, traces, contact identities, and detailed provider payloads retained?
- Is the initial K3s target single-node or multi-node, and what recovery objectives are required?
