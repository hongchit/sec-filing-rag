## ADDED Requirements

### Requirement: Immutable configuration versions
Configuration changes SHALL create immutable version records with logical identity, creator, timestamp, safe values, and an independently managed active-version pointer.

#### Scenario: Default model changes
- **WHEN** an administrator selects a new default generation model
- **THEN** a new configuration version becomes active without modifying historical versions

### Requirement: Secret separation
Configuration records and experiment snapshots SHALL reference but SHALL NOT contain provider credentials, database passwords, operational contact emails, or other secrets.

#### Scenario: Configuration inspected
- **WHEN** an authorized user retrieves an experiment configuration snapshot
- **THEN** reproducibility metadata is present and secret values are absent

### Requirement: Reproducible experiment run
Every query execution SHALL persist its corpus and filing scope, question, retrieval and generation configuration, models, prompt, evaluation profile, execution strategy, retrieved results, answer, citations, latency, usage, costs, evaluations, and trace identifiers.

#### Scenario: Historical run reopened
- **WHEN** a user opens a run after active configurations have changed
- **THEN** the run displays the exact immutable versions used originally

### Requirement: History and feedback
Users SHALL be able to filter and inspect their own stored runs, bookmark or label a run, and submit answer feedback without mutating the original execution record.

#### Scenario: Feedback submitted
- **WHEN** a user marks an answer helpful or not helpful
- **THEN** the system stores a linked feedback record and preserves the original experiment

