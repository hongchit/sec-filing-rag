## ADDED Requirements

### Requirement: Categorized inference ledger
Every external or local model execution SHALL record execution provider/type, model and revision, purpose, category, input/token/embedding units, batch size when applicable, cache usage when available, latency, runtime/hardware metadata where applicable, calculated external and optional infrastructure cost, relevant user/job/experiment/trace identifiers, and timestamp; billable calls SHALL reference an immutable pricing version.

#### Scenario: Generation call completes
- **WHEN** the gateway receives provider usage for a generation call
- **THEN** it writes a generation-category ledger entry linked to the experiment and pricing version

#### Scenario: Local MiniLM batch completes
- **WHEN** the CPU-local embedding adapter completes a batch
- **THEN** it records zero external-provider cost plus input units, batch size, latency, pinned model/runtime versions, hardware class, and any configured infrastructure-cost allocation

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
