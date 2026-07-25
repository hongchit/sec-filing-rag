## ADDED Requirements

### Requirement: Selective evaluation profiles
The platform SHALL support independently versioned `none`, `quick`, `standard`, and `benchmark` profiles and SHALL run only a profile authorized and explicitly requested, sampled by configured policy, or started by an administrator.

#### Scenario: Ordinary query default
- **WHEN** a user submits a query without choosing an evaluation profile
- **THEN** no additional evaluation model call is made

### Requirement: Deterministic quick evaluation
Quick evaluation SHALL use low-cost deterministic checks such as citation coverage, missing citations, context availability, answer length, and existing execution metrics without a model call.

#### Scenario: Quick evaluation requested
- **WHEN** an authorized user selects Quick
- **THEN** results are recorded with an evaluator version and no billable evaluation-model usage

### Requirement: Independent model evaluation
Standard and benchmark evaluations SHALL be stored separately from the source experiment, use the AI gateway, record their configuration and cost, and SHALL NOT change the original answer status when evaluation fails.

#### Scenario: Evaluator provider failure
- **WHEN** a standard evaluation call fails
- **THEN** the answer remains available and the evaluation has its own failed state and normalized error

### Requirement: Versioned benchmark execution
Administrative benchmarks SHALL reference immutable dataset, corpus, experiment, evaluator, and configuration versions and SHALL run as application-owned asynchronous jobs coordinated by Kestra.

#### Scenario: Benchmark retry
- **WHEN** a partially completed benchmark is retried
- **THEN** completed cases are not duplicated and partial results remain traceable

