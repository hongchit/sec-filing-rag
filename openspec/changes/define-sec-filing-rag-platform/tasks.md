## 1. Stage 1.1 — PoC harness and decision record

- [ ] 1.1 Define target CPU architecture, representative non-production fixtures, measurement method, evidence format, and accept, constrain, replace, or defer decision template.
- [ ] 1.2 Keep PoC resources disposable and isolated from production manifests, credentials, and data.
- [ ] 1.3 Record pinned inputs, reproducible commands, observed results, limitations, owners, and decisions for every PoC.

## 2. Stage 1.2 — PostgreSQL 18 extension stack PoC

- [ ] 2.1 Build a disposable PostgreSQL 18 image with pinned pgvector and trial `pg_textsearch` versions for the target CPU architecture.
- [ ] 2.2 Load representative SEC-style chunks and prove vector, BM25, and ticker, CIK, form, fiscal-period, item, filing, and corpus-build filters can coexist.
- [ ] 2.3 Verify parameterized invalid-input handling, expected query plans, extension version discovery, restart persistence, and understood index rebuild and upgrade procedures.
- [ ] 2.4 Record image size, build and startup time, memory, index size, representative latency, and the decision to accept `pg_textsearch` or select a retriever-port-compatible alternative.

## 3. Stage 1.3 — Kestra database compatibility PoC

- [ ] 3.1 Run a pinned official Kestra image against a dedicated PostgreSQL 18 candidate using disposable storage and least-privilege credentials.
- [ ] 3.2 Execute a minimal workflow and verify execution history across application and database restarts.
- [ ] 3.3 Record compatibility, resource use, required configuration, and whether Kestra must use a separately pinned supported PostgreSQL version.

## 4. Stage 1.4 — K3s storage PoC

- [ ] 4.1 Prove the intended host and storage class satisfy PostgreSQL ownership, permissions, access-mode, capacity, and local-volume scheduling assumptions.
- [ ] 4.2 Verify data survives pod replacement and database restart while explicitly excluding host and volume disaster recovery.
- [ ] 4.3 Record storage constraints and the approved Stage 2 persistent-volume pattern.

## 5. Stage 1.5 — Traefik routing and streaming PoC

- [ ] 5.1 Deploy disposable frontend and API responders through the intended Traefik routing pattern with same-origin `/api`, forwarded-header trust, HTTPS redirect, host validation, and body limits.
- [ ] 5.2 Prove an SSE stream remains usable through ingress with heartbeats, disconnect, reconnect, buffering controls, and bounded timeouts.
- [ ] 5.3 Record ingress annotations, proxy trust boundaries, and routing constraints for Stage 2.

## 6. Stage 1.6 — Image delivery and CI connectivity PoC

- [ ] 6.1 Build a minimal target-architecture image, publish it under an immutable digest-addressable tag, and pull it from the intended registry using scoped credentials.
- [ ] 6.2 Prove the selected GitHub Actions runner can authenticate and deploy to a disposable K3s namespace without publicly exposing the Kubernetes API.
- [ ] 6.3 Record registry, runner, credential, network, provenance, and deployment-branch decisions for Stage 2.

## 7. Stage 1.7 — Resource envelope and foundation gate

- [ ] 7.1 Measure combined idle, startup, and representative-load CPU, memory, disk, and restart behavior for the approved database, Kestra, ingress, and minimal application candidates.
- [ ] 7.2 Decide the minimum K3s node envelope and whether internal Prometheus and Grafana provide sufficient value within that envelope.
- [ ] 7.3 Review every PoC decision and block Stage 2 until all foundation-changing failures have an accepted constraint or replacement.
- [ ] 7.4 Publish the Stage 1 evidence summary and explicit go or no-go decision for the separate Stage 2 foundation change.

## 8. Stage 2.1 — Reproducible K3s foundation

- [ ] 8.1 Document the approved single-node dedicated-VM topology, availability limitation, namespaces, DNS, local storage, environment overlays, prerequisites, and secret bootstrap.
- [ ] 8.2 Add reproducible K3s, Traefik, namespace, storage, Secret-reference, and ConfigMap manifests.
- [ ] 8.3 Verify a clean environment can bind a persistent volume and run a disposable internal workload.

## 9. Stage 2.2 — Versioned Hello World applications

- [ ] 9.1 Scaffold independently buildable Next.js/TypeScript/Tailwind and FastAPI/Pydantic applications with modular source layouts.
- [ ] 9.2 Add live and version API contracts with build-time commit/image identity and contract tests.
- [ ] 9.3 Build minimal containers and display frontend version, API reachability, and API version from FastAPI.

## 10. Stage 2.3 — Public ingress and TLS

- [ ] 10.1 Configure Traefik HTTPS routes for only the frontend and documented API prefix.
- [ ] 10.2 Configure certificate issuance, HTTP redirect, host validation, CORS policy, and baseline security headers.
- [ ] 10.3 Verify HTTPS browser-to-API behavior and prove internal service ports are not publicly reachable.

## 11. Stage 2.4 — Application PostgreSQL persistence

- [ ] 11.1 Build and pin a PostgreSQL 18 image containing tested versions of pgvector and trial `pg_textsearch`.
- [ ] 11.2 Deploy application PostgreSQL with dedicated credentials, service, persistent volume, and resource limits while documenting that host/volume disaster recovery is outside the MVP.
- [ ] 11.3 Add a minimal migration and adapter for deployment-check records using parameterized database access.
- [ ] 11.4 Verify simple query, extension availability, write/read behavior, and persistence across application and database pod restarts.

## 12. Stage 2.5 — Readiness and safe status

- [ ] 12.1 Implement bounded readiness checks for required application dependencies without coupling liveness to PostgreSQL.
- [ ] 12.2 Implement a response-modeled infrastructure-status endpoint that redacts topology, credentials, and exception internals.
- [ ] 12.3 Configure probes and verify unready pods stop receiving traffic and recover when dependencies return.

## 13. Stage 2.6 — Independent Kestra persistence

- [ ] 13.1 Deploy dedicated Kestra PostgreSQL with separate credentials, service, volume, and network exposure.
- [ ] 13.2 Deploy the pinned official Kestra image against only its dedicated database.
- [ ] 13.3 Create and execute a minimal validation workflow and verify execution history survives Kestra and database restarts.

## 14. Stage 2.7 — Protected internal workflow connectivity

- [ ] 14.1 Define a versioned internal callback contract and least-privilege workflow authentication mechanism.
- [ ] 14.2 Implement a protected, rate-limited internal validation endpoint with sanitized logging.
- [ ] 14.3 Verify valid Kestra invocation, invalid-credential rejection, timeout behavior, correlation, and lack of public exposure.

## 15. Stage 2.8 — Pull-request CI

- [ ] 15.1 Add pinned frontend lint, type, unit, and production-build checks.
- [ ] 15.2 Add pinned backend lint, type, unit, migration, and dependency-lock checks.
- [ ] 15.3 Add container builds, manifest rendering/validation, secret scanning, dependency vulnerability checks, and test-result reporting.
- [ ] 15.4 Prove representative frontend, backend, manifest, and security regressions fail pull-request CI without production secrets.

## 16. Stage 2.9 — Immutable deployment pipeline

- [ ] 16.1 Publish frontend and API images under immutable commit-addressed tags with provenance metadata.
- [ ] 16.2 Deploy only immutable tags from the protected deployment branch with serialized deployment concurrency.
- [ ] 16.3 Wait for rollout and run public plus internal smoke tests that fail the pipeline on readiness or version mismatch.

## 17. Stage 2.10 — Rollback and recreation rehearsal

- [ ] 17.1 Document and automate restoration of the last known-good stateless application version.
- [ ] 17.2 Rehearse an unhealthy release and verify healthy traffic plus persistent records survive restoration.
- [ ] 17.3 Recreate stateless services and configuration from version-controlled manifests and documented secret inputs without claiming database disaster recovery.
- [ ] 17.4 Deploy minimal internal-only Grafana and a metrics source if they prove the approved service, database, PVC, and Kestra signals without affecting readiness.
- [ ] 17.5 Run and record the complete Stage 2 acceptance suite, including the documented backup/recovery exclusion.

## 18. Stage 3.1 — Google authentication

- [ ] 18.1 Document the approved Google Authorization Code with PKCE and FastAPI-owned opaque-session threat model.
- [ ] 18.2 Implement verified-email login, stable-`sub` user resolution, hashed server sessions, secure cookies, CSRF/origin validation, logout, revocation, and validated return URLs.
- [ ] 18.3 Enforce the seven-day absolute and twelve-hour idle session limits with rotation after login and privilege changes.
- [ ] 18.4 Test invalid state/nonce, unverified email, CSRF, origin, expiry, deactivation, logout, token redaction, and account return behavior.

## 19. Stage 3.2 — Two-role authorization

- [ ] 19.1 Add application-owned `user` and `admin` roles and an audited initial-admin bootstrap.
- [ ] 19.2 Implement reusable FastAPI authorization policies and role-gated frontend navigation.
- [ ] 19.3 Test normal, admin, cross-user, deactivated-user, and role-refresh cases at the API boundary.

## 20. Stage 3.3 — Versioned configuration registry

- [ ] 20.1 Model immutable logical configuration versions, safe snapshots, active pointers, creator metadata, and secret references.
- [ ] 20.2 Add migrations, repository ports, transactional active-version selection, and lookup APIs.
- [ ] 20.3 Test that changes create new versions and historical versions remain unchanged and secret-free.

## 21. Stage 3.4 — Minimal production schema and seeded filing

- [ ] 21.1 Model normalized companies, ticker aliases, CIK identity, filings and sections with canonical/observed headings and qualified optional page coordinates; immutable corpus builds and chunk metadata projections; embedding sets; vectors; compatible indexes; and citation lineage.
- [ ] 21.2 Model multi-target query scope, per-source retrieval results, typed analytical metrics, immutable configuration snapshots, and purged-artifact state.
- [ ] 21.3 Add reversible migrations, dimension/configuration constraints, readiness transitions, cleanup protections, and idempotent repository operations.
- [ ] 21.4 Build a repeatable import for one approved 10-K with extraction, corpus, chunking, source metadata, and OpenAI embedding-set metadata.
- [ ] 21.5 Validate corpus completeness, legitimate item absence, table-of-contents/body heading disambiguation, title normalization, page-scheme qualification, duplicate import handling, filing-to-chunk traceability, and incompatible-vector rejection.

## 22. Stage 3.5 — One retrieval path

- [ ] 22.1 Define normalized retriever and result contracts independent of SQLAlchemy and provider types.
- [ ] 22.2 Implement the initial OpenAI `text-embedding-3-small` 1,536-dimensional embedding adapter and compatible vector retriever with allowlisted filters, version compatibility, controlled top-k, and parameterized queries.
- [ ] 22.3 Expose validated ticker, filing, section, and question query contracts with request and pagination limits.
- [ ] 22.4 Test ranked retrieval, unsupported/ambiguous ticker, invalid filters, incompatible embedding versions, and tenant isolation.

## 23. Stage 3.6 — Grounded answer and citations

- [ ] 23.1 Implement context limits, source delimiting, stable citation handles, and prompt-injection-aware context construction.
- [ ] 23.2 Implement the centralized gateway port and pinned OpenAI `gpt-5-mini-2025-08-07` Responses API adapter with at most two transient retries, operation deadlines, normalized errors, and no automatic fallback.
- [ ] 23.3 Add a versioned grounded-answer prompt and structured citation validation.
- [ ] 23.4 Test supported, insufficient-evidence, invalid-citation, provider-failure, unsafe-content-rendering, and financial-advice cases.

## 24. Stage 3.7 — Experiment persistence

- [ ] 24.1 Model immutable query executions, retrieved-result snapshots, answers, citations, configuration references, failures, and traces.
- [ ] 24.2 Persist successful and failed runs transactionally without mutating historical executions.
- [ ] 24.3 Implement user-scoped history/detail and admin-scoped inspection contracts with filters and controlled sorting.
- [ ] 24.4 Test historical rendering after configuration changes and cross-user access denial.

## 25. Stage 3.8 — Usage cost and basic budgets

- [ ] 25.1 Model effective-dated immutable OpenAI pricing, external/local inference ledger entries, budgets, reservations, decisions, and reconciliation.
- [ ] 25.2 Route generation usage through atomic global and per-experiment/job reservation and reconciliation.
- [ ] 25.3 Implement explicit block and configured-fallback results without silent substitution.
- [ ] 25.4 Test concurrent near-limit calls, provider failure, underestimated usage, expired reservation recovery, and ledger reconciliation.

## 26. Stage 3.9 — Walking-skeleton Tailwind UI

- [ ] 26.1 Build the responsive authenticated shell with Ask, History, Jobs, Usage, user controls, and role-gated Admin navigation.
- [ ] 26.2 Build the analyst-focused query form with ticker resolution, latest-10-K scope, multiline question, and collapsed Advanced Settings.
- [ ] 26.3 Build cited answer and source cards using canonical item labels, preserved observed headings, stable source anchors, and only qualified optional page coordinates, plus collapsed run-detail, feedback, evaluation, comparison, and bookmark controls.
- [ ] 26.4 Add accessible loading, empty, validation, insufficient-evidence, and error states with safe text rendering.
- [ ] 26.5 Verify the end-to-end login, seeded query, citation, cost, and history flow on desktop and mobile.

## 27. Stage 4.1 — Filing discovery and EDGAR policy

- [ ] 27.1 Implement authoritative ticker-to-CIK resolution and the latest accepted original-`10-K` policy while rejecting `10-K/A` as unsupported for the MVP.
- [ ] 27.2 Implement an SSRF-resistant, rate-limited SEC adapter with fixed endpoints, HTTPS, timeouts, response limits, and compliant User-Agent construction.
- [ ] 27.3 Implement trigger-dependent contact selection, verified-email disclosure, actor audit, encrypted/access-controlled persistence, and structured redaction.
- [ ] 27.4 Test user, schedule, admin backfill, retry, ambiguous security, unsafe identifier, and contact-leakage cases.

## 28. Stage 4.2 — Deterministic single-filing ingestion

- [ ] 28.1 Implement idempotent download and source-integrity recording for one explicit accession.
- [ ] 28.2 Implement versioned selected-item extraction and normalization with safe parser limits.
- [ ] 28.3 Implement chunking, gateway-based embeddings, BM25/vector indexing, and immutable lineage.
- [ ] 28.4 Implement completeness validation and atomic readiness publication while retaining the prior ready build.
- [ ] 28.5 Test retries and failures at every stage, legitimate absent items, duplicate inputs, malformed documents, and partial-build invisibility.

## 29. Stage 4.3 — Application job state machine

- [ ] 29.1 Model application jobs, attempts, stable stages, progress, trigger provenance, workflow reference, errors, cost, and budget state.
- [ ] 29.2 Define versioned Kestra start and callback contracts with idempotency keys and authenticated callbacks.
- [ ] 29.3 Enforce valid transactional state transitions and repeated/out-of-order callback handling.
- [ ] 29.4 Test durable REST state across browser, API, Kestra, and database restarts.

## 30. Stage 4.4 — Manual admin ingestion

- [ ] 30.1 Add validated admin filing-target preview and manual-ingestion start operations.
- [ ] 30.2 Add audited inspect, retry, cancel, and re-run actions with safe state guards.
- [ ] 30.3 Test user denial, terminal/retriable handling, idempotent retries, and cancellation propagation.

## 31. Stage 4.5 — On-demand ingestion

- [ ] 31.1 Model private ingestion requests and durable pending query executions separately from shared jobs.
- [ ] 31.2 Create or join ingestion from a missing-filing query after authorization, quota, consent, and budget checks.
- [ ] 31.3 Persist the original resolved inputs and cancellation/expiration state without holding the HTTP request open.
- [ ] 31.4 Test ready, missing, quota-blocked, budget-blocked, cancelled, and browser-departure paths.

## 32. Stage 4.6 — Deduplication and concurrency

- [ ] 32.1 Define the compatibility key for filing, corpus, extraction, chunking, embedding, and index versions.
- [ ] 32.2 Enforce one active compatible job with transactional uniqueness or locking and separately associate every request.
- [ ] 32.3 Define scheduled/on-demand collision, ownership, cost attribution, detachment, retry, and admin-cancellation rules.
- [ ] 32.4 Run concurrency tests proving one workflow, immutable EDGAR provenance, isolated requests, and recoverable retry.

## 33. Stage 4.7 — SSE progress and reconnect

- [ ] 33.1 Define versioned, public-safe SSE event schemas, authorization, heartbeats, cursor/reconciliation, and terminal events.
- [ ] 33.2 Implement persistent job retrieval and streaming without exposing raw Kestra payloads or contact identity.
- [ ] 33.3 Build in-place Tailwind progress, elapsed time, cost state, leave/return, retry, and role-appropriate failure details.
- [ ] 33.4 Test disconnect/reconnect, logout/return, shared-job visibility, terminal completion, and cross-user leakage.

## 34. Stage 4.8 — Automatic query continuation

- [ ] 34.1 Claim eligible pending queries transactionally when a corpus build becomes ready.
- [ ] 34.2 Revalidate user status, authorization, configuration, quota, and budget before retrieval or generation.
- [ ] 34.3 Transition the UI from readiness to the independently persisted completed or failed experiment.
- [ ] 34.4 Test duplicate ready events, cancelled/expired requests, user deactivation, insufficient budget, and at-most-once execution.

## 35. Stage 4.9 — Scheduled ingestion

- [ ] 35.1 Model audited, versioned scheduled ticker configuration with enabled state, filing type, cadence, and history depth.
- [ ] 35.2 Implement Kestra discovery using operational identity and application APIs rather than direct business-table writes.
- [ ] 35.3 Apply ready-build skipping, deduplication, overlap handling, and admin-visible failure state.
- [ ] 35.4 Test new filing, no change, overlapping schedule, disabled ticker, and discovery failure.

## 36. Stage 4.10 — Ingestion history and cost

- [ ] 36.1 Build user-scoped job history and detail with ticker, trigger, status, progress, timestamps, and authorized cost.
- [ ] 36.2 Build minimal admin scheduled-ticker and job pages with audited actions and workflow references.
- [ ] 36.3 Record and reconcile download, extraction, embedding, indexing, workflow, and retry costs without leaking contact identity.

## 37. Stage 5.1 — Retriever contract conformance

- [ ] 37.1 Create shared contract fixtures and conformance tests for metadata, scores, citations, filtering, limits, and errors.
- [ ] 37.2 Ensure query, context, and experiment modules depend only on the normalized retriever port.

## 38. Stage 5.2 — PostgreSQL BM25

- [ ] 38.1 Add versioned BM25 index migrations and operational restore/rebuild procedures.
- [ ] 38.2 Implement BM25 retrieval with validated query input and recorded extension/configuration versions.
- [ ] 38.3 Validate exact-term fixtures, score persistence, index upgrades, index rebuild behavior, and safe failure when unavailable.

## 39. Stage 5.3 — Vector strategy formalization

- [ ] 39.1 Version distance metric, embedding compatibility, index parameters, top-k, and metadata filters.
- [ ] 39.2 Implement a pinned CPU-only `sentence-transformers/all-MiniLM-L6-v2` adapter with an immutable model artifact, 384-dimensional normalized vectors, cosine similarity, and no runtime model download.
- [ ] 39.3 Create model-compatible MiniLM chunk and embedding sets, testing the 256-word-piece truncation boundary rather than silently truncating an existing chunk set.
- [ ] 39.4 Support concurrent OpenAI and MiniLM indexes selected explicitly by experiment configuration.
- [ ] 39.5 Add controlled and optimized-pipeline comparison fixtures covering quality, latency, input units, external/infrastructure cost, chunking differences, and index size.
- [ ] 39.6 Add dependency-aware admin retire/purge operations with size preview, active/shared protections, audit, and preserved experiment evidence.
- [ ] 39.7 Add deterministic vector retrieval fixtures and explainable advanced score display.

## 40. Stage 5.4 — Deterministic hybrid retrieval

- [ ] 40.1 Implement versioned reciprocal-rank fusion with controlled candidates and deterministic tie-breaking.
- [ ] 40.2 Persist component ranks/scores and final ordering without adding a hidden reranker call.
- [ ] 40.3 Test repeated results, ties, missing component candidates, and bounded resource use.

## 41. Stage 5.5 — Strategy selection

- [ ] 41.1 Register enabled retriever configurations and enforce user/admin allowlists in FastAPI.
- [ ] 41.2 Add readable BM25, Vector, and Hybrid controls in Advanced Settings with Hybrid as the documented default.
- [ ] 41.3 Verify an ordinary query executes exactly one selected strategy.

## 42. Stage 5.6 — Intentional comparison

- [ ] 42.1 Model comparison parents and independently executable child experiments.
- [ ] 42.2 Estimate and authorize aggregate selected-strategy cost before starting comparison.
- [ ] 42.3 Execute only selected strategies and retain partial success with per-child errors.

## 43. Stage 5.7 — Comparison results UI

- [ ] 43.1 Build accessible desktop columns and mobile stacked cards for answers, sources, latency, and categorized cost.
- [ ] 43.2 Build a normalized metrics table for retrieval, total latency, sources, citation coverage, generation cost, and evaluation cost.
- [ ] 43.3 Show qualitative observations only when a versioned evaluator supplies supporting evidence.
- [ ] 43.4 Test historical comparison reproduction, partial failures, responsive layout, and absence of automatic universal winners.

## 44. Stage 6.1 — Deterministic Quick evaluation

- [ ] 44.1 Implement versioned citation coverage, missing-citation, context-availability, answer-length, and operational checks.
- [ ] 44.2 Verify Quick performs no model call and persists results independently.

## 45. Stage 6.2 — Standard evaluation

- [ ] 45.1 Add a versioned evaluator prompt, allowlisted model, structured result, and independent lifecycle.
- [ ] 45.2 Route evaluation through gateway budgets, usage, cost, timeouts, and normalized errors.
- [ ] 45.3 Verify evaluation failure never changes the original answer's completion state.

## 46. Stage 6.3 — Evaluation profile policy

- [ ] 46.1 Model immutable `none`, `quick`, `standard`, and `benchmark` definitions and active policies.
- [ ] 46.2 Enforce user allowlists, sampling configuration, evaluation quotas, and explicit invocation records.
- [ ] 46.3 Add permitted query-page controls while keeping Benchmark in admin/experiment workflows.

## 47. Stage 6.4 — Benchmark dataset

- [ ] 47.1 Model immutable benchmark datasets, cases, filing/corpus scope, expected evidence, and rubrics.
- [ ] 47.2 Add validated import/export with access controls and referential integrity.
- [ ] 47.3 Publish a representative initial dataset and lock its version.

## 48. Stage 6.5 — Kestra benchmark workflow

- [ ] 48.1 Model application-owned benchmark jobs, case executions, progress, partial results, and budgets.
- [ ] 48.2 Coordinate bounded benchmark execution through authenticated versioned Kestra contracts.
- [ ] 48.3 Test retry without duplicate cases, partial persistence, cancellation, budget exhaustion, and progress.

## 49. Stage 6.6 — Scoped budget hierarchy

- [ ] 49.1 Add global, provider, model, category, job, user, and experiment budget scopes with period, currency, and precedence rules.
- [ ] 49.2 Extend atomic reservation/reconciliation across ingestion, embedding, generation, evaluation, and comparison.
- [ ] 49.3 Implement pause, block, expiry recovery, and explicit configured fallback workflows.
- [ ] 49.4 Stress-test concurrency, nested limits, retries, stale reservations, and ledger reconciliation.

## 50. Stage 6.7 — User cost views

- [ ] 50.1 Build monthly query/job counts, separated category costs, total, limit, used, and remaining summaries.
- [ ] 50.2 Document and display the shared-ingestion attribution rule and distinguish estimated, reserved, and final cost.
- [ ] 50.3 Verify user isolation and exact reconciliation to authorized ledger entries.

## 51. Stage 6.8 — Administrative governance

- [ ] 51.1 Build the minimal admin dashboard for service health, active/failed jobs, indexed filings, spend, warnings, and recent failures.
- [ ] 51.2 Build audited budget and model configuration pages with versioned pricing, defaults, allowlists, and fallback rules.
- [ ] 51.3 Build user and role management with rate controls and protected operational detail.
- [ ] 51.4 Verify admin totals reconcile and historical costs do not change after pricing updates.

## 52. Stage 6.9 — MVP acceptance

- [ ] 52.1 Run the authenticated query, missing-filing ingestion, reconnect, cited answer, history, usage, comparison, and evaluation user journeys.
- [ ] 52.2 Run scheduled-ticker, job management, model/strategy, benchmark, budget, user, and platform-cost admin journeys.
- [ ] 52.3 Complete authorization, validation, XSS, injection, SSRF, rate/quota, secret-redaction, cost-concurrency, persistence, rollback, and public-exposure testing.
- [ ] 52.4 Document operations, retention, incident response, SEC identity disclosure, known availability and durability limits, the explicit backup/disaster-recovery exclusion, and MVP acceptance.

## 53. Stage 7 — Corpus expansion

- [ ] 53.1 Define and test a collection adapter contract for taxonomy, extraction, completeness, citation, ingestion, and query scope.
- [ ] 53.2 Add remaining 10-K sections as a new immutable corpus version without changing historical experiments.
- [ ] 53.3 Design and add versioned base-filing-plus-amendment overlay support for `10-K/A`.
- [ ] 53.4 Add Form 10-Q discovery, extraction, completeness, citation, retrieval, and evaluation fixtures.
- [ ] 53.5 Add Form 8-K event/item semantics and explicit multi-filing scope.
- [ ] 53.6 Add reproducible cross-period and cross-filing selection, context balancing, citation grouping, and cost control.
- [ ] 53.7 Add an approval and provenance process for each non-SEC collection before query enablement.

## 54. Stage 8 — Agentic expansion

- [ ] 54.1 Define an execution-strategy contract and adapt `direct_rag` without changing behavior.
- [ ] 54.2 Define read-only, least-privilege agent tools with input schemas, authorization propagation, audit, iteration limits, and gateway-only model access.
- [ ] 54.3 Implement one bounded agentic strategy with explicit user selection, traceability, citation enforcement, and terminal failure states.
- [ ] 54.4 Implement direct-versus-agentic comparison over aligned question, filing, corpus, model-policy, metric, and evaluation scopes.
- [ ] 54.5 Add framework adapters one at a time without bypassing authorization, gateway, budget, experiment, or tool policies.
- [ ] 54.6 Benchmark step count, tools, retries, quality, latency, and agent cost with explicit budget-exhaustion outcomes.
