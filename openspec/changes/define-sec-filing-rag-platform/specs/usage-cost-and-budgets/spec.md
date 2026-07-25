## ADDED Requirements

### Requirement: Categorized usage ledger
Every billable call SHALL record provider, model, purpose, category, token or embedding units, cache usage when available, latency, immutable pricing version, calculated cost, relevant user/job/experiment/trace identifiers, and timestamp.

#### Scenario: Generation call completes
- **WHEN** the gateway receives provider usage for a generation call
- **THEN** it writes a generation-category ledger entry linked to the experiment and pricing version

### Requirement: Separately identifiable costs
Ingestion, embedding, generation, evaluation, agent, system, and applicable retrieval infrastructure costs SHALL remain separately identifiable even when summaries combine categories.

#### Scenario: User usage summary
- **WHEN** a user views monthly usage
- **THEN** generation, evaluation, ingestion/embedding, and total cost can be reconciled to authorized ledger records

### Requirement: Atomic budget enforcement
Before a billable operation, the system SHALL estimate and atomically reserve cost against every applicable enabled budget, execute only if permitted, and reconcile the reservation to actual cost.

#### Scenario: Concurrent near-limit requests
- **WHEN** concurrent operations would collectively exceed a budget
- **THEN** transactional reservation permits only the operations that fit

### Requirement: Explicit budget outcomes
Budget decisions SHALL be recorded as permit, block, pause, or explicitly configured fallback; model substitution SHALL never occur silently.

#### Scenario: Fallback model used
- **WHEN** a primary model is blocked and an allowed fallback is selected
- **THEN** the experiment records the decision, original selection, fallback model, and resulting usage

### Requirement: Scoped governance
The platform SHALL support global, provider, model, category, job, user, and experiment budget scopes, with the initial release implementing global, per-model, per-category, and per-job controls.

#### Scenario: Multiple limits apply
- **WHEN** a call is subject to several budget policies
- **THEN** the documented policy resolution applies every relevant constraint before permitting execution

