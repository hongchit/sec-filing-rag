## ADDED Requirements

### Requirement: Frontend boundary
Next.js SHALL communicate only with documented FastAPI contracts and SHALL NOT directly access PostgreSQL, Kestra, SEC EDGAR, or AI providers.

#### Scenario: Query submitted
- **WHEN** the browser submits a filing question
- **THEN** it uses the FastAPI query contract and receives no provider or workflow credentials

### Requirement: Modular backend
The backend SHALL separate API transport, application use cases, domain policy, persistence, and external adapters so domain behavior can be tested without network services or framework-specific objects.

#### Scenario: Retriever unit test
- **WHEN** query orchestration is tested with a fake retriever and gateway
- **THEN** it executes without importing provider SDKs, Kestra payloads, or database models into the domain contract

### Requirement: Ports for replaceable integrations
SEC retrieval, workflow control, retrieval strategies, generation, evaluation, cost pricing, identity verification, and persistence SHALL be accessed through explicit interfaces with adapter-specific behavior contained at the boundary.

#### Scenario: Provider adapter replaced
- **WHEN** an allowed generation provider is changed
- **THEN** query orchestration and experiment contracts remain unchanged

### Requirement: Policy cannot be bypassed
All billable model operations SHALL pass through the AI gateway, all public authorization SHALL pass through FastAPI, and all durable business state SHALL be written to application PostgreSQL rather than Kestra PostgreSQL.

#### Scenario: New evaluator added
- **WHEN** a model-based evaluator is introduced
- **THEN** it uses gateway budget and usage controls and writes application-owned evaluation records

### Requirement: Versioned contracts
Public APIs, SSE event types, internal workflow callbacks, retriever results, job states, and configuration schemas SHALL be explicitly versioned or evolved compatibly with contract tests.

#### Scenario: Workflow callback retried after deployment
- **WHEN** an in-flight workflow calls the supported callback contract after an application rollout
- **THEN** the application accepts the compatible version or rejects it with a controlled terminal response

