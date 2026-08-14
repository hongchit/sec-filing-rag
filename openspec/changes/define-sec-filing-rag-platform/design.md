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

Google OAuth/OIDC Authorization Code flow with PKCE supplies identity for the MVP. Any verified Google identity may register as a normal user; administrators are explicitly bootstrapped or assigned. The application maps the stable Google `sub` claim to an application user and maintains its own `user` or `admin` role.

FastAPI owns an opaque, server-side, revocable application session. Only a hash of the opaque session token is persisted. The browser sends it in a `Secure`, `HttpOnly`, `SameSite=Lax` cookie over the same site used by the frontend and `/api`. The default policy is a seven-day absolute lifetime and a twelve-hour idle timeout. Session identifiers rotate after authentication and privilege changes; account deactivation revokes all sessions. State-changing requests require a session-bound CSRF token, an allowlisted `Origin`, and an approved content type. SSE uses the authenticated read-only cookie flow.

FastAPI independently validates the application session and enforces authorization. The frontend may hide unavailable navigation but is not an authorization boundary. A new verified email for the same Google subject updates the application identity with an audit record and applies only to newly initiated SEC requests.

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

Companies are resolved from normalized ticker aliases to durable SEC CIK identity. The UI defaults to the most recently accepted original filing whose form is exactly `10-K`, ordered by SEC acceptance time, but the stored query references the resolved accession, CIK, selection-policy version, and corpus version. Fiscal reporting period is displayed separately from filing date.

Form `10-K/A` amendments are excluded from MVP ingestion, default selection, retrieval, and corpus merging. The product documents this limitation and may later add a versioned base-filing-plus-amendment overlay model.

Filing records retain at least submitted ticker, CIK, company name, form, filing date, SEC acceptance time when available, reporting quarter when applicable, accession number, fiscal year, fiscal month, fiscal/reporting-period date, source URL, ingestion timestamp, parser version, and selection/corpus lineage metadata.

Corpus readiness is versioned rather than a mutable filing Boolean. Filing, extraction, chunk-set, embedding/index, and ingestion versions preserve lineage. A prior ready version remains queryable while a replacement is built.

Selected Item 1, 1A, 1C, 3, 5, 7, 7A, 8, and 9A sections retain source and extraction metadata. The ingestion completeness policy distinguishes legitimate absence from extraction failure, especially for filing periods where an item was not required.

Item number is the stable section taxonomy. Each extracted section stores the versioned canonical Form 10-K title separately from the exact observed filer heading, plus a normalized display title, heading source, extraction evidence, and confidence where produced. The parser must not represent an inferred canonical title as though it was observed in the filing. Repeated table-of-contents headings, abbreviated or company-specific headings, combined sections, cross-references, and incorporated material require explicit extraction handling.

Page number is optional citation metadata because EDGAR HTML and ASCII do not provide uniform canonical pagination. Citations primarily use accession, source document URL, item, source excerpt, and stable source character offsets or element anchors. When a page coordinate is available, it stores both the value and its qualified scheme, such as `filer_printed`, `source_pdf`, or `edgar_rendered_pdf`; dynamically generated or ambiguous pages are never presented as an unqualified source page.

Authoritative source metadata remains normalized across companies, ticker aliases, filings, and sections. Immutable retrieval projections denormalize frequently filtered attributes such as company, CIK, filing, form, fiscal period, item, and corpus build onto chunks. A corpus build stores one immutable configuration snapshot plus a checksum for integrity/equivalence; generated UUIDs remain the relational identities.

Chunk sets and embedding sets are separate derived artifacts. An embedding set references the chunk set, exact model/revision, tokenizer/runtime, vector dimensions, distance metric, and compatible vector index that produced it. Because embedding models have different token limits, an optimized embedding pipeline may use a model-specific chunk set. Multiple ready embedding sets and their compatible indexes may coexist and be queried concurrently.

### Retrieval

All retrievers implement a normalized result contract. Lexical retrieval uses a selected PostgreSQL BM25 extension; semantic retrieval uses pgvector; hybrid retrieval initially uses deterministic reciprocal-rank fusion with documented candidate counts, tie-breaking, and versioned parameters. Extension and index versions are deployment metadata.

The initial ordinary query runs one selected strategy, defaulting to Hybrid when available. Comparison mode runs only strategies intentionally selected by the user and creates a parent comparison with independently persisted child experiments.

Queries are modeled with one or more resolved target records rather than embedding ticker assumptions in the query row. Each target resolves to exact companies, filings, fiscal periods, and optional sections. Retrieval-result association records retain target, chunk, filing, embedding set, strategy, rank, component scores, and context-selection state. Multi-target retrieval reserves or balances evidence per target so one company or filing cannot silently consume the entire global top-k.

Embedding comparisons declare their comparison mode. A controlled comparison uses a common chunk set supported by every compared model to isolate embedding effects. An optimized-pipeline comparison permits model-specific chunking and evaluates the complete chunking-plus-embedding retrieval configuration. Reports must identify which mode was used.

### Grounded generation and AI gateway

The context builder accepts normalized retrieval results, enforces context limits, and emits stable citation handles. The generation prompt requires supplied-context grounding, citations, insufficient-evidence disclosure, fact/interpretation separation, and no financial advice.

Every billable embedding, generation, evaluation, and future agent call passes through a centralized gateway. The gateway handles allowlisted providers/models, rate limits, timeouts, normalized errors, retries, telemetry, usage, pricing, and budget decisions. Application modules cannot import provider clients directly.

Stage 3 uses OpenAI `text-embedding-3-small` at 1,536 dimensions and pinned `gpt-5-mini-2025-08-07` generation through the Responses API. The gateway permits at most two retries for transient rate-limit, selected timeout, and server errors using bounded exponential backoff with jitter; it does not retry validation, authentication, policy, context-limit, or budget failures. The MVP performs no automatic provider or model fallback.

After the OpenAI path is validated, a local embedding adapter may use pinned `sentence-transformers/all-MiniLM-L6-v2`, producing 384-dimensional normalized vectors for cosine similarity. It uses pinned CPU-only PyTorch wheels and a pinned model revision packaged into an immutable image or model artifact; production pods do not download mutable model assets at startup. Its default 256-word-piece truncation requires explicit SEC-chunk testing and may drive a distinct chunking configuration.

Local model execution follows the same gateway/inference contract even when external provider cost is zero. It records input units, batch size, latency, model and revision, tokenizer, sentence-transformers/PyTorch versions, hardware/runtime class, failures, and optional allocated infrastructure-cost estimates.

### Immutable configurations and experiments

Logical configurations have immutable database versions and an independently selected active version. New values create new records; history is never rewritten. Secrets are referenced outside configuration snapshots. Experiments reference resolved corpus, retriever, embedding, prompt, generation, evaluation, pricing, and execution-strategy versions and retain retrieved results, answer, citations, metrics, costs, and traces.

The initial schema uses typed source and artifact tables, a shared immutable configuration-version registry, and immutable JSON configuration snapshots on corpus builds and experiments. Common analytical dimensions and metrics use typed columns; JSONB is reserved for configuration snapshots, uncommon metrics, and provider-specific details. Embeddings live in embedding sets rather than columns on chunks so different dimensions and indexes remain isolated.

An administrator may retire and purge derived test artifacts to free vector-index, embedding, and exclusively owned chunk-set storage. Cleanup first presents dependency and estimated-resource impact, rejects active/default sets and running jobs, removes only artifacts not required by another live set, and writes an audit record. Experiments retain configuration, metrics, retrieved-evidence snapshots, and a purged-artifact marker; purged runs remain inspectable but are no longer rerunnable from deleted derived artifacts.

### Usage, costs, and budgets

The ledger records all model executions. Provider calls use provider-reported usage and calculated cost by immutable pricing version; local calls record equivalent operational units and zero external-provider cost plus any explicitly configured infrastructure-cost allocation. Costs remain separately identifiable for ingestion, embedding, generation, evaluation, agent, retrieval infrastructure when applicable, and system activity.

Budget enforcement uses an atomic estimate-reserve-execute-reconcile lifecycle. Applicable global, provider, model, category, user, experiment, and job policies are evaluated consistently. A rejected reservation prevents the provider call. Expired reservations are recoverable. Fallback is permitted only when explicitly configured and is recorded in the experiment.

### UI information architecture

The normal Tailwind UI centers three tasks: Ask, monitor missing-data ingestion in place, and Compare. Primary navigation is Ask, Compare, History, Jobs, Usage, and a role-gated Admin area. Advanced retrieval, sections, evaluation, result count, model, scores, metrics, and costs use an expandable Advanced Settings or Run Details disclosure.

The query page is an analyst search tool rather than a workflow console. Missing data transitions the result region to persistent progress without navigating to Kestra. Answers contain readable cited prose, source cards, collapsed run details, feedback, evaluation, comparison, and bookmark actions. Desktop comparisons use columns and mobile comparisons use stacked cards. The UI never declares a winner without supporting evaluation evidence.

### Deployment and delivery

Stage 1 is a disposable pre-foundation PoC gate. It resolves only uncertainties capable of changing the foundation: PostgreSQL 18 extension coexistence, Kestra database compatibility, target storage behavior, Traefik same-origin and SSE routing, target-architecture image and registry delivery, CI-to-K3s connectivity, and the single-node resource envelope. Every PoC pins inputs, uses representative but non-production data, records commands and evidence, and ends in an explicit accept, constrain, replace, or defer decision. PoC resources are not promoted directly into production manifests, and product concerns such as Google authentication, OpenAI, MiniLM, SEC extraction, production schema, retrieval quality, and evaluation remain in their owning stages.

Stage 1.6 uses private GitHub Container Registry delivery and repository-scoped GitHub Actions Runner Controller (ARC) runners inside K3s. Local Docker Desktop validates the probe natively as `linux/arm64`, while a GitHub-hosted build job publishes one `linux/amd64` probe image for the x86_64 VPS under a full-commit tag and registry digest using `GITHUB_TOKEN`. The Dockerfile pins one multi-platform base-image index and both resolved child manifests are recorded. K3s pulls the amd64 image with a namespace-local `read:packages` credential. ARC polls GitHub using outbound HTTPS and creates at most one ephemeral deploy runner with no Docker socket, privileged mode, host networking, or Secret/RBAC permissions. The runner may update and observe only the approved workload resources in the selected project namespace; the Kubernetes API remains private.

The Stage 1.6 proof deploys into `project-sec-filing-rag-poc` and is deleted after evidence capture. A separately reviewed set of manifests may then leave the same accepted digest running in `project-sec-filing-rag` as a non-production static portfolio demonstration. This persistent demo has no input, provider calls, database, or cost-generating endpoint and is not a promotion of the disposable PoC resources. Each namespace receives its own out-of-band GHCR pull Secret and Origin CA TLS Secret. Cross-namespace TLS Secret references remain disabled.

The Stage 1 PostgreSQL PoC is the first gate because it can change the application database image and retrieval architecture. It must prove pinned pgvector and trial `pg_textsearch` versions build and load together on PostgreSQL 18; coexist under representative vector, BM25, and metadata-filtered queries; retain data and indexes across a disposable restart; expose version metadata; use expected query plans; and have understood rebuild and upgrade procedures. Failure of `pg_textsearch` does not couple the domain to another implementation: lexical retrieval remains behind the retriever port and a replacement is selected before Stage 2.

Stage 2 proves a single-node K3s baseline on a dedicated VM, Traefik TLS ingress, immutable frontend/API images, the PoC-approved PostgreSQL and extension versions, isolated Kestra PostgreSQL, Kestra, local SSD-backed persistent volumes, secrets/configuration, CI/CD, readiness, smoke tests, persistence, and rollback. Only Next.js and FastAPI ingress are public. Stage 1.7 includes ARC controller/listener idle usage and active-runner peak usage in the node-envelope decision.

Application PostgreSQL, Kestra PostgreSQL, and Kestra storage use separate PVCs and prove persistence across pod restarts. Database backup, disaster recovery, recovery-point objectives, and recovery-time objectives are outside the MVP boundary. The MVP makes no high-availability or disaster-recovery claim; those controls remain required future production-hardening work before stronger durability claims.

Stage 2 may include internal-only Grafana with a metrics source such as Prometheus only when the Stage 1 resource-envelope PoC shows that its value and resource cost are acceptable. It may prove collection of API availability/latency/errors, pod restarts, PostgreSQL reachability, PVC usage, and Kestra health. Monitoring is not an application readiness dependency, must contain no filing/user/sensitive payloads, and must not expand into a general observability dashboard.

Delivery proceeds through independently testable iterations:

1. Stage 1: disposable infrastructure PoCs and a recorded go/no-go foundation decision.
2. Stage 2: deployment foundation, applications, ingress/TLS, databases/extensions, readiness, Kestra, internal connectivity, CI, deployment, rollback.
3. Stage 3: Google login, roles, versioned configuration, seeded corpus, one retriever, grounded answer, experiments, usage/cost, basic budget, end-to-end UI.
4. Stage 4: filing discovery, EDGAR identity, ingestion pipeline, jobs, manual/on-demand/scheduled triggers, deduplication, SSE, continuation, history.
5. Stage 5: common retriever contract, BM25, formalized vector, hybrid, selection, intentional comparison, comparison UI.
6. Stage 6: deterministic and model evaluation, profile policies, benchmark data/workflows, scoped budgets, governance views, and MVP acceptance.
7. Stage 7: new corpus adapters, additional forms, and cross-period queries.
8. Stage 8: bounded, policy-compliant agent execution and comparison.

## Risks / Trade-offs

- [Greenfield scope is too broad for one implementation change] → Treat this change as the baseline specification and implement each stage or bounded iteration through subsequent changes.
- [The `pg_textsearch` trial may expose PostgreSQL 18 compatibility or operational issues] → Pin both extensions, prove coexistence and representative retrieval in Stage 1, understand index rebuild and upgrades, and select a retriever-port-compatible alternative before Stage 2 if it fails.
- [Shared ingestion conflicts with user ownership and cancellation] → Separate request intent from shared job execution and restrict shared cancellation to admins.
- [Automatic continuation spends money after the user leaves] → Persist consent, reserve or recheck budgets, and skip cancelled/expired pending requests.
- [Concurrent calls overspend budgets] → Use transactional reservations and reconciliation rather than check-then-spend.
- [Prompt injection in filings or user questions influences model behavior] → Treat retrieved content as untrusted data, delimit it, restrict tool access, require citations, and evaluate outputs; do not claim prompt injection can be eliminated.
- [Generated output or filing HTML enables XSS] → Store/render plain text by default and sanitize any explicitly supported markup.
- [SEC contact email leaks through logs or UI] → Store encrypted or access-controlled provenance, use structured redaction, and expose only a non-sensitive identity category.
- [Readiness checks overload dependencies or disclose topology] → Use bounded, cached/minimal checks and return only safe summaries publicly.
- [K3s single-node storage is neither highly available nor disaster-recoverable] → State the limitation prominently, prove only pod-restart persistence in the MVP, and require a later backup/recovery design before stronger durability or production claims.
- [Model-specific chunking confounds embedding comparisons] → Label controlled versus optimized-pipeline comparisons and persist every chunking, embedding, and index configuration used.
- [Concurrent embedding sets consume database, index, and CPU resources] → Apply quotas, expose set-level size/usage, allow audited dependency-aware cleanup, and protect active or shared artifacts.
- [Ignoring 10-K amendments can omit corrected disclosures] → Clearly disclose the MVP limitation, preserve original accession identity, and add amendment-aware overlays only through a later versioned corpus design.
- [Configuration immutability grows storage and complicates lookup] → Use logical configuration keys, indexed version tables, explicit active pointers, and retention rules that never break experiment lineage.
- [Evaluation claims a universal winner] → Present measurements and evidence-bound observations only.

## Migration Plan

There is no production application data to migrate. Complete the disposable Stage 1 PoC gate and record its decisions before creating the separate Stage 2 foundation implementation change. Require the Stage 2 acceptance suite before application schema work. Apply application migrations through versioned deployment jobs, seed only the controlled Stage 3 corpus, and roll out later capabilities behind allowlists or feature flags. Preserve backward-compatible API and event contracts within a stage. Roll back stateless application images independently; database migrations must include a tested forward-fix or reversible path appropriate to data risk. Persistent volumes and secret/configuration recreation are MVP prerequisites; database backup and disaster recovery are explicitly deferred production-hardening work.

## Open Questions

- Which container registry, certificate issuer, and deployment branch will be used?
- What are the initial question-size, request-rate, query, ingestion, evaluation, and monetary quotas?
- What exact versioned applicability rules distinguish legitimate absence of each selected 10-K item?
- How long are raw questions, generated answers, traces, contact identities, and detailed provider payloads retained?
