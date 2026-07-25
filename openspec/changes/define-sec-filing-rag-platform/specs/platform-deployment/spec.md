## ADDED Requirements

### Requirement: Pre-foundation proof gate
Before foundation implementation begins, the platform SHALL complete disposable proofs for PostgreSQL-extension compatibility, Kestra database compatibility, target storage behavior, ingress and SSE routing, target-architecture image delivery, CI deployment connectivity, and the single-node resource envelope.

#### Scenario: Foundation decision
- **WHEN** the pre-foundation proofs complete
- **THEN** their pinned inputs, reproducible procedure, measured evidence, limitations, and accept, constrain, replace, or defer decisions are recorded before Stage 2 manifests are implemented

### Requirement: PostgreSQL extension proof
The first pre-foundation proof SHALL test compatible pinned pgvector and trial `pg_textsearch` versions together on PostgreSQL 18 using representative vector, BM25, and metadata-filtered retrieval without coupling the retriever contract to the extension.

#### Scenario: Extension candidate fails
- **WHEN** `pg_textsearch` cannot satisfy the compatibility or operational acceptance criteria
- **THEN** PostgreSQL 18 and pgvector may remain while a retriever-port-compatible lexical-search alternative is selected before Stage 2

### Requirement: Isolated K3s service topology
The platform SHALL deploy Next.js and FastAPI behind Traefik TLS ingress while PostgreSQL, Kestra PostgreSQL, Kestra, and internal service ports remain inaccessible through public ingress.

#### Scenario: Public and internal exposure
- **WHEN** the deployed environment is scanned through its public entry points
- **THEN** only the intended frontend and API routes are reachable

### Requirement: Independent persistent databases
The platform SHALL operate application PostgreSQL and Kestra PostgreSQL as separate workloads with distinct services, credentials, databases, and persistent volumes.

#### Scenario: Workload restart
- **WHEN** either database and its client workload are restarted
- **THEN** its persisted validation record or workflow history remains available without using the other database

### Requirement: Health and version contracts
FastAPI SHALL provide liveness, readiness, version, and safe infrastructure-status endpoints, and readiness SHALL fail when a required application dependency is unavailable.

#### Scenario: Database unavailable
- **WHEN** application PostgreSQL is unavailable
- **THEN** liveness remains process-oriented, readiness fails, and unready pods stop receiving traffic

### Requirement: Required PostgreSQL extensions
The application database SHALL use PostgreSQL 18 and SHALL install and report compatible, pinned versions of pgvector and the trial `pg_textsearch` extension before stages that depend on them.

#### Scenario: Extension verification
- **WHEN** deployment smoke tests query extension availability
- **THEN** the tests confirm the expected extension names and versions without exposing connection credentials

### Requirement: Single-node persistence boundary
The initial K3s environment SHALL use a documented single-node availability model with separate local persistent volumes and SHALL identify database backup, disaster recovery, recovery-point objectives, and recovery-time objectives as outside the MVP boundary.

#### Scenario: Database pod restart
- **WHEN** either PostgreSQL pod restarts while its persistent volume remains available
- **THEN** its deployment-check record or workflow history remains available without claiming recovery from volume or host loss

### Requirement: Minimal internal monitoring
When Stage 2 includes Grafana after an acceptable Stage 1 resource-envelope decision, it SHALL remain internal-only and use a metrics source to validate application availability and latency, errors, pod restarts, database reachability, persistent-volume usage, and Kestra health without becoming a readiness dependency.

#### Scenario: Monitoring unavailable
- **WHEN** Grafana or its metrics source is unavailable
- **THEN** public application readiness remains governed by application dependencies and monitoring remains inaccessible through public ingress

### Requirement: Immutable safe deployment
CI/CD SHALL test pull requests and deploy immutable commit-addressed images with rollout verification, smoke tests, deployment serialization, and a tested restoration path.

#### Scenario: Unhealthy release
- **WHEN** a newly deployed version fails readiness or smoke tests
- **THEN** the pipeline fails and a previously healthy version can be restored without losing persistent records
