## ADDED Requirements

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
When Stage 0 includes Grafana, it SHALL remain internal-only and use a metrics source to validate application availability and latency, errors, pod restarts, database reachability, persistent-volume usage, and Kestra health without becoming a readiness dependency.

#### Scenario: Monitoring unavailable
- **WHEN** Grafana or its metrics source is unavailable
- **THEN** public application readiness remains governed by application dependencies and monitoring remains inaccessible through public ingress

### Requirement: Immutable safe deployment
CI/CD SHALL test pull requests and deploy immutable commit-addressed images with rollout verification, smoke tests, deployment serialization, and a tested restoration path.

#### Scenario: Unhealthy release
- **WHEN** a newly deployed version fails readiness or smoke tests
- **THEN** the pipeline fails and a previously healthy version can be restored without losing persistent records
