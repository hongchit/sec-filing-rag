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
The application PostgreSQL image SHALL install and report compatible, pinned versions of pgvector and the selected PostgreSQL BM25 extension before stages that depend on them.

#### Scenario: Extension verification
- **WHEN** deployment smoke tests query extension availability
- **THEN** the tests confirm the expected extension names and versions without exposing connection credentials

### Requirement: Immutable safe deployment
CI/CD SHALL test pull requests and deploy immutable commit-addressed images with rollout verification, smoke tests, deployment serialization, and a tested restoration path.

#### Scenario: Unhealthy release
- **WHEN** a newly deployed version fails readiness or smoke tests
- **THEN** the pipeline fails and a previously healthy version can be restored without losing persistent records

